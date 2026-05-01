# Sunrise Admin App – Deployment Guide

**Repository:** https://github.com/quietcod/sunrise_app_admin (branch `main`)
**App package:** `com.sunrise.admin`
**Server base URL:** `https://admin.thesunrisecomputers.com/flutex_admin_api/`

This release bundles four feature areas. Both the Flutter app and the
Perfex/CodeIgniter server module must be updated together — the app uses
endpoints that only exist in the updated PHP controllers.

---

## 1. UI Refresh

Visual refresh across dashboard, tickets, projects, tasks, attendance and
estimates. Highlights:

- New dashboard widget styling (cards, icons, gradients).
- Ticket priority counts now match `/tickets` snapshot (no longer reads from
  `/dashboard` which groups by status, not priority).
- Project Tasks tab uses a new `TaskCard` (icon + status + priority chip).
- Attendance screens (staff + admin) use Material 3 styling.

### Flutter files changed

| File | Purpose |
|---|---|
| `lib/features/dashboard/view/dashboard_screen.dart` | Admin/staff branching, attendance button, ticket priority widget |
| `lib/features/dashboard/controller/dashboard_controller.dart` | `_hydrateScopedTicketStats()` — parses `/tickets` per-priority |
| `lib/features/task/widget/task_card.dart` | New card design |
| `lib/features/task/widget/task_kanban.dart` | Updated colours |
| `lib/features/estimate/view/estimate_details_screen.dart` | Layout updates |
| `lib/features/estimate/widget/estimate_kanban.dart` | Updated colours |
| `lib/features/proposal/view/proposal_details_screen.dart` | Layout updates |
| `lib/features/profile/view/notification_settings_screen.dart` | Updated switch widget |

---

## 2. Attendance System (NEW)

Staff can check in / out with GPS + reverse-geocoded address. Admins get a
view-only screen showing all staff records and location updates by date.

### Behaviour

- **Staff dashboard** shows `Check In` / `Check Out` buttons with a state
  machine (no record → can check in → can check out → done).
- **Admin dashboard** shows `View Attendance` button → opens a 2-tab screen
  (Attendance records + Location Updates) with date picker and pull-to-refresh.
- GPS acquisition tries High → Medium → Low accuracy with 20s timeouts and
  falls back to last-known position (handles indoor / weak-signal scenarios).
- HTTP requests have a 60s timeout to prevent indefinite hangs.

### Flutter files (new)

| File | Purpose |
|---|---|
| `lib/features/attendance/controller/admin_attendance_controller.dart` | Admin: load all staff records + location updates by date |
| `lib/features/attendance/view/admin_attendance_screen.dart` | Admin tabbed view |

### Flutter files (modified)

| File | Change |
|---|---|
| `lib/features/attendance/controller/attendance_controller.dart` | Resilient GPS acquisition (high→med→low fallback, last-known fallback) |
| `lib/features/attendance/model/attendance_model.dart` | Added `firstname`, `lastname`, `email`, `staffFullName` getter |
| `lib/features/attendance/model/location_model.dart` | Added `firstname`, `lastname`, `staffFullName` |
| `lib/features/attendance/repo/attendance_repo.dart` | New methods: `getAllAttendanceRecords()`, `getAllLocationRecords()`, `getAttendanceReport()` |
| `lib/core/route/route.dart` | Added `adminAttendanceScreen` route |
| `lib/core/service/api_service.dart` | 60s request timeout, `TimeoutException` handling, debug body trimmed to 4000 chars |
| `lib/features/dashboard/view/dashboard_screen.dart` | `isAdminLike` detection, admin "View Attendance" button, `Get.lazyPut(AttendanceController)` so admins don't auto-fire `/attendance/today` |

### Server files (PHP) – upload to live server

Path on server: `/public_html/perfex_crm/modules/flutex_admin_api/controllers/`

| File | Purpose |
|---|---|
| `Attendance.php` | All attendance endpoints — staff check-in/out, history, location updates, plus admin-only `records_get`, `location_records_get`, `report_get` |
| `routes.php` | Adds attendance routes (see route list below) |

### SQL migration – run once on live DB

| File | Purpose |
|---|---|
| `ATTENDANCE_MIGRATION_TBL.sql` | Creates `tblstaff_attendance_records` + `tblstaff_location_updates` tables |

> The PHP controller will auto-create the tables on first request as a
> safety net, but running the SQL manually is recommended.

### Endpoints added

| Method | URL | Who |
|---|---|---|
| GET  | `/attendance/today` | Staff |
| POST | `/attendance/checkin` | Staff |
| POST | `/attendance/checkout` | Staff |
| GET  | `/attendance/history?date=&limit=` | Staff |
| POST | `/attendance/location` | Staff |
| GET  | `/attendance/location_history?date=` | Staff |
| GET  | `/attendance/records?date=&staff_id=` | Admin |
| GET  | `/attendance/location_records?date=&staff_id=` | Admin |
| GET  | `/attendance/report?from=&to=&staff_id=` | Admin |

### Important server-side notes

- The constructor of `Attendance.php` previously had a blanket `is_admin()`
  block returning 403 for all admin requests. **Removed.** Admin-blocking is
  now per-method via a private `blockAdmin()` helper that runs ONLY inside
  staff endpoints. Admin endpoints (`records_get`, `location_records_get`,
  `report_get`) keep their existing `is_admin()` checks.
- `checkin_post` now reports the actual MySQL error if the insert fails.
- `checkout_post` now falls back to the most recent open check-in within the
  last 36 hours when the exact `attendance_date` lookup fails (handles server
  vs. device timezone mismatches that previously caused
  *"No check-in found for today"* errors).
- Both write endpoints return `status: true` in the JSON body on success.

---

## 3. Project Tasks – Add Task Fix + Web Features Parity

Adding a task from inside Project → Tasks tab now correctly attaches the new
task to the project (previously the task was created but had no `rel_type` /
`rel_id` so it never appeared inside the project, only in the global tasks
list).

### Root cause

Perfex's `tasks_model->add()` was dropping the `rel_type` / `rel_id` columns
when called from the API (it relies on web-admin form helpers). The Flutter
side also wasn't preserving the project preset across screen rebuilds.

### Flutter files changed

| File | Change |
|---|---|
| `lib/features/project/section/tasks.dart` | `_openAddTask()` now passes `rel_type` / `rel_id` via `Get.toNamed(arguments: ...)` and refreshes after return |
| `lib/features/task/view/add_task_screen.dart` | New `initState()` re-asserts the preset rel values from route arguments after first frame |
| `lib/features/project/controller/project_controller.dart` | Existing `loadProjectGroup()` (no change to logic, verified parses correctly) |

### Server file changed

`flutex_admin_api/controllers/Tasks.php` — in `tasks_post()`, after
`tasks_model->add()` succeeds, force-update the new task's `rel_type` and
`rel_id` columns from the POST body. The response now also returns the
created task's `id`.

```php
// After $success = $this->tasks_model->add($data);
$relType = $this->input->post('rel_type');
$relId   = $this->input->post('rel_id');
if (!empty($relType) && !empty($relId)) {
    $this->db->where('id', (int) $success);
    $this->db->update(db_prefix() . 'tasks', [
        'rel_type' => $relType,
        'rel_id'   => (int) $relId,
    ]);
}
```

### Other project-level web features added

| File | Purpose |
|---|---|
| `flutex_admin_api/controllers/Projects.php` | Project group endpoint with `available_features` fallback (treats missing settings as enabled, prevents spurious 403s on legacy projects) |
| `flutex_admin_api/controllers/Invoices.php` | Project invoices listing |
| `flutex_admin_api/controllers/Estimates.php` | Project estimates listing |
| `flutex_admin_api/controllers/Proposals.php` | Project proposals listing |
| `flutex_admin_api/controllers/Invoice_extras.php` | Extra invoice fields |
| `flutex_admin_api/controllers/Estimates_extras.php` | Extra estimate fields |
| `flutex_admin_api/controllers/Proposals_extras.php` | Extra proposal fields |
| `flutex_admin_api/controllers/Contracts_extras.php` | Extra contract fields |
| `flutex_admin_api/controllers/Customers_extras.php` | Extra customer fields |
| `flutex_admin_api/controllers/Customer_attachments.php` | Customer file uploads |
| `flutex_admin_api/controllers/Settings_extras.php` | Settings endpoints |
| `flutex_admin_api/controllers/Generic.php` | Misc shared endpoints |

---

## 4. Tickets – Assign Option + Spam Filters

Admins can now assign a ticket to a staff member from the ticket detail page.

### Flutter changes

`lib/features/ticket/**` — assign UI already in place, hits the new endpoint.

### Server files

| File | Purpose |
|---|---|
| `flutex_admin_api/controllers/Tickets_spam_filters.php` | Spam filter management |
| Updated `Tickets.php` (in main controller folder) | Added `assign_post` endpoint |

---

## Deployment Checklist

### Flutter app

1. Clone the repo:
   ```powershell
   git clone https://github.com/quietcod/sunrise_app_admin.git
   cd sunrise_app_admin
   ```
2. `flutter pub get`
3. Create `android/key.properties` with your existing upload keystore:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=YOUR_ALIAS
   storeFile=C:/path/to/your/upload-keystore.jks
   ```
   > `key.properties` and `*.jks` are gitignored — never commit them.
4. Build:
   ```powershell
   flutter build appbundle --release   # Play Store
   # or
   flutter build apk --release          # Direct distribution
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

### Server (Perfex)

1. Upload all PHP files in `server_files/` to:
   `/public_html/perfex_crm/modules/flutex_admin_api/controllers/`
2. Append the new routes from `server_files/routes.php` (or `ATTENDANCE_ROUTES.php`) into the
   live `flutex_admin_api/config/routes.php` — do NOT overwrite the whole file
   blindly; merge route lines.
3. Run `server_files/ATTENDANCE_MIGRATION_TBL.sql` on the live database (uses
   `tbl` prefix). If your DB uses a different prefix, use
   `ATTENDANCE_MIGRATION.sql` and adjust accordingly.
4. Clear Perfex cache (Setup → Tools → Clear cache) if available.

### Smoke tests after deploy

| Test | Expected |
|---|---|
| Login as admin → Dashboard | "View Attendance" button appears (NOT Check-In) |
| Admin → View Attendance → pick yesterday | Shows all staff who checked in yesterday |
| Login as staff → Dashboard | Check-In button appears |
| Staff → Check-In | Returns success, row appears in `tblstaff_attendance_records` |
| Staff → Check-Out (same session) | Returns success, `check_out_time` populated |
| Project → Tasks → Add Task | New task appears immediately on the project's Tasks tab |
| Tickets list | Priority counts (Low/Medium/High) show real numbers, not 0 |
| Any list page (Tickets, Projects, Tasks) | Loads within 60 seconds; no infinite spinner |

---

## Known transitive package holdbacks

13 transitive dependencies cannot be upgraded yet because direct deps
(`geocoding ^4.0.0`, `flutter_widget_from_html ^0.17.1`, `file_picker ^11.0.2`)
pin them to older majors. This is the latest reachable state. Bumping them
requires upstream releases.

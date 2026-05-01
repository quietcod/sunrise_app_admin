import 'package:get/get.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';

/// Centralised permission gate for the Admin Tools modules.
///
/// Rules:
///   * If the staff payload is not loaded yet OR the user is an admin
///     (`is_admin == true`), every check returns `true` — this keeps
///     existing admin behaviour intact during rollout.
///   * Otherwise the specific flag from `staff_permissions` is honoured.
///   * Modules whose flag is `null` (server hasn't sent it) default to
///     `false` for non-admins so we fail closed for new modules.
class MyPermissions {
  MyPermissions._();

  static StaffPermissions? get _perm {
    if (!Get.isRegistered<DashboardController>()) return null;
    return Get.find<DashboardController>().homeModel.staffPermissions;
  }

  static bool get isAdmin => _perm?.isAdmin == true;

  /// Treat the user as fully privileged when:
  ///   - the dashboard hasn't been fetched yet (null perm) — first launch
  ///     of an existing admin install before the new payload arrives, OR
  ///   - `is_admin` is explicitly true.
  static bool get _allowAll => _perm == null || isAdmin;

  static bool _check(bool? flag) => _allowAll || flag == true;

  // ── Settings hub (admin-only modules) ──────────────────────────────────────
  static bool get canManageSettings => _check(_perm?.canManageSettings);

  // ── Knowledge Base ─────────────────────────────────────────────────────────
  static bool get canViewKb => _check(_perm?.kbView);
  static bool get canCreateKb => _check(_perm?.kbCreate);
  static bool get canEditKb => _check(_perm?.kbEdit);
  static bool get canDeleteKb => _check(_perm?.kbDelete);

  // ── Subscriptions ──────────────────────────────────────────────────────────
  static bool get canViewSubscriptions => _check(_perm?.subscriptionsView);
  static bool get canCreateSubscriptions => _check(_perm?.subscriptionsCreate);
  static bool get canEditSubscriptions => _check(_perm?.subscriptionsEdit);
  static bool get canDeleteSubscriptions => _check(_perm?.subscriptionsDelete);

  // ── Reports (read-only module) ─────────────────────────────────────────────
  static bool get canViewReports => _check(_perm?.reportsView);

  // ── Calendar ───────────────────────────────────────────────────────────────
  static bool get canViewCalendar => _check(_perm?.calendarView);
  static bool get canCreateCalendar => _check(_perm?.calendarCreate);
  static bool get canEditCalendar => _check(_perm?.calendarEdit);
  static bool get canDeleteCalendar => _check(_perm?.calendarDelete);

  // ── Newsfeed ───────────────────────────────────────────────────────────────
  static bool get canViewNewsfeed => _check(_perm?.newsfeedView);
  static bool get canCreateNewsfeed => _check(_perm?.newsfeedCreate);
  static bool get canDeleteNewsfeed => _check(_perm?.newsfeedDelete);

  // ── GDPR (admin-only module) ───────────────────────────────────────────────
  static bool get canViewGdpr => _check(_perm?.gdprView);
  static bool get canManageGdpr => _check(_perm?.gdprManage);

  // ── Estimate Requests ──────────────────────────────────────────────────────
  static bool get canViewEstimateRequests =>
      _check(_perm?.estimateRequestsView);
  static bool get canEditEstimateRequests =>
      _check(_perm?.estimateRequestsEdit);
  static bool get canDeleteEstimateRequests =>
      _check(_perm?.estimateRequestsDelete);
}

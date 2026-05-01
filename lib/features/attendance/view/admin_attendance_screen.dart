import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/admin_attendance_controller.dart';
import 'package:flutex_admin/features/attendance/model/attendance_model.dart';
import 'package:flutex_admin/features/attendance/model/location_model.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';

/// Admin-only screen: shows all staff attendance + location updates for a
/// chosen date. Reached from the dashboard "View Attendance" button.
class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(sharedPreferences: Get.find()));
    }
    if (!Get.isRegistered<AttendanceRepo>()) {
      Get.put(AttendanceRepo(apiClient: Get.find()));
    }
    if (!Get.isRegistered<AdminAttendanceController>()) {
      Get.put(AdminAttendanceController(attendanceRepo: Get.find()));
    } else {
      // Refresh on re-entry.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Get.find<AdminAttendanceController>().loadAll());
    }

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
      BuildContext context, AdminAttendanceController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      await controller.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminAttendanceController>(builder: (c) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFEFF3F8),
        appBar: AppBar(
          title: Text('Staff Attendance', style: semiBoldLarge),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Pick date',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _pickDate(context, c),
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: c.loadAll,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space15, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.event,
                          size: 18, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 6),
                      Text('Date: ${c.headerDateLabel}',
                          style: semiBoldDefault),
                      const Spacer(),
                      Text(
                        'Staff: ${c.attendanceRecords.length}',
                        style: regularDefault.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.bodyMedium!.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Attendance', icon: Icon(Icons.people_outline)),
                    Tab(
                        text: 'Location Updates',
                        icon: Icon(Icons.location_on_outlined)),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _AttendanceTab(controller: c),
            _LocationsTab(controller: c),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTENDANCE TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceTab extends StatelessWidget {
  final AdminAttendanceController controller;
  const _AttendanceTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingAttendance) return const CustomLoader();
    if (controller.attendanceRecords.isEmpty) {
      return _EmptyState(
        icon: Icons.people_alt_outlined,
        message: 'No attendance records for this date',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadAttendanceRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.space15),
        itemCount: controller.attendanceRecords.length,
        itemBuilder: (ctx, i) => _StaffAttendanceTile(
          record: controller.attendanceRecords[i],
          controller: controller,
        ),
      ),
    );
  }
}

class _StaffAttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  final AdminAttendanceController controller;
  const _StaffAttendanceTile({required this.record, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCheckOut = record.checkOutTime != null;
    final initials = _initials(record.staffFullName);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space10),
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.15),
                child: Text(initials,
                    style: semiBoldDefault.copyWith(
                        color: Theme.of(context).primaryColor, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.staffFullName, style: semiBoldDefault),
                    if (record.email != null && record.email!.isNotEmpty)
                      Text(record.email!,
                          style: regularSmall.copyWith(
                              color: Colors.grey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasCheckOut ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasCheckOut ? 'Complete' : 'Active',
                  style: regularSmall.copyWith(
                      color: hasCheckOut ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space12),
          Row(
            children: [
              _TimePill(
                  label: 'In',
                  time: controller.formatTime(record.checkInTime),
                  color: Colors.green),
              const SizedBox(width: Dimensions.space10),
              _TimePill(
                  label: 'Out',
                  time: hasCheckOut
                      ? controller.formatTime(record.checkOutTime)
                      : '--:--:--',
                  color: hasCheckOut ? Colors.orange : Colors.grey),
              const Spacer(),
              _TimePill(
                  label: 'Duration',
                  time: record.formattedDuration,
                  color: Theme.of(context).primaryColor),
            ],
          ),
          if (record.checkInAddress != null &&
              record.checkInAddress!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.space8),
            _AddressLine(icon: Icons.login, label: record.checkInAddress!),
          ],
          if (record.checkOutAddress != null &&
              record.checkOutAddress!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _AddressLine(icon: Icons.logout, label: record.checkOutAddress!),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION UPDATES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _LocationsTab extends StatelessWidget {
  final AdminAttendanceController controller;
  const _LocationsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingLocations) return const CustomLoader();
    if (controller.locationRecords.isEmpty) {
      return _EmptyState(
        icon: Icons.location_off_outlined,
        message: 'No location updates for this date',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadLocationRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.space15),
        itemCount: controller.locationRecords.length,
        itemBuilder: (ctx, i) =>
            _LocationTile(item: controller.locationRecords[i]),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationUpdate item;
  const _LocationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space10),
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined,
                  size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 6),
              Expanded(child: Text(item.staffFullName, style: semiBoldDefault)),
              if (item.updateTime != null && item.updateTime!.isNotEmpty)
                Text(item.updateTime!,
                    style: regularSmall.copyWith(color: Colors.grey)),
            ],
          ),
          if (item.activityNote != null && item.activityNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(item.activityNote!, style: regularDefault),
          ],
          if (item.address != null && item.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _AddressLine(
                icon: Icons.location_on_outlined, label: item.address!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TimePill extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  const _TimePill(
      {required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                regularSmall.copyWith(color: Colors.grey[500], fontSize: 11)),
        Text(time, style: semiBoldDefault.copyWith(color: color, fontSize: 15)),
      ],
    );
  }
}

class _AddressLine extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AddressLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(label,
              style: regularSmall.copyWith(color: Colors.grey[500]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Wrap in scrollable so RefreshIndicator works on empty state too.
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(message,
                    style: regularDefault.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

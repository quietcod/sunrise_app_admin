import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/attendance_controller.dart';
import 'package:flutex_admin/features/attendance/model/attendance_model.dart';
import 'package:flutex_admin/features/attendance/model/location_model.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';

class AttendanceRecordsScreen extends StatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  State<AttendanceRecordsScreen> createState() =>
      _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Reuse controller if already registered (e.g. from AttendanceScreen)
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(sharedPreferences: Get.find()));
    }
    if (!Get.isRegistered<AttendanceRepo>()) {
      Get.put(AttendanceRepo(apiClient: Get.find()));
    }
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController(attendanceRepo: Get.find()));
    }

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<AttendanceController>();
      c.loadAttendanceHistory();
      c.loadLocationHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(builder: (c) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFEFF3F8),
        appBar: AppBar(
          title: Text('Attendance Records', style: semiBoldLarge),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'History', icon: Icon(Icons.history)),
              Tab(
                  text: 'Location Updates',
                  icon: Icon(Icons.location_on_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _HistoryTab(controller: c),
            _LocationHistoryTab(controller: c),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY TAB
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final AttendanceController controller;
  const _HistoryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingHistory) return const CustomLoader();
    if (controller.attendanceHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No attendance history',
                style: regularDefault.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadAttendanceHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.space15),
        itemCount: controller.attendanceHistory.length,
        itemBuilder: (ctx, i) => _AttendanceTile(
            record: controller.attendanceHistory[i], controller: controller),
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  final AttendanceController controller;
  const _AttendanceTile({required this.record, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCheckOut = record.checkOutTime != null;
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
          // Date row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.formatDate(record.attendanceDate),
                  style: semiBoldDefault.copyWith(
                      color: Theme.of(context).primaryColor, fontSize: 13),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasCheckOut ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasCheckOut ? 'Complete' : 'Incomplete',
                  style: regularSmall.copyWith(
                      color: hasCheckOut ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space12),
          // Times row
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
          // Location snippets
          if (record.checkInAddress != null) ...[
            const SizedBox(height: Dimensions.space8),
            _AddressLine(icon: Icons.login, label: record.checkInAddress!),
          ],
          if (record.checkOutAddress != null) ...[
            const SizedBox(height: 4),
            _AddressLine(icon: Icons.logout, label: record.checkOutAddress!),
          ],
        ],
      ),
    );
  }
}

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION HISTORY TAB
// ─────────────────────────────────────────────────────────────────────────────

class _LocationHistoryTab extends StatelessWidget {
  final AttendanceController controller;
  const _LocationHistoryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingLocationHistory) return const CustomLoader();
    if (controller.locationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No location updates',
                style: regularDefault.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadLocationHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.space15),
        itemCount: controller.locationHistory.length,
        itemBuilder: (ctx, i) => _LocationTile(
            item: controller.locationHistory[i], controller: controller),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationUpdate item;
  final AttendanceController controller;
  const _LocationTile({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space10),
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_outlined,
                color: Theme.of(context).primaryColor, size: 18),
          ),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.activityNote ?? 'No note', style: semiBoldDefault),
                const SizedBox(height: 2),
                Text(item.address ?? 'Unknown location',
                    style: regularSmall.copyWith(color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (item.updateDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.formatDate(item.updateDate),
                    style: regularSmall.copyWith(
                        color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Text(
            controller.formatTime(item.updateTime),
            style: regularSmall.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutex_admin/features/attendance/model/attendance_model.dart';
import 'package:flutex_admin/features/attendance/model/location_model.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';

/// Controller used by the admin "View Attendance" screen.
/// Lists all staff attendance + location updates for a chosen date.
class AdminAttendanceController extends GetxController {
  final AttendanceRepo attendanceRepo;

  AdminAttendanceController({required this.attendanceRepo});

  // Selected date (yyyy-MM-dd) — defaults to today.
  DateTime selectedDate = DateTime.now();
  String? staffIdFilter; // optional filter

  List<AttendanceRecord> attendanceRecords = [];
  List<LocationUpdate> locationRecords = [];

  bool isLoadingAttendance = false;
  bool isLoadingLocations = false;

  String get _formattedSelectedDate {
    final d = selectedDate;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> setDate(DateTime date) async {
    selectedDate = DateTime(date.year, date.month, date.day);
    update();
    await loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadAttendanceRecords(), loadLocationRecords()]);
  }

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> loadAttendanceRecords() async {
    isLoadingAttendance = true;
    update();

    final res = await attendanceRepo.getAllAttendanceRecords(
      date: _formattedSelectedDate,
      staffId: staffIdFilter,
    );
    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      attendanceRecords = AttendanceListModel.fromJson(json).data ?? [];
    } else {
      attendanceRecords = [];
    }

    isLoadingAttendance = false;
    update();
  }

  Future<void> loadLocationRecords() async {
    isLoadingLocations = true;
    update();

    final res = await attendanceRepo.getAllLocationRecords(
      date: _formattedSelectedDate,
      staffId: staffIdFilter,
    );
    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      locationRecords = LocationHistoryModel.fromJson(json).data ?? [];
    } else {
      locationRecords = [];
    }

    isLoadingLocations = false;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers (mirrors AttendanceController helpers)
  // ─────────────────────────────────────────────────────────────────────────

  String formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '--:--:--';
    try {
      final dt = DateTime.parse(dateTime);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    } catch (_) {
      return '--:--:--';
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  String get headerDateLabel {
    final d = selectedDate;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}

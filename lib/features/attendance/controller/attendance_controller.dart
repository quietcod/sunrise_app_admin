import 'dart:convert';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/features/attendance/model/attendance_model.dart';
import 'package:flutex_admin/features/attendance/model/location_model.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';

class AttendanceController extends GetxController {
  final AttendanceRepo attendanceRepo;

  AttendanceController({required this.attendanceRepo});

  // ─────────────────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────────────────

  // Attendance
  AttendanceRecord? todayAttendance;
  List<AttendanceRecord> attendanceHistory = [];

  // Location
  List<LocationUpdate> locationHistory = [];

  // Current location
  Position? currentPosition;
  String currentAddress = 'Fetching location…';

  // UI State
  bool isLoadingAttendance = true;
  bool isLoadingHistory = false;
  bool isLoadingLocationHistory = false;
  bool isCheckingIn = false;
  bool isCheckingOut = false;
  bool isSubmittingLocation = false;

  @override
  void onInit() {
    super.onInit();
    getTodayAttendance();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  bool _isReliableCachedPosition(Position position, {int maxAgeMinutes = 2}) {
    final timestamp = position.timestamp;
    final age = DateTime.now().difference(timestamp).inMinutes.abs();
    if (age > maxAgeMinutes) return false;

    return position.accuracy <= 100;
  }

  void _storePosition(Position position) {
    currentPosition = position;
    currentAddress =
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
    // ignore: unawaited_futures
    _reverseGeocode(position.latitude, position.longitude);
  }

  Future<Position?> _getCurrentPosition({bool allowCached = false}) async {
    try {
      // 1. Ensure location services are on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.error(
            errorList: ['Location services are disabled. Please enable GPS.']);
        return null;
      }

      // 2. Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        CustomSnackBar.error(errorList: ['Location permission denied.']);
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        CustomSnackBar.error(errorList: [
          'Location permission permanently denied. Enable it in app settings.'
        ]);
        await Geolocator.openAppSettings();
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (allowCached &&
          lastKnown != null &&
          _isReliableCachedPosition(lastKnown)) {
        _storePosition(lastKnown);
        return lastKnown;
      }

      Position? position;
      // Try high → medium → low accuracy in sequence so we get *something*
      // even when GPS satellites aren't immediately visible (indoors, etc.).
      for (final accuracy in const [
        LocationAccuracy.high,
        LocationAccuracy.medium,
        LocationAccuracy.low,
      ]) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: accuracy,
              timeLimit: const Duration(seconds: 20),
            ),
          ).timeout(const Duration(seconds: 22));
          break;
        } catch (_) {
          // try next accuracy level
        }
      }

      // Last resort: any cached fix, even older / less accurate.
      if (position == null && lastKnown != null) {
        position = lastKnown;
      }

      if (position == null) {
        CustomSnackBar.error(errorList: [
          'Could not get a fresh GPS fix. Please wait a moment and try again.'
        ]);
        return null;
      }

      _storePosition(position);
      return position;
    } catch (e) {
      CustomSnackBar.error(errorList: ['Failed to get location: $e']);
      return null;
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await geo
          .placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .toList();
        currentAddress = parts.isNotEmpty
            ? parts.join(', ')
            : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      } else {
        currentAddress = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
    } catch (_) {
      currentAddress = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
    update();
  }

  /// Safely decode a JSON response. Returns null when the body isn't JSON
  /// (e.g. server returned an HTML 404/500 page).
  Map<String, dynamic>? _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ATTENDANCE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getTodayAttendance() async {
    isLoadingAttendance = true;
    update();

    final res = await attendanceRepo.getTodayAttendance();
    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      todayAttendance =
          json['data'] != null ? AttendanceRecord.fromJson(json['data']) : null;
    }

    isLoadingAttendance = false;
    update();
  }

  Future<void> performCheckIn() async {
    // ── OPTIMISTIC UI ────────────────────────────────────────────────────
    // Flip the button immediately so the user perceives instant action.
    final previousAttendance = todayAttendance;
    final nowIso = DateTime.now().toIso8601String();
    todayAttendance = AttendanceRecord(
      attendanceDate: DateTime.now().toIso8601String().substring(0, 10),
      checkInTime: nowIso,
    );
    isCheckingIn = false; // not loading — already "done" from user's POV
    update();
    CustomSnackBar.success(successList: ['Checked in']);

    // ── BACKGROUND WORK ──────────────────────────────────────────────────
    // Fetch location + call API without blocking the UI.
    // This keeps running even if the user minimizes the app.
    // ignore: unawaited_futures
    _doCheckInBackground(previousAttendance);
  }

  Future<void> _doCheckInBackground(AttendanceRecord? previous) async {
    final position = await _getCurrentPosition();
    if (position == null) {
      // Roll back optimistic state
      todayAttendance = previous;
      update();
      return;
    }

    final res = await attendanceRepo.checkIn(
      latitude: position.latitude,
      longitude: position.longitude,
      address: currentAddress,
    );

    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      // Replace optimistic record with the real one from the server
      if (json['data'] != null) {
        todayAttendance = AttendanceRecord.fromJson(json['data']);
        update();
      }
    } else {
      // Roll back and show error
      todayAttendance = previous;
      update();
      CustomSnackBar.error(errorList: [
        json?['message']?.toString() ?? 'Check-in failed. Please try again.'
      ]);
    }
  }

  Future<void> performCheckOut() async {
    if (todayAttendance == null) return;

    // ── OPTIMISTIC UI ────────────────────────────────────────────────────
    final previousAttendance = todayAttendance;
    final nowIso = DateTime.now().toIso8601String();
    todayAttendance = AttendanceRecord(
      id: previousAttendance!.id,
      staffId: previousAttendance.staffId,
      attendanceDate: previousAttendance.attendanceDate,
      checkInTime: previousAttendance.checkInTime,
      checkInAddress: previousAttendance.checkInAddress,
      checkOutTime: nowIso,
    );
    isCheckingOut = false;
    update();
    CustomSnackBar.success(successList: ['Checked out']);

    // ── BACKGROUND WORK ──────────────────────────────────────────────────
    // ignore: unawaited_futures
    _doCheckOutBackground(previousAttendance);
  }

  Future<void> _doCheckOutBackground(AttendanceRecord previous) async {
    final position = await _getCurrentPosition();
    if (position == null) {
      todayAttendance = previous;
      update();
      return;
    }

    final res = await attendanceRepo.checkOut(
      latitude: position.latitude,
      longitude: position.longitude,
      address: currentAddress,
    );

    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      if (json['data'] != null) {
        todayAttendance = AttendanceRecord.fromJson(json['data']);
        update();
      }
    } else {
      todayAttendance = previous;
      update();
      CustomSnackBar.error(errorList: [
        json?['message']?.toString() ?? 'Check-out failed. Please try again.'
      ]);
    }
  }

  Future<void> loadAttendanceHistory() async {
    isLoadingHistory = true;
    update();

    final res = await attendanceRepo.getAttendanceHistory();
    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      attendanceHistory = AttendanceListModel.fromJson(json).data ?? [];
    }

    isLoadingHistory = false;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION TRACKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> submitLocationUpdate(String activityNote) async {
    if (activityNote.trim().isEmpty) {
      CustomSnackBar.error(errorList: ['Please enter an activity note']);
      return;
    }

    isSubmittingLocation = true;
    update();

    // Get current location
    final position = await _getCurrentPosition();
    if (position == null) {
      isSubmittingLocation = false;
      update();
      return;
    }

    // Call API
    final res = await attendanceRepo.submitLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: currentAddress,
      activityNote: activityNote.trim(),
    );

    if (res.status) {
      CustomSnackBar.success(successList: ['Location submitted']);
      await loadLocationHistory();
    } else {
      final json = _safeDecode(res.responseJson);
      CustomSnackBar.error(errorList: [
        json?['message']?.toString() ?? 'Failed to submit location'
      ]);
    }
    isSubmittingLocation = false;
    update();
  }

  Future<void> loadLocationHistory() async {
    isLoadingLocationHistory = true;
    update();

    final res = await attendanceRepo.getLocationHistory();
    final json = _safeDecode(res.responseJson);
    if (res.status && json != null) {
      locationHistory = LocationHistoryModel.fromJson(json).data ?? [];
    }

    isLoadingLocationHistory = false;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String formatTime(String? dateTime) {
    if (dateTime == null) return '--:--:--';
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
    if (date == null) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }
}

import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class AttendanceRepo {
  final ApiClient apiClient;
  AttendanceRepo({required this.apiClient});

  // ─────────────────────────────────────────────────────────────────────────
  // ATTENDANCE ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────

  Future<ResponseModel> getTodayAttendance() {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceTodayUrl}',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> checkIn({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceCheckinUrl}',
      Method.postMethod,
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> checkOut({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceCheckoutUrl}',
      Method.postMethod,
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> getAttendanceHistory({String? date, int limit = 30}) {
    final q = [
      if (date != null) 'date=$date',
      'limit=$limit',
    ].join('&');
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceHistoryUrl}?$q',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCATION TRACKING ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────

  Future<ResponseModel> submitLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String activityNote,
  }) {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceLocationUrl}',
      Method.postMethod,
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
        'activity_note': activityNote,
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> getLocationHistory({String? date}) {
    final q = date != null ? '?date=$date' : '';
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceLocationHistoryUrl}$q',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN ENDPOINTS (require is_admin on server)
  // ─────────────────────────────────────────────────────────────────────────

  Future<ResponseModel> getAllAttendanceRecords({
    String? date,
    String? staffId,
  }) {
    final params = <String>[
      if (date != null && date.isNotEmpty) 'date=$date',
      if (staffId != null && staffId.isNotEmpty) 'staff_id=$staffId',
    ];
    final q = params.isEmpty ? '' : '?${params.join('&')}';
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceRecordsUrl}$q',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> getAllLocationRecords({
    String? date,
    String? staffId,
  }) {
    final params = <String>[
      if (date != null && date.isNotEmpty) 'date=$date',
      if (staffId != null && staffId.isNotEmpty) 'staff_id=$staffId',
    ];
    final q = params.isEmpty ? '' : '?${params.join('&')}';
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceLocationRecordsUrl}$q',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> getAttendanceReport({
    required String fromDate,
    required String toDate,
    String? staffId,
  }) {
    final params = <String>[
      'from_date=$fromDate',
      'to_date=$toDate',
      if (staffId != null && staffId.isNotEmpty) 'staff_id=$staffId',
    ];
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.attendanceReportUrl}?${params.join('&')}',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }
}

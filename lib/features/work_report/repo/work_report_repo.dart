import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class WorkReportRepo {
  ApiClient apiClient;
  WorkReportRepo({required this.apiClient});

  Future<ResponseModel> getReports({
    String? staffId,
    String? date,
  }) async {
    final params = <String>[];
    if (staffId != null && staffId.isNotEmpty) params.add('staff_id=$staffId');
    if (date != null && date.isNotEmpty) params.add('date=$date');
    final q = params.isNotEmpty ? '?${params.join('&')}' : '';
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportsUrl}$q',
        Method.getMethod,
        null,
        passHeader: true);
  }

  /// Admin-only: latest report per staff member.
  Future<ResponseModel> getLatestPerStaff() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportsUrl}?latest=1',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getReportById(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportsUrl}?id=$id',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> submitReport(Map<String, dynamic> data) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportsUrl}',
        Method.postMethod,
        data,
        passHeader: true);
  }

  Future<ResponseModel> deleteReport(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> postReply(String reportId, String message) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.workReportRepliesUrl}',
        Method.postMethod,
        {'report_id': reportId, 'message': message},
        passHeader: true);
  }

  Future<ResponseModel> getStaffList() async {
    return apiClient.request('${UrlContainer.baseUrl}${UrlContainer.staffUrl}',
        Method.getMethod, null,
        passHeader: true);
  }
}

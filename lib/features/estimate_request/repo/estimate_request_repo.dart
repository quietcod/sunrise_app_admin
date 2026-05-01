import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class EstimateRequestRepo {
  ApiClient apiClient;
  EstimateRequestRepo({required this.apiClient});

  Future<ResponseModel> getRequests({String? status}) async {
    final q = status != null ? '?status=$status' : '';
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.estimateRequestsUrl}$q',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> updateStatus(String id, String status) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.estimateRequestStatusUrl}?id=$id',
        Method.putMethod,
        {'status': status},
        passHeader: true);
  }

  Future<ResponseModel> assignStaff(String id, String staffId) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.estimateRequestAssignUrl}?id=$id',
        Method.putMethod,
        {'staff_id': staffId},
        passHeader: true);
  }

  Future<ResponseModel> convertToEstimate(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.estimateRequestConvertUrl}?id=$id',
        Method.postMethod,
        {},
        passHeader: true);
  }

  Future<ResponseModel> deleteRequest(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.estimateRequestsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }
}

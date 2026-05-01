import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class GdprRepo {
  ApiClient apiClient;
  GdprRepo({required this.apiClient});

  Future<ResponseModel> getPurposes() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.gdprPurposesUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addPurpose(Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.gdprPurposesUrl}',
        Method.postMethod,
        p,
        passHeader: true);
  }

  Future<ResponseModel> deletePurpose(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.gdprPurposesUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getRemovalRequests() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.gdprRemovalRequestsUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> updateRemovalRequest(
      String id, Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.gdprRemovalRequestsUrl}?id=$id',
        Method.putMethod,
        p,
        passHeader: true);
  }
}

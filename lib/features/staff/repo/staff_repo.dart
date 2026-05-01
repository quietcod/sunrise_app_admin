import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class StaffRepo {
  ApiClient apiClient;
  StaffRepo({required this.apiClient});

  Future<ResponseModel> getAllStaff() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getStaffDetails(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}/id/$id';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addStaff(Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}';
    return apiClient.request(url, Method.postMethod, data, passHeader: true);
  }

  Future<ResponseModel> updateStaff(
      String id, Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, data, passHeader: true);
  }

  Future<ResponseModel> changeStaffStatus(String id, String status) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, {'active': status},
        passHeader: true);
  }

  Future<ResponseModel> deleteStaff(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

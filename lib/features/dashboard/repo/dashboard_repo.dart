import 'dart:convert';

import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class DashboardRepo {
  ApiClient apiClient;
  DashboardRepo({required this.apiClient});

  Future<ResponseModel> getData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.dashboardUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> logout() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.logoutUrl}';
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<int> fetchUnreadNotificationCount() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.notificationsUrl}';
    final response =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    if (response.status) {
      try {
        final data = jsonDecode(response.responseJson);
        return (data['unread_count'] as int?) ?? 0;
      } catch (_) {}
    }
    return 0;
  }

  Future<ResponseModel> getTicketsSnapshot() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }
}

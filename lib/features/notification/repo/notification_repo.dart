import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class NotificationRepo {
  ApiClient apiClient;
  NotificationRepo({required this.apiClient});

  Future<ResponseModel> getAllNotifications() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.notificationsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> markNotificationRead(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.markNotificationReadUrl}';
    return apiClient.request(url, Method.postMethod, {'id': id},
        passHeader: true);
  }

  Future<ResponseModel> markAllNotificationsRead() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.markAllNotificationsReadUrl}';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }
}

import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class SubscriptionRepo {
  ApiClient apiClient;
  SubscriptionRepo({required this.apiClient});

  Future<ResponseModel> getSubscriptions() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.subscriptionsUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getSubscription(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.subscriptionsUrl}?id=$id',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> cancelSubscription(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.subscriptionCancelUrl}?id=$id',
        Method.postMethod,
        {},
        passHeader: true);
  }

  Future<ResponseModel> deleteSubscription(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.subscriptionsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }
}

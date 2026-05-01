import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class CalendarRepo {
  ApiClient apiClient;
  CalendarRepo({required this.apiClient});

  Future<ResponseModel> getEvents({String? start, String? end}) async {
    final params = <String>[];
    if (start != null) params.add('start=$start');
    if (end != null) params.add('end=$end');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.calendarEventsUrl}$query',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addEvent(Map<String, dynamic> params) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.calendarEventsUrl}',
        Method.postMethod,
        params,
        passHeader: true);
  }

  Future<ResponseModel> updateEvent(
      String id, Map<String, dynamic> params) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.calendarEventsUrl}?id=$id',
        Method.putMethod,
        params,
        passHeader: true);
  }

  Future<ResponseModel> deleteEvent(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.calendarEventsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getUpcoming() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.calendarUpcomingUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }
}

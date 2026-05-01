import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class AnnouncementRepo {
  ApiClient apiClient;
  AnnouncementRepo({required this.apiClient});

  Future<ResponseModel> getAllAnnouncements() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getAnnouncementDetails(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}/id/$id';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> dismissAnnouncement(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}/dismiss';
    return apiClient.request(url, Method.postMethod, {'id': id},
        passHeader: true);
  }

  Future<ResponseModel> addAnnouncement(Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}';
    return apiClient.request(url, Method.postMethod, data, passHeader: true);
  }

  Future<ResponseModel> updateAnnouncement(
      String id, Map<String, dynamic> data) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, data, passHeader: true);
  }

  Future<ResponseModel> deleteAnnouncement(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.announcementsUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

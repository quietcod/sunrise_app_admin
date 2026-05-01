import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class KbRepo {
  ApiClient apiClient;
  KbRepo({required this.apiClient});

  Future<ResponseModel> getGroups() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbGroupsUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addGroup(Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbGroupsUrl}',
        Method.postMethod,
        p,
        passHeader: true);
  }

  Future<ResponseModel> updateGroup(String id, Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbGroupsUrl}/id/$id',
        Method.putMethod,
        p,
        passHeader: true);
  }

  Future<ResponseModel> deleteGroup(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbGroupsUrl}/id/$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getArticles({String? groupId}) async {
    final url = groupId != null
        ? '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}?group_id=$groupId'
        : '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getArticle(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}?id=$id',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addArticle(Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}',
        Method.postMethod,
        p,
        passHeader: true);
  }

  Future<ResponseModel> updateArticle(String id, Map<String, dynamic> p) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}/id/$id',
        Method.putMethod,
        p,
        passHeader: true);
  }

  Future<ResponseModel> deleteArticle(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbArticlesUrl}/id/$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> searchArticles(String q) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.kbArticlesSearchUrl}?q=${Uri.encodeComponent(q)}',
        Method.getMethod,
        null,
        passHeader: true);
  }
}

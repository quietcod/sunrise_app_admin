import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class NewsfeedRepo {
  ApiClient apiClient;
  NewsfeedRepo({required this.apiClient});

  Future<ResponseModel> getPosts({int page = 1}) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedPostsUrl}?page=$page',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> createPost(Map<String, dynamic> params) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedPostsUrl}',
        Method.postMethod,
        params,
        passHeader: true);
  }

  Future<ResponseModel> deletePost(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedPostsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> toggleLike(String postId) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedLikeUrl}?id=$postId',
        Method.postMethod,
        {},
        passHeader: true);
  }

  Future<ResponseModel> getComments(String postId) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedCommentsUrl}?post_id=$postId',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addComment(String postId, String content) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedCommentsUrl}?post_id=$postId',
        Method.postMethod,
        {'content': content},
        passHeader: true);
  }

  Future<ResponseModel> deleteComment(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.newsfeedCommentsUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }
}

import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class TodoRepo {
  ApiClient apiClient;
  TodoRepo({required this.apiClient});

  Future<ResponseModel> getAllTodos() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addTodo(String description) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}';
    return apiClient.request(
        url, Method.postMethod, {'description': description},
        passHeader: true);
  }

  Future<ResponseModel> toggleTodoDone(String id, bool finished) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}/id/$id';
    return apiClient.request(
        url, Method.putMethod, {'finished': finished ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> updateTodoDescription(
      String id, String description) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}/id/$id';
    return apiClient.request(
        url, Method.putMethod, {'description': description},
        passHeader: true);
  }

  Future<ResponseModel> deleteTodo(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> reorderTodo(String id, int newOrder) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.todosUrl}/reorder/$id';
    return apiClient.request(
        url, Method.putMethod, {'item_order': newOrder.toString()},
        passHeader: true);
  }
}

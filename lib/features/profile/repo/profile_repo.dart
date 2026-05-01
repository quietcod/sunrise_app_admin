import 'dart:io';

import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:http/http.dart' as http;

class ProfileRepo {
  ApiClient apiClient;
  ProfileRepo({required this.apiClient});

  Future<ResponseModel> getData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.profileUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> updateProfile(Map<String, dynamic> data) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.profileUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.putMethod, data, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> changePassword(Map<String, dynamic> data) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.changePasswordUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.postMethod, data, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> uploadProfilePicture(File imageFile) async {
    try {
      apiClient.initToken();
      final url = Uri.parse(
          '${UrlContainer.baseUrl}${UrlContainer.profileUrl}/upload_profile_image');
      final request = http.MultipartRequest('POST', url)
        ..headers['X-Authorization'] = apiClient.token
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
        ));
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        return ResponseModel(true, 'Profile picture updated', body);
      } else {
        return ResponseModel(false, 'Failed to upload profile picture', body);
      }
    } catch (e) {
      return ResponseModel(false, e.toString(), '');
    }
  }

  Future<ResponseModel> removeProfilePicture() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.profileUrl}/remove_profile_image';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> getMyTimesheets() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.profileTimesheetsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }
}

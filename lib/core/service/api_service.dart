import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/method.dart';

class ApiClient extends GetxService {
  SharedPreferences sharedPreferences;
  ApiClient({required this.sharedPreferences});

  Map<String, dynamic>? _redactParams(Map<String, dynamic>? params) {
    if (params == null) {
      return null;
    }

    const sensitiveKeys = {
      'password',
      'pass',
      'pwd',
      'token',
      'access_token',
      'refresh_token',
      'authorization',
    };

    final Map<String, dynamic> copy = <String, dynamic>{};
    params.forEach((key, value) {
      final keyLower = key.toLowerCase();
      if (sensitiveKeys.contains(keyLower)) {
        copy[key] = '***';
      } else if (value is Map<String, dynamic>) {
        copy[key] = _redactParams(value);
      } else {
        copy[key] = value;
      }
    });

    return copy;
  }

  dynamic _tryDecodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeSuccessfulPayload(
      dynamic decodedBody, StatusModel model, String rawBody) {
    // If the body couldn't be decoded as JSON (e.g. PHP HTML error page),
    // treat it as a failure regardless of HTTP status code.
    if (decodedBody == null && rawBody.trim().isNotEmpty) {
      return false;
    }
    if (decodedBody is! Map<String, dynamic>) {
      return model.status ?? true;
    }

    final dynamic rawStatus = decodedBody['status'];
    if (rawStatus is bool) {
      if (rawStatus) {
        return true;
      }

      final message = decodedBody['message']?.toString().toLowerCase() ?? '';
      if (message.contains('successfully') ||
          message.contains('retrieved successfully')) {
        return true;
      }

      return false;
    }

    if (rawStatus is num) {
      return rawStatus != 0;
    }

    if (rawStatus is String) {
      final normalized = rawStatus.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == 'success' ||
          normalized == 'ok') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == 'error' ||
          normalized == 'failed') {
        return false;
      }
    }

    final message = decodedBody['message']?.toString().toLowerCase() ?? '';
    if (message.contains('successfully') ||
        message.contains('retrieved successfully')) {
      return true;
    }

    if (decodedBody.containsKey('id') &&
        !decodedBody.containsKey('errors') &&
        !decodedBody.containsKey('error')) {
      return true;
    }

    return model.status ?? true;
  }

  Future<ResponseModel> request(
      String uri, String method, Map<String, dynamic>? params,
      {bool passHeader = false}) async {
    Uri url = Uri.parse(uri);
    http.Response response;

    // Hard ceiling on every HTTP request so a stuck server cannot freeze
    // the UI indefinitely. Some endpoints (e.g. /tickets, /dashboard) on a
    // shared-hosting backend can legitimately take 20-40s, so the cap is
    // generous; this is only a safety net for true hangs.
    const requestTimeout = Duration(seconds: 60);

    try {
      if (method == Method.postMethod) {
        if (passHeader) {
          initToken();
          response = await http.post(url, body: params, headers: {
            'Accept': 'application/json',
            'X-Authorization': token
          }).timeout(requestTimeout);
        } else {
          response = await http.post(url, body: params).timeout(requestTimeout);
        }
      } else if (method == Method.putMethod) {
        initToken();
        response = await http.put(url, body: params, headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json',
          'X-Authorization': token
        }).timeout(requestTimeout);
      } else if (method == Method.deleteMethod) {
        initToken();
        response = await http.delete(url, headers: {
          'Accept': 'application/json',
          'X-Authorization': token
        }).timeout(requestTimeout);
      } else {
        if (passHeader) {
          initToken();
          response = await http.get(url, headers: {
            'Accept': 'application/json',
            'X-Authorization': token
          }).timeout(requestTimeout);
        } else {
          response = await http.get(url).timeout(requestTimeout);
        }
      }

      if (kDebugMode) {
        // Truncate large bodies — printing huge JSON blobs blocks the UI
        // thread and dramatically slows down debug builds.
        final body = response.body;
        final shortBody = body.length > 4000
            ? '${body.substring(0, 4000)}…(${body.length}b)'
            : body;
        print('====> url: ${uri.toString()}');
        print('====> method: $method');
        print('====> params: ${_redactParams(params).toString()}');
        print('====> status: ${response.statusCode}');
        print('====> body: $shortBody');
        print('====> token: <redacted>');
      }

      // Defensively parse the response body – some error responses (e.g. a
      // CDN/firewall 403) may return HTML instead of JSON. Falling back to an
      // empty StatusModel prevents a spurious FormatException that would
      // otherwise redirect the user to the login screen.
      final decodedBody = _tryDecodeBody(response.body);
      StatusModel model;
      try {
        model = StatusModel.fromJson(decodedBody);
      } catch (_) {
        model = StatusModel(status: null, message: null);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Treat any 2xx (200, 201, 202, 204, ...) as a successful HTTP
        // response. The JSON body's `status` flag is intentionally NOT used to
        // force a logout — a `status:false` payload is a normal
        // validation/permission error that the calling controller should
        // surface to the user via `model.message`.
        final bool jsonOk =
            _looksLikeSuccessfulPayload(decodedBody, model, response.body);
        return ResponseModel(
            jsonOk,
            model.message?.tr ??
                (jsonOk ? '' : LocalStrings.somethingWentWrong.tr),
            response.body);
      } else if (response.statusCode == 401) {
        sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
        Get.offAllNamed(RouteHelper.loginScreen);
        return ResponseModel(
            false,
            model.message?.tr ?? LocalStrings.somethingWentWrong.tr,
            response.body);
      } else if (response.statusCode == 403) {
        return ResponseModel(
            false,
            model.message?.tr ??
                'You do not have permission to view this module.',
            response.body,
            isForbidden: true);
      } else if (response.statusCode == 404) {
        return ResponseModel(
            false,
            model.message?.tr ?? LocalStrings.somethingWentWrong.tr,
            response.body);
      } else if (response.statusCode == 500) {
        return ResponseModel(
            false, model.message?.tr ?? LocalStrings.serverError.tr, '');
      } else {
        return ResponseModel(
            false, model.message?.tr ?? LocalStrings.somethingWentWrong.tr, '');
      }
    } on SocketException {
      return ResponseModel(false, LocalStrings.somethingWentWrong.tr, '');
    } on TimeoutException {
      return ResponseModel(
          false, 'Request timed out. Please check your connection.', '');
    } catch (e) {
      return ResponseModel(false, e.toString(), '');
    }
  }

  String token = '';

  void initToken() {
    if (sharedPreferences.containsKey(SharedPreferenceHelper.accessTokenKey)) {
      String? t =
          sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey);
      token = t ?? '';
    } else {
      token = '';
    }
  }

  Future<ResponseModel> multipartRequest(
      String uri, String filePath, Map<String, String> fields,
      {bool passHeader = false}) async {
    try {
      initToken();
      final request = http.MultipartRequest(Method.postMethod, Uri.parse(uri));
      if (passHeader) {
        request.headers['X-Authorization'] = token;
        request.headers['Accept'] = 'application/json';
      }
      fields.forEach((k, v) => request.fields[k] = v);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        print('====> url: $uri');
        print('====> method: multipart');
        print('====> status: ${response.statusCode}');
        print('====> body: ${response.body}');
      }

      StatusModel model;
      try {
        model = StatusModel.fromJson(jsonDecode(response.body));
      } catch (_) {
        model = StatusModel(status: false, message: null);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bool jsonOk = model.status ?? true;
        return ResponseModel(
            jsonOk,
            model.message?.tr ??
                (jsonOk ? '' : LocalStrings.somethingWentWrong.tr),
            response.body);
      } else {
        return ResponseModel(
            false, model.message?.tr ?? LocalStrings.somethingWentWrong.tr, '');
      }
    } on SocketException {
      return ResponseModel(false, LocalStrings.somethingWentWrong.tr, '');
    } on TimeoutException {
      return ResponseModel(false, 'Upload timed out. Please try again.', '');
    } catch (e) {
      return ResponseModel(false, e.toString(), '');
    }
  }
}

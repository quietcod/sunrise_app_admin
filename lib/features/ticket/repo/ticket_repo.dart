import 'dart:convert';

import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/ticket/model/ticket_create_model.dart';
import 'package:http/http.dart' as http;

class TicketRepo {
  ApiClient apiClient;
  TicketRepo({required this.apiClient});

  Future<ResponseModel> getAllTickets() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getTicketDetails(ticketId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/id/$ticketId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllCustomers() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getCustomerContacts(customerId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contactsUrl}/id/$customerId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getTicketDepartments() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/ticket_departments";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getTicketPriorities() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/ticket_priorities";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getTicketServices() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/ticket_services";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createTicket(TicketCreateModel ticketModel,
      {String? ticketId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}";

    Map<String, dynamic> params = {
      "subject": ticketModel.subject,
      "department": ticketModel.department,
      "priority": ticketModel.priority,
      "service": ticketModel.service,
      "userid": ticketModel.userId,
      "contactid": ticketModel.contactId,
      "message": ticketModel.description,
    };

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$ticketId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteTicket(ticketId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/id/$ticketId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchTicket(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> changeTicketStatus(
      String ticketId, String status) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/id/$ticketId"; // Uses PUT method implicitly via apiClient logic usually, or explicit params
    Map<String, dynamic> params = {
      "ticketid": ticketId,
      "status": status,
    };
    ResponseModel responseModel = await apiClient
        .request(url, Method.putMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> addTicketReply(String ticketId, String message) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/reply/id/$ticketId";
    Map<String, dynamic> params = {
      "message": message,
    };
    ResponseModel responseModel = await apiClient
        .request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> editTicketReply(String replyId, String message) async {
    final url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/reply/id/$replyId";
    return apiClient.request(url, Method.putMethod, {'message': message},
        passHeader: true);
  }

  Future<ResponseModel> deleteTicketReply(String replyId) async {
    final url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/reply/id/$replyId";
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> requestCloseOtp(String ticketId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketCloseRequestOtpUrl}/id/$ticketId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> verifyCloseOtp(String ticketId, String otp) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketCloseVerifyOtpUrl}/id/$ticketId";
    Map<String, dynamic> params = {
      "otp": otp,
    };
    ResponseModel responseModel = await apiClient
        .request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> resendTicketOtp(String ticketId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketCloseResendOtpUrl}/id/$ticketId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> closeTicketWithoutOtp(String ticketId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketCloseWithoutOtpUrl}/id/$ticketId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendOtpToDifferentNumber(
      String ticketId, String phone) async {
    final String url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketSendOtpToNumberUrl}/id/$ticketId";
    final Map<String, dynamic> params = {"phone_number": phone};
    ResponseModel responseModel = await apiClient
        .request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAssignableStaff() async {
    final token = apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.accessTokenKey) ??
        '';
    final urls = <String>[
      '${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/staff_members',
      '${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/staff',
      '${UrlContainer.baseUrl}staff',
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Unable to load staff members', '');

    for (final url in urls) {
      final response = await _safeRequest(
        url: url,
        method: Method.getMethod,
        params: null,
        token: token,
      );
      if (response.status) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse;
  }

  Future<ResponseModel> getStaffById(String staffId) async {
    final token = apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.accessTokenKey) ??
        '';
    final url = "${UrlContainer.baseUrl}staff/id/$staffId";
    return _safeRequest(
      url: url,
      method: Method.getMethod,
      params: null,
      token: token,
    );
  }

  Future<ResponseModel> assignTicketToStaff(
      String ticketId, int staffId) async {
    final token = apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.accessTokenKey) ??
        '';
    final url =
        "${UrlContainer.baseUrl}${UrlContainer.ticketsUrl}/id/$ticketId";
    final paramCandidates = <Map<String, dynamic>>[
      {'assigned': staffId.toString()},
      {'ticketid': ticketId, 'assigned': staffId.toString()},
      {'ticketid': ticketId, 'staffid': staffId.toString()},
      {'ticketid': ticketId, 'assigned_to': staffId.toString()},
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Unable to assign ticket', '');

    for (final params in paramCandidates) {
      final response = await _safeRequest(
        url: url,
        method: Method.putMethod,
        params: params,
        token: token,
      );
      if (response.status) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse;
  }

  Future<ResponseModel> _safeRequest({
    required String url,
    required String method,
    required Map<String, dynamic>? params,
    required String token,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = <String, String>{
        'Accept': 'application/json',
        if (token.trim().isNotEmpty) 'X-Authorization': token,
      };

      final encodedParams = params?.map(
            (key, value) => MapEntry(key, value?.toString() ?? ''),
          ) ??
          <String, String>{};

      late final http.Response response;
      if (method == Method.postMethod) {
        response = await http.post(uri, body: encodedParams, headers: headers);
      } else if (method == Method.putMethod) {
        response = await http.put(uri, body: encodedParams, headers: headers);
      } else if (method == Method.deleteMethod) {
        response = await http.delete(uri, headers: headers);
      } else {
        response = await http.get(uri, headers: headers);
      }

      final statusCode = response.statusCode;
      final body = response.body;

      if (statusCode >= 200 && statusCode < 300) {
        return ResponseModel(true, 'ok', body);
      }

      String message = 'Request failed with status $statusCode';
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      return ResponseModel(false, message, body);
    } catch (e) {
      return ResponseModel(false, e.toString(), '');
    }
  }

  // ── Predefined replies ────────────────────────────────────────────────────
  Future<ResponseModel> getPredefinedReplies() async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.predefinedRepliesUrl}',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  // ── Priorities CRUD ───────────────────────────────────────────────────────
  Future<ResponseModel> getPrioritiesAdmin() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketPrioritiesAdminUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addPriority(String name) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketPriorityAdminUrl}',
        Method.postMethod,
        {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> updatePriority(String id, String name) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketPriorityAdminUrl}?id=$id',
        Method.putMethod,
        {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> deletePriority(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketPriorityAdminUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  // ── Ticket Statuses CRUD ─────────────────────────────────────────────────
  Future<ResponseModel> getTicketStatusesAdmin() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketStatusesAdminUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addTicketStatus(String name, String color) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketStatusAdminUrl}',
        Method.postMethod,
        {'name': name, 'color': color},
        passHeader: true);
  }

  Future<ResponseModel> updateTicketStatus(
      String id, String name, String color) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketStatusAdminUrl}?id=$id',
        Method.putMethod,
        {'name': name, 'color': color},
        passHeader: true);
  }

  Future<ResponseModel> deleteTicketStatus(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketStatusAdminUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  // ── Services CRUD ─────────────────────────────────────────────────────────
  Future<ResponseModel> getServicesAdmin() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketServicesAdminUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addService(String name) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketServiceAdminUrl}',
        Method.postMethod,
        {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> updateService(String id, String name) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketServiceAdminUrl}?id=$id',
        Method.putMethod,
        {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> deleteService(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketServiceAdminUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  // ── Spam Filters CRUD ─────────────────────────────────────────────────────
  Future<ResponseModel> getSpamFiltersAdmin() async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketSpamFiltersAdminUrl}',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> addSpamFilter(String type, String value) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketSpamFilterAdminUrl}',
        Method.postMethod,
        {'type': type, 'value': value},
        passHeader: true);
  }

  Future<ResponseModel> updateSpamFilter(
      String id, String type, String value) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketSpamFilterAdminUrl}?id=$id',
        Method.putMethod,
        {'type': type, 'value': value},
        passHeader: true);
  }

  Future<ResponseModel> deleteSpamFilter(String id) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketSpamFilterAdminUrl}?id=$id',
        Method.deleteMethod,
        null,
        passHeader: true);
  }

  // ── Bulk Actions ──────────────────────────────────────────────────────────
  Future<ResponseModel> bulkDeleteTickets(List<String> ids) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.ticketBulkUrl}',
        Method.postMethod,
        {'action': 'delete', 'ids': ids},
        passHeader: true);
  }
}

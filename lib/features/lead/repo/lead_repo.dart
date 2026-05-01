import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/lead/model/lead_create_model.dart';

class LeadRepo {
  ApiClient apiClient;
  LeadRepo({required this.apiClient});

  Future<ResponseModel> getAllLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnLeadsFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/leads",
    ];

    ResponseModel lastResponse = ResponseModel(false, 'Lead access denied', '');
    for (final url in candidates) {
      final response = await apiClient.request(url, Method.getMethod, null,
          passHeader: true);
      if (response.status) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse;
  }

  Future<ResponseModel> getLeadDetails(leadId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> attachmentDownload(String attachmentKey) async {
    String url = "${UrlContainer.leadAttachmentUrl}/$attachmentKey";
    ResponseModel responseModel =
        await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getLeadStatuses() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/leads_statuses";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getLeadSources() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/leads_sources";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createLead(LeadCreateModel leadModel,
      {String? leadId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";

    Map<String, dynamic> params = {
      "source": leadModel.source,
      "status": leadModel.status,
      "name": leadModel.name,
      "assigned": leadModel.assigned,
      "tags": leadModel.tags,
      "lead_value": leadModel.value,
      "title": leadModel.title,
      "email": leadModel.email,
      "website": leadModel.website,
      "phonenumber": leadModel.phoneNumber,
      "company": leadModel.company,
      "address": leadModel.address,
      "city": leadModel.city,
      "state": leadModel.state,
      "country": leadModel.country,
      "default_language": leadModel.defaultLanguage,
      "description": leadModel.description,
      "is_public": leadModel.isPublic,
    };

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$leadId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteLead(leadId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> convertLeadToCustomer(String leadId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/convert_to_customer/id/$leadId';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  Future<ResponseModel> searchLead(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  // ── Lead notes ────────────────────────────────────────────────────────────
  Future<ResponseModel> getLeadNotes(String leadId) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadNotesUrl}/$leadId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addLeadNote(String leadId, String note) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadNotesUrl}/$leadId';
    return apiClient.request(url, Method.postMethod, {'note': note},
        passHeader: true);
  }

  Future<ResponseModel> updateLeadNote(String noteId, String note) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadNotesUrl}/note/$noteId';
    return apiClient.request(url, Method.putMethod, {'note': note},
        passHeader: true);
  }

  Future<ResponseModel> deleteLeadNote(String noteId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadNotesUrl}/note/$noteId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> markAsLost(String leadId, bool lost) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId';
    return apiClient.request(url, Method.putMethod, {'lost': lost ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> markAsJunk(String leadId, bool junk) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId';
    return apiClient.request(url, Method.putMethod, {'junk': junk ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> updateLeadStatusOnly(
      String leadId, String statusId) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId';
    return apiClient.request(url, Method.putMethod, {'status': statusId},
        passHeader: true);
  }

  // ── Lead activity log ─────────────────────────────────────────────────────
  Future<ResponseModel> getLeadActivity(String leadId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadActivityUrl}?lead_id=$leadId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  // ── Lead reminders ────────────────────────────────────────────────────────
  Future<ResponseModel> getLeadReminders(String leadId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadRemindersUrl}?id=$leadId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addLeadReminder(String leadId, String date,
      String description, String notifyStaff) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadReminderUrl}?id=$leadId';
    return apiClient.request(url, Method.postMethod,
        {'date': date, 'description': description, 'notify_staff': notifyStaff},
        passHeader: true);
  }

  Future<ResponseModel> deleteLeadReminder(String reminderId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadReminderUrl}?reminder_id=$reminderId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Lead sources admin CRUD ───────────────────────────────────────────────
  Future<ResponseModel> getLeadSourcesAdmin() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadSourcesAdminUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addLeadSource(String name) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadSourceAdminUrl}';
    return apiClient.request(url, Method.postMethod, {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> updateLeadSource(String id, String name) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadSourceAdminUrl}?id=$id';
    return apiClient.request(url, Method.putMethod, {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> deleteLeadSource(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadSourceAdminUrl}?id=$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Lead statuses admin CRUD ──────────────────────────────────────────────
  Future<ResponseModel> getLeadStatusesAdmin() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadStatusesAdminUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addLeadStatus(String name, String color) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.leadStatusAdminUrl}';
    return apiClient.request(
        url, Method.postMethod, {'name': name, 'color': color},
        passHeader: true);
  }

  Future<ResponseModel> updateLeadStatus(
      String id, String name, String color) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadStatusAdminUrl}?id=$id';
    return apiClient.request(
        url, Method.putMethod, {'name': name, 'color': color},
        passHeader: true);
  }

  Future<ResponseModel> deleteLeadStatus(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.leadStatusAdminUrl}?id=$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

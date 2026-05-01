import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/contact_post_model.dart';
import 'package:flutex_admin/features/customer/model/customer_post_model.dart';

class CustomerRepo {
  ApiClient apiClient;
  CustomerRepo({required this.apiClient});

  Future<ResponseModel> getAllCustomers() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnCustomersFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/customers",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Customer access denied', '');
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

  Future<ResponseModel> getCustomerDetails(customerId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/id/$customerId";
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

  Future<ResponseModel> getCustomerGroups() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/client_groups";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getCountries() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/countries";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getCurrencies() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/currencies";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> submitCustomer(CustomerPostModel customerModel,
      {String? customerId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";

    Map<String, dynamic> params = {
      "company": customerModel.company,
      "vat": customerModel.vat,
      "phonenumber": customerModel.phoneNumber,
      "website": customerModel.website,
      //"default_language": customerModel.defaultLanguage,
      "default_currency": customerModel.defaultCurrency,
      "address": customerModel.address,
      "city": customerModel.city,
      "state": customerModel.state,
      "zip": customerModel.zip,
      "country": customerModel.country,
      "billing_street": customerModel.billingStreet,
      "billing_city": customerModel.billingCity,
      "billing_state": customerModel.billingState,
      "billing_zip": customerModel.billingZip,
      "billing_country": customerModel.billingCountry,
      "shipping_street": customerModel.shippingStreet,
      "shipping_city": customerModel.shippingCity,
      "shipping_state": customerModel.shippingState,
      "shipping_zip": customerModel.shippingZip,
      "shipping_country": customerModel.shippingCountry,
    };

    if (customerModel.groupsIn != null) {
      int i = 0;
      for (var group in customerModel.groupsIn!) {
        params['groups_in[$i]'] = group;
        i++;
      }
    }

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$customerId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteCustomer(customerId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/id/$customerId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> toggleCustomerActive(
      String customerId, bool active) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customersUrl}/id/$customerId';
    return apiClient.request(
        url, Method.putMethod, {'active': active ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> searchCustomer(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.customersUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createContact(ContactPostModel contactModel) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contactsUrl}/id/${contactModel.customerId}";

    Map<String, dynamic> params = {
      "firstname": contactModel.firstName,
      "lastname": contactModel.lastName,
      "email": contactModel.email,
      "title": contactModel.title,
      "phonenumber": contactModel.phone,
      "password": contactModel.password,
    };

    ResponseModel responseModel = await apiClient
        .request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> updateContact(
      ContactPostModel contactModel, String contactId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contactsUrl}/id/$contactId";

    final Map<String, dynamic> params = {
      "firstname": contactModel.firstName,
      "lastname": contactModel.lastName,
      "email": contactModel.email,
      "title": contactModel.title,
      "phonenumber": contactModel.phone,
      "is_primary": contactModel.isPrimary ? '1' : '0',
      "active": contactModel.isActive ? '1' : '0',
      "invoice_emails": contactModel.invoiceEmails ? '1' : '0',
      "estimate_emails": contactModel.estimateEmails ? '1' : '0',
      "credit_note_emails": contactModel.creditNoteEmails ? '1' : '0',
      "contract_emails": contactModel.contractEmails ? '1' : '0',
      "task_emails": contactModel.taskEmails ? '1' : '0',
      "project_emails": contactModel.projectEmails ? '1' : '0',
      "ticket_emails": contactModel.ticketEmails ? '1' : '0',
      "permissions": contactModel.permissions,
      if (contactModel.password.isNotEmpty) "password": contactModel.password,
    };

    ResponseModel responseModel = await apiClient
        .request(url, Method.putMethod, params, passHeader: true);
    return responseModel;
  }

  // ── Customer sub-resources ─────────────────────────────────────────────────
  Future<ResponseModel> getCustomerInvoices(String clientId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerInvoicesUrl}?id=$clientId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getCustomerTickets(String clientId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerTicketsUrl}?id=$clientId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  // ── Notes ──────────────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerNotes(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerNotesUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addCustomerNote(
      String customerId, String description) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerNotesUrl}?id=$customerId';
    return apiClient.request(
        url, Method.postMethod, {'description': description},
        passHeader: true);
  }

  Future<ResponseModel> deleteCustomerNote(
      String customerId, String noteId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerNoteDeleteUrl}?id=$customerId&note_id=$noteId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Credit notes ──────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerCreditNotes(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerCreditNotesUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  // ── Activities ────────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerActivities(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerActivitiesUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> toggleContactStatus(
      String contactId, bool active) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerContactStatusUrl}?id=$contactId';
    return apiClient.request(
        url, Method.putMethod, {'active': active ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> deleteContactImage(String contactId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerContactImageDeleteUrl}?id=$contactId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> updateContactFileAccess(
      String contactId, bool canAccess) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerContactFileAccessUrl}?id=$contactId';
    return apiClient.request(
        url, Method.putMethod, {'file_access': canAccess ? '1' : '0'},
        passHeader: true);
  }

  // ── Subscriptions ─────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerSubscriptions(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerSubscriptionsUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  // ── Statement ─────────────────────────────────────────────────────────────
  Future<ResponseModel> sendCustomerStatement(
      String customerId, String from, String to) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerStatementUrl}/$customerId';
    return apiClient.request(url, Method.postMethod, {'from': from, 'to': to},
        passHeader: true);
  }

  // ── Groups ────────────────────────────────────────────────────────────────
  Future<ResponseModel> assignCustomerToGroup(
      String customerId, List<String> groupIds) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerGroupAssignUrl}/$customerId';
    final Map<String, dynamic> params = {};
    for (int i = 0; i < groupIds.length; i++) {
      params['groups_in[$i]'] = groupIds[i];
    }
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  // ── Attachments ───────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerAttachments(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAttachmentsUrl}?customer_id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> uploadCustomerAttachment(
      String customerId, String filePath) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAttachmentsUrl}?customer_id=$customerId';
    return apiClient.multipartRequest(url, filePath, {}, passHeader: true);
  }

  Future<ResponseModel> deleteCustomerAttachment(String attachmentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAttachmentUrl}?attachment_id=$attachmentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Admins ────────────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerAdmins(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAdminsUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> assignCustomerAdmin(
      String customerId, String staffId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAdminsUrl}?id=$customerId';
    return apiClient.request(url, Method.postMethod, {'staff_id': staffId},
        passHeader: true);
  }

  Future<ResponseModel> removeCustomerAdmin(
      String customerId, String staffId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerAdminsUrl}?id=$customerId&staff_id=$staffId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── GDPR Consents ─────────────────────────────────────────────────────────
  Future<ResponseModel> getCustomerGdprConsents(String customerId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.customerGdprConsentsUrl}?id=$customerId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  // ── Staff (for admin picker) ──────────────────────────────────────────────
  Future<ResponseModel> getAllStaff() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }
}

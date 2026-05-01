import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_post_model.dart';

class EstimateRepo {
  ApiClient apiClient;
  EstimateRepo({required this.apiClient});

  Future<ResponseModel> getAllEstimates() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnEstimatesFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/estimates",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Estimate access denied', '');
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

  Future<ResponseModel> getEstimateDetails(estimateId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/id/$estimateId";
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

  Future<ResponseModel> getCurrencies() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/currencies";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getItems() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.itemsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createEstimate(EstimatePostModel estimateModel,
      {String? estimateId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}";

    Map<String, dynamic> params = {
      "clientid": estimateModel.clientId,
      "number": estimateModel.number,
      "date": estimateModel.date,
      "currency": estimateModel.currency,
      "billing_street": estimateModel.billingStreet,
      "expirydate": estimateModel.duedate,
      "status": estimateModel.status,
      "clientnote": estimateModel.clientNote,
      "terms": estimateModel.terms,
      "newitems[0][description]": estimateModel.firstItemName,
      "newitems[0][long_description]": estimateModel.firstItemDescription,
      "newitems[0][qty]": estimateModel.firstItemQty,
      "newitems[0][rate]": estimateModel.firstItemRate,
      "newitems[0][unit]": estimateModel.firstItemUnit,
      "subtotal": estimateModel.subtotal,
      "total": estimateModel.total,
    };

    if ((estimateModel.projectId ?? '').trim().isNotEmpty) {
      params['project_id'] = estimateModel.projectId!.trim();
    }

    int i = 0;
    for (var estimate in estimateModel.newItems) {
      String estimateItemName = estimate.itemNameController.text;
      String estimateItemDescription = estimate.descriptionController.text;
      String estimateItemQty = estimate.qtyController.text;
      String estimateItemRate = estimate.rateController.text;
      String estimateItemUnit = estimate.unitController.text;

      if (estimateItemName.isNotEmpty && estimateItemRate.isNotEmpty) {
        i = i + 1;
        params['newitems[$i][description]'] = estimateItemName;
        params['newitems[$i][long_description]'] = estimateItemDescription;
        params['newitems[$i][qty]'] = estimateItemQty;
        params['newitems[$i][rate]'] = estimateItemRate;
        params['newitems[$i][unit]'] = estimateItemUnit;
        //params['newitems[$i][order]'] = '1';
        //params['newitems[0][taxname][]'] = 'CGST|9.00';
        //params['newitems[0][taxname][]'] = 'SGST|9.00';
      }
    }

    if (estimateModel.removedItems != null) {
      int r = 0;
      for (var removedItems in estimateModel.removedItems!) {
        params['removed_items[$r]'] = removedItems;
        r++;
      }
    }

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$estimateId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteEstimate(estimateId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/id/$estimateId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> convertEstimateToInvoice(String estimateId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/create_invoice_from_estimate/$estimateId';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  Future<ResponseModel> searchEstimate(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendByEmail(String estimateId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.emailEstimateUrl}/$estimateId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> markActionStatus(
      String estimateId, String status) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}/id/$estimateId';
    return apiClient.request(url, Method.putMethod, {'status': status},
        passHeader: true);
  }

  // ── Copy estimate ─────────────────────────────────────────────────────────
  Future<ResponseModel> copyEstimate(String estimateId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateCopyUrl}?id=$estimateId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Send expiry reminder ──────────────────────────────────────────────────
  Future<ResponseModel> sendExpiryReminder(String estimateId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateExpiryReminderUrl}?id=$estimateId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Attachments ───────────────────────────────────────────────────────────
  Future<ResponseModel> uploadAttachment(
      String estimateId, String filePath, bool visibleToCustomer) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateAttachmentsUrl}?id=$estimateId';
    return apiClient.multipartRequest(
      url,
      filePath,
      {'visible_to_customer': visibleToCustomer ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteAttachment(
      String estimateId, String attachmentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateAttachmentDeleteUrl}?id=$estimateId&attachment_id=$attachmentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Clear signature ───────────────────────────────────────────────────────
  Future<ResponseModel> clearSignature(String estimateId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateClearSignatureUrl}?id=$estimateId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Admin note ────────────────────────────────────────────────────────────
  Future<ResponseModel> updateAdminNote(String estimateId, String note) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.estimateAdminNoteUrl}?id=$estimateId';
    return apiClient.request(url, Method.postMethod, {'adminnote': note},
        passHeader: true);
  }
}

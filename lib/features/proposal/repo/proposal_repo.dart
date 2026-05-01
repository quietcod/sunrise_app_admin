import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/proposal/model/proposal_post_model.dart';

class ProposalRepo {
  ApiClient apiClient;
  ProposalRepo({required this.apiClient});

  Future<ResponseModel> getAllProposals() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnProposalsFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/proposals",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Proposal access denied', '');
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

  Future<ResponseModel> getProposalDetails(proposalId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/id/$proposalId";
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

  Future<ResponseModel> getCustomerContacts(String customerId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contactsUrl}/id/$customerId";
    return await apiClient.request(url, Method.getMethod, null,
        passHeader: true);
  }

  Future<ResponseModel> getAllLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";
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

  Future<ResponseModel> createProposal(ProposalPostModel proposalModel,
      {String? proposalId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}";

    Map<String, dynamic> params = {
      "subject": proposalModel.subject,
      "rel_type": proposalModel.related,
      "rel_id": proposalModel.relId,
      "proposal_to": proposalModel.proposalTo,
      "date": proposalModel.date,
      "open_till": proposalModel.openTill,
      "currency": proposalModel.currency,
      //"discount_type": proposalModel.discountType,
      "status": proposalModel.status,
      //"assigned": proposalModel.assigned,
      "email": proposalModel.email,
      if (proposalModel.projectId != null &&
          proposalModel.projectId!.isNotEmpty)
        "project_id": proposalModel.projectId,
      "newitems[0][description]": proposalModel.firstItemName,
      "newitems[0][long_description]": proposalModel.firstItemDescription,
      "newitems[0][qty]": proposalModel.firstItemQty,
      "newitems[0][rate]": proposalModel.firstItemRate,
      "newitems[0][unit]": proposalModel.firstItemUnit,
      "subtotal": proposalModel.subtotal,
      "total": proposalModel.total,
    };

    int i = 0;
    for (var proposal in proposalModel.newItems) {
      String proposalItemName = proposal.itemNameController.text;
      String proposalItemDescription = proposal.descriptionController.text;
      String proposalItemQty = proposal.qtyController.text;
      String proposalItemRate = proposal.rateController.text;
      String proposalItemUnit = proposal.unitController.text;

      if (proposalItemName.isNotEmpty && proposalItemRate.isNotEmpty) {
        i = i + 1;
        params['newitems[$i][description]'] = proposalItemName;
        params['newitems[$i][long_description]'] = proposalItemDescription;
        params['newitems[$i][qty]'] = proposalItemQty;
        params['newitems[$i][rate]'] = proposalItemRate;
        params['newitems[$i][unit]'] = proposalItemUnit;
        //params['newitems[$i][order]'] = '1';
        //params['newitems[0][taxname][]'] = 'CGST|9.00';
        //params['newitems[0][taxname][]'] = 'SGST|9.00';
      }
    }

    if (proposalModel.removedItems != null) {
      int r = 0;
      for (var removedItems in proposalModel.removedItems!) {
        params['removed_items[$r]'] = removedItems;
        r++;
      }
    }

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$proposalId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteProposal(proposalId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/id/$proposalId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchProposal(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> convertToEstimate(String proposalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/convert_to_estimate/$proposalId';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  Future<ResponseModel> convertToInvoice(String proposalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/convert_to_invoice/$proposalId';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  /// status: 1=Open, 2=Declined, 3=Accepted, 4=Sent, 6=Revised
  Future<ResponseModel> markActionStatus(
      String proposalId, String status) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}/id/$proposalId';
    return apiClient.request(url, Method.putMethod, {'status': status},
        passHeader: true);
  }

  // ── Copy proposal ─────────────────────────────────────────────────────────
  Future<ResponseModel> copyProposal(String proposalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalCopyUrl}?id=$proposalId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Send expiry reminder ──────────────────────────────────────────────────
  Future<ResponseModel> sendExpiryReminder(String proposalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalExpiryReminderUrl}?id=$proposalId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Comments ──────────────────────────────────────────────────────────────
  Future<ResponseModel> addComment(String proposalId, String content) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalCommentsUrl}?id=$proposalId';
    return apiClient.request(url, Method.postMethod, {'content': content},
        passHeader: true);
  }

  Future<ResponseModel> deleteComment(
      String proposalId, String commentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalCommentDeleteUrl}?id=$proposalId&comment_id=$commentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Attachments ───────────────────────────────────────────────────────────
  Future<ResponseModel> uploadAttachment(
      String proposalId, String filePath, bool visibleToCustomer) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalAttachmentsUrl}?id=$proposalId';
    return apiClient.multipartRequest(
      url,
      filePath,
      {'visible_to_customer': visibleToCustomer ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteAttachment(
      String proposalId, String attachmentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalAttachmentDeleteUrl}?id=$proposalId&attachment_id=$attachmentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Clear signature ───────────────────────────────────────────────────────
  Future<ResponseModel> clearSignature(String proposalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.proposalClearSignatureUrl}?id=$proposalId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }
}

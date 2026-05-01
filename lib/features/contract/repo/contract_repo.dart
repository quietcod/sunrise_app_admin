import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/contract/model/contract_post_model.dart';

class ContractRepo {
  ApiClient apiClient;
  ContractRepo({required this.apiClient});

  Future<ResponseModel> getAllContracts() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnContractsFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/contracts",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Contract access denied', '');
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

  Future<ResponseModel> getContractDetails(contractId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/id/$contractId";
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

  Future<ResponseModel> createContract(ContractPostModel contractModel,
      {String? contractId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}";

    Map<String, dynamic> params = {
      "subject": contractModel.subject,
      "client": contractModel.client,
      "datestart": contractModel.startDate,
      "dateend": contractModel.endDate,
      "contract_value": contractModel.contractValue,
      "description": contractModel.description,
      "content": contractModel.content,
    };

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$contractId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteContract(contractId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/id/$contractId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchContract(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendByEmail(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.emailContractUrl}/$contractId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> markSigned(String contractId,
      {bool signed = true}) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractSignUrl}/$contractId';
    return apiClient.request(
        url, Method.postMethod, {'signed': signed ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> copyContract(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractCopyUrl}/$contractId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> getContractNotes(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractNotesUrl}?id=$contractId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addContractNote(
      String contractId, String description) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractNotesUrl}?id=$contractId';
    return apiClient.request(
        url, Method.postMethod, {'description': description},
        passHeader: true);
  }

  Future<ResponseModel> deleteContractNote(
      String contractId, String noteId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractNoteDeleteUrl}?id=$contractId&note_id=$noteId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Comments ──────────────────────────────────────────────────────────────
  Future<ResponseModel> addContractComment(
      String contractId, String content) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractCommentsUrl}?id=$contractId';
    return apiClient.request(url, Method.postMethod, {'content': content},
        passHeader: true);
  }

  Future<ResponseModel> getContractComments(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractCommentsUrl}?id=$contractId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> deleteContractComment(
      String contractId, String commentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractCommentDeleteUrl}?id=$contractId&comment_id=$commentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Attachments ───────────────────────────────────────────────────────────
  Future<ResponseModel> uploadContractAttachment(
      String contractId, String filePath, bool visibleToCustomer) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractAttachmentsUrl}?id=$contractId';
    return apiClient.multipartRequest(
      url,
      filePath,
      {'visible_to_customer': visibleToCustomer ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteContractAttachment(
      String contractId, String attachmentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractAttachmentDeleteUrl}?id=$contractId&attachment_id=$attachmentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Clear signature ───────────────────────────────────────────────────────
  Future<ResponseModel> clearSignature(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractClearSignatureUrl}?id=$contractId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  // ── Renewals ──────────────────────────────────────────────────────────────
  Future<ResponseModel> getRenewals(String contractId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractRenewUrl}?id=$contractId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> renewContract(
      String contractId, String dateStart, String dateEnd) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractRenewUrl}?id=$contractId';
    return apiClient.request(
        url, Method.postMethod, {'date_start': dateStart, 'date_end': dateEnd},
        passHeader: true);
  }

  Future<ResponseModel> deleteRenewal(
      String contractId, String renewalId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractRenewUrl}?id=$contractId&renewal_id=$renewalId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

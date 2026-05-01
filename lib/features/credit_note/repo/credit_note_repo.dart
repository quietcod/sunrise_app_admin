import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class CreditNoteRepo {
  ApiClient apiClient;
  CreditNoteRepo({required this.apiClient});

  Future<ResponseModel> getAllCreditNotes() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getCreditNoteDetails(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}/id/$id';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addCreditNote(Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}';
    return apiClient.request(url, Method.postMethod, data, passHeader: true);
  }

  Future<ResponseModel> updateCreditNote(
      String id, Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, data, passHeader: true);
  }

  Future<ResponseModel> deleteCreditNote(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> getAllCustomers() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.customersUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> getCurrencies() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/currencies';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> sendByEmail(String id) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.emailCreditNoteUrl}/$id';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  Future<ResponseModel> applyToInvoice(
      String creditNoteId, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}/apply_to_invoice/$creditNoteId';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> refund(
      String creditNoteId, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.creditNotesUrl}/refund/$creditNoteId';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }
}

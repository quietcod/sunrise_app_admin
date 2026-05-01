import 'package:flutex_admin/common/models/payment_modes_model.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'dart:convert';

class PaymentRepo {
  ApiClient apiClient;
  PaymentRepo({required this.apiClient});

  Future<ResponseModel> getAllPayments() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnPaymentsFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/payments",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Payment access denied', '');
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

  Future<ResponseModel> getPaymentDetails(paymentId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}/id/$paymentId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchPayment(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendReceipt(String paymentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.emailPaymentReceiptUrl}?id=$paymentId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> addPayment(Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.paymentsUrl}';
    return apiClient.request(url, Method.postMethod, data, passHeader: true);
  }

  Future<PaymentModesModel> getPaymentModes() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/payment_modes';
    final res =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    if (res.status) {
      return PaymentModesModel.fromJson(jsonDecode(res.responseJson));
    }
    return PaymentModesModel();
  }
}

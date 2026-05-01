import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class ReportsRepo {
  ApiClient apiClient;
  ReportsRepo({required this.apiClient});

  Future<ResponseModel> getSummary(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsSummaryUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getSales(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsSalesUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getPayments(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsPaymentsUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getExpenses(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsExpensesUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getLeads(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsLeadsUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getTaxSummary(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsTaxSummaryUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }

  Future<ResponseModel> getByPaymentMode(String year) async {
    return apiClient.request(
        '${UrlContainer.baseUrl}${UrlContainer.reportsByPaymentModeUrl}?year=$year',
        Method.getMethod,
        null,
        passHeader: true);
  }
}

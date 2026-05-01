import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class ExpenseRepo {
  ApiClient apiClient;
  ExpenseRepo({required this.apiClient});

  Future<ResponseModel> getAllExpenses() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getExpenseDetails(expenseId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/id/$expenseId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getExpenseCategories() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/expense_categories";
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

  Future<ResponseModel> getAllProjects() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}";
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

  Future<ResponseModel> getTaxes() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/tax_data";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createExpense(Map<String, dynamic> params) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}";
    ResponseModel responseModel = await apiClient
        .request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> updateExpense(
      String expenseId, Map<String, dynamic> params) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/id/$expenseId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.putMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteExpense(expenseId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/id/$expenseId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchExpense(String keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> convertToInvoice(String expenseId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expenseConvertToInvoiceUrl}/$expenseId";
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  // ── Expense Categories CRUD ────────────────────────────────────────────
  Future<ResponseModel> addCategory(Map<String, dynamic> params) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/category";
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updateCategory(
      String categoryId, Map<String, dynamic> params) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/category/$categoryId";
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deleteCategory(String categoryId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.expensesUrl}/category/$categoryId";
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

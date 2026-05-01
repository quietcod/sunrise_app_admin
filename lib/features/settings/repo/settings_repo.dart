import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class SettingsRepo {
  ApiClient apiClient;
  SettingsRepo({required this.apiClient});

  // ── Taxes ──────────────────────────────────────────────────────────────────

  Future<ResponseModel> getTaxes() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsTaxesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addTax(Map<String, dynamic> params) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsTaxesUrl}';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updateTax(
      String id, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsTaxesUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deleteTax(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsTaxesUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Payment Modes ──────────────────────────────────────────────────────────

  Future<ResponseModel> getPaymentModes() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsPaymentModesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addPaymentMode(Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsPaymentModesUrl}';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updatePaymentMode(
      String id, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsPaymentModesUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deletePaymentMode(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsPaymentModesUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Departments ────────────────────────────────────────────────────────────

  Future<ResponseModel> getDepartments() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsDepartmentsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addDepartment(Map<String, dynamic> params) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsDepartmentsUrl}';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updateDepartment(
      String id, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsDepartmentsUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deleteDepartment(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsDepartmentsUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Client Groups ──────────────────────────────────────────────────────────

  Future<ResponseModel> getClientGroups() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsClientGroupsUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addClientGroup(Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsClientGroupsUrl}';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updateClientGroup(
      String id, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsClientGroupsUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deleteClientGroup(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsClientGroupsUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Roles ──────────────────────────────────────────────────────────────────

  Future<ResponseModel> getRoles() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsRolesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addRole(Map<String, dynamic> params) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.settingsRolesUrl}';
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }

  Future<ResponseModel> updateRole(
      String id, Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsRolesUrl}/id/$id';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  Future<ResponseModel> deleteRole(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsRolesUrl}/id/$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Invoice Number Settings ────────────────────────────────────────────────

  Future<ResponseModel> getInvoiceNumberSettings() async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsInvoiceNumberUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> updateInvoiceNumberSettings(
      Map<String, dynamic> params) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.settingsInvoiceNumberUrl}';
    return apiClient.request(url, Method.putMethod, params, passHeader: true);
  }

  // ── Contract Types ────────────────────────────────────────────────────────

  Future<ResponseModel> getContractTypes() async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.contractTypesUrl}';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> addContractType(String name) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.contractTypesUrl}';
    return apiClient.request(url, Method.postMethod, {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> updateContractType(String id, String name) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractTypesUrl}?id=$id';
    return apiClient.request(url, Method.putMethod, {'name': name},
        passHeader: true);
  }

  Future<ResponseModel> deleteContractType(String id) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.contractTypesUrl}?id=$id';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }
}

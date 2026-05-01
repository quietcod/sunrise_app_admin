import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/currencies_model.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/common/models/taxes_model.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/expense/model/expense_category_model.dart';
import 'package:flutex_admin/features/expense/model/expense_details_model.dart';
import 'package:flutex_admin/features/expense/model/expense_model.dart';
import 'package:flutex_admin/features/expense/repo/expense_repo.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpenseController extends GetxController {
  ExpenseRepo expenseRepo;
  ExpenseController({required this.expenseRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;

  ExpensesModel expensesModel = ExpensesModel();
  ExpenseDetailsModel expenseDetailsModel = ExpenseDetailsModel();
  ExpenseCategoriesModel categoriesModel = ExpenseCategoriesModel();
  CustomersModel customersModel = CustomersModel();
  ProjectsModel projectsModel = ProjectsModel();
  CurrenciesModel currenciesModel = CurrenciesModel();
  TaxesModel taxesModel = TaxesModel();

  bool isSearch = false;
  TextEditingController searchController = TextEditingController();

  // Form controllers
  TextEditingController expenseNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController referenceNoController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController tax2Controller = TextEditingController();

  // FocusNodes
  FocusNode expenseNameFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode referenceNoFocusNode = FocusNode();
  FocusNode noteFocusNode = FocusNode();

  bool billable = false;

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();
    await loadExpenses();
    isLoading = false;
    update();
  }

  Future<void> loadExpenses() async {
    ResponseModel responseModel = await expenseRepo.getAllExpenses();
    if (responseModel.status) {
      expensesModel =
          ExpensesModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      expensesModel = ExpensesModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadExpenseDetails(expenseId) async {
    ResponseModel responseModel =
        await expenseRepo.getExpenseDetails(expenseId);
    if (responseModel.status) {
      expenseDetailsModel =
          ExpenseDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<ExpenseCategoriesModel> loadCategories() async {
    try {
      ResponseModel responseModel = await expenseRepo.getExpenseCategories();
      if (responseModel.status && responseModel.responseJson.isNotEmpty) {
        categoriesModel = ExpenseCategoriesModel.fromJson(
            jsonDecode(responseModel.responseJson));
      }
    } catch (_) {}
    return categoriesModel;
  }

  Future<CustomersModel> loadCustomers() async {
    try {
      ResponseModel responseModel = await expenseRepo.getAllCustomers();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return customersModel = CustomersModel(status: false, data: []);
      }
      return customersModel =
          CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return customersModel = CustomersModel(status: false, data: []);
    }
  }

  Future<ProjectsModel> loadProjects() async {
    try {
      ResponseModel responseModel = await expenseRepo.getAllProjects();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return projectsModel = ProjectsModel();
      }
      return projectsModel =
          ProjectsModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return projectsModel = ProjectsModel();
    }
  }

  Future<CurrenciesModel> loadCurrencies() async {
    try {
      ResponseModel responseModel = await expenseRepo.getCurrencies();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return currenciesModel = CurrenciesModel();
      }
      return currenciesModel =
          CurrenciesModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return currenciesModel = CurrenciesModel();
    }
  }

  Future<TaxesModel> loadTaxes() async {
    try {
      ResponseModel responseModel = await expenseRepo.getTaxes();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return taxesModel = TaxesModel();
      }
      return taxesModel =
          TaxesModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return taxesModel = TaxesModel();
    }
  }

  Future<void> loadExpenseUpdateData(expenseId) async {
    ResponseModel responseModel =
        await expenseRepo.getExpenseDetails(expenseId);
    if (responseModel.status) {
      expenseDetailsModel =
          ExpenseDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      final e = expenseDetailsModel.data;
      expenseNameController.text = e?.expenseName ?? '';
      amountController.text = e?.amount ?? '';
      dateController.text = e?.date ?? '';
      referenceNoController.text = e?.referenceNo ?? '';
      noteController.text = e?.note ?? '';
      categoryController.text = e?.category ?? '';
      clientController.text = e?.clientId ?? '';
      projectController.text = e?.projectId ?? '';
      currencyController.text = e?.currency ?? '';
      taxController.text = e?.tax ?? '';
      tax2Controller.text = e?.tax2 ?? '';
      billable = (e?.billable ?? '0') == '1';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void changeSearchIcon() {
    isSearch = !isSearch;
    if (!isSearch) {
      searchController.clear();
      initialData(shouldLoad: false);
    }
    update();
  }

  Future<void> searchExpense() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      await initialData(shouldLoad: false);
      return;
    }
    isLoading = true;
    update();
    ResponseModel responseModel = await expenseRepo.searchExpense(query);
    if (responseModel.status) {
      expensesModel =
          ExpensesModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      expensesModel = ExpensesModel();
    }
    isLoading = false;
    update();
  }

  // ── Submit / Update ───────────────────────────────────────────────────────

  Future<void> submitExpense({String? expenseId, bool isUpdate = false}) async {
    final name = expenseNameController.text.trim();
    final amount = amountController.text.trim();
    final date = dateController.text.trim();
    final category = categoryController.text.trim();
    final currency = currencyController.text.trim();

    if (name.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterExpenseName.tr]);
      return;
    }
    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterExpenseAmount.tr]);
      return;
    }
    if (date.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterExpenseDate.tr]);
      return;
    }
    if (category.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.selectExpenseCategory.tr]);
      return;
    }
    if (currency.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.selectCurrency.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    final params = <String, dynamic>{
      'expense_name': name,
      'amount': amount,
      'date': date,
      'category': category,
      'currency': currency,
      'billable': billable ? '1' : '0',
    };
    if (referenceNoController.text.trim().isNotEmpty) {
      params['reference_no'] = referenceNoController.text.trim();
    }
    if (noteController.text.trim().isNotEmpty) {
      params['note'] = noteController.text.trim();
    }
    if (clientController.text.trim().isNotEmpty) {
      params['clientid'] = clientController.text.trim();
    }
    if (projectController.text.trim().isNotEmpty) {
      params['project_id'] = projectController.text.trim();
    }
    if (taxController.text.trim().isNotEmpty) {
      params['tax'] = taxController.text.trim();
    }
    if (tax2Controller.text.trim().isNotEmpty) {
      params['tax2'] = tax2Controller.text.trim();
    }

    ResponseModel responseModel;
    if (isUpdate && expenseId != null) {
      responseModel = await expenseRepo.updateExpense(expenseId, params);
    } else {
      responseModel = await expenseRepo.createExpense(params);
    }

    isSubmitLoading = false;
    update();

    if (responseModel.status) {
      clearData();
      CustomSnackBar.success(
        successList: [
          isUpdate
              ? LocalStrings.expenseUpdatedSuccessfully.tr
              : LocalStrings.expenseAddedSuccessfully.tr,
        ],
      );
      Get.back();
      if (isUpdate) {
        Get.back(); // pop detail screen too
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteExpense(String expenseId) async {
    isLoading = true;
    update();
    ResponseModel responseModel = await expenseRepo.deleteExpense(expenseId);
    if (responseModel.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.expenseDeletedSuccessfully.tr]);
      Get.back(); // pop detail screen
      await initialData(shouldLoad: false);
    } else {
      isLoading = false;
      update();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> openPdf(String expenseId) async {
    final uri = Uri.parse('${UrlContainer.pdfExpenseWebUrl}$expenseId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.error(errorList: ['Could not open PDF']);
    }
  }

  Future<void> convertToInvoice(String expenseId) async {
    isSubmitLoading = true;
    update();
    final response = await expenseRepo.convertToInvoice(expenseId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.convertToInvoiceMsg.tr]);
      await loadExpenseDetails(expenseId);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  // ── Expense Categories CRUD ──────────────────────────────────────────────

  Future<void> addCategory(String name, String description) async {
    isSubmitLoading = true;
    update();
    final response = await expenseRepo.addCategory({
      'name': name,
      'description': description,
    });
    isSubmitLoading = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Category added successfully']);
      await loadCategories();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<void> updateCategory(
      String categoryId, String name, String description) async {
    isSubmitLoading = true;
    update();
    final response = await expenseRepo.updateCategory(categoryId, {
      'name': name,
      'description': description,
    });
    isSubmitLoading = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Category updated successfully']);
      await loadCategories();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    isSubmitLoading = true;
    update();
    final response = await expenseRepo.deleteCategory(categoryId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Category deleted successfully']);
      await loadCategories();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  void clearData() {
    expenseNameController.clear();
    amountController.clear();
    dateController.clear();
    referenceNoController.clear();
    noteController.clear();
    categoryController.clear();
    clientController.clear();
    projectController.clear();
    currencyController.clear();
    taxController.clear();
    tax2Controller.clear();
    billable = false;
    update();
  }

  @override
  void onClose() {
    expenseNameController.dispose();
    amountController.dispose();
    dateController.dispose();
    referenceNoController.dispose();
    noteController.dispose();
    categoryController.dispose();
    clientController.dispose();
    projectController.dispose();
    currencyController.dispose();
    taxController.dispose();
    tax2Controller.dispose();
    searchController.dispose();
    expenseNameFocusNode.dispose();
    amountFocusNode.dispose();
    referenceNoFocusNode.dispose();
    noteFocusNode.dispose();
    super.onClose();
  }
}

import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/settings/model/settings_models.dart';
import 'package:flutex_admin/features/settings/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  SettingsRepo settingsRepo;
  SettingsController({required this.settingsRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;

  // ── Taxes ──────────────────────────────────────────────────────────────────
  TaxesModel taxesModel = TaxesModel();

  // ── Payment Modes ──────────────────────────────────────────────────────────
  PaymentModesModel paymentModesModel = PaymentModesModel();

  // ── Departments ────────────────────────────────────────────────────────────
  DepartmentsModel departmentsModel = DepartmentsModel();

  // ── Client Groups ──────────────────────────────────────────────────────────
  ClientGroupsModel clientGroupsModel = ClientGroupsModel();

  // ── Roles ──────────────────────────────────────────────────────────────────
  RolesModel rolesModel = RolesModel();

  // ── Form controllers ────────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final rateController = TextEditingController();
  final descController = TextEditingController();
  final emailController = TextEditingController();

  // ── Data load helpers ──────────────────────────────────────────────────────

  Future<void> loadTaxes() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getTaxes();
    if (res.status) {
      taxesModel = TaxesModel.fromJson(jsonDecode(res.responseJson));
    } else {
      taxesModel = TaxesModel();
    }
    isLoading = false;
    update();
  }

  Future<void> loadPaymentModes() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getPaymentModes();
    if (res.status) {
      paymentModesModel =
          PaymentModesModel.fromJson(jsonDecode(res.responseJson));
    } else {
      paymentModesModel = PaymentModesModel();
    }
    isLoading = false;
    update();
  }

  Future<void> loadDepartments() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getDepartments();
    if (res.status) {
      departmentsModel =
          DepartmentsModel.fromJson(jsonDecode(res.responseJson));
    } else {
      departmentsModel = DepartmentsModel();
    }
    isLoading = false;
    update();
  }

  Future<void> loadClientGroups() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getClientGroups();
    if (res.status) {
      clientGroupsModel =
          ClientGroupsModel.fromJson(jsonDecode(res.responseJson));
    } else {
      clientGroupsModel = ClientGroupsModel();
    }
    isLoading = false;
    update();
  }

  Future<void> loadRoles() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getRoles();
    if (res.status) {
      rolesModel = RolesModel.fromJson(jsonDecode(res.responseJson));
    } else {
      rolesModel = RolesModel();
    }
    isLoading = false;
    update();
  }

  // ── Taxes CRUD ─────────────────────────────────────────────────────────────

  Future<void> addTax() async {
    if (nameController.text.trim().isEmpty ||
        rateController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.addTax({
      'name': nameController.text.trim(),
      'taxrate': rateController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadTaxes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateTax(String id) async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.updateTax(id, {
      'name': nameController.text.trim(),
      'taxrate': rateController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadTaxes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteTax(String id) async {
    final res = await settingsRepo.deleteTax(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadTaxes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  // ── Payment Modes CRUD ─────────────────────────────────────────────────────

  Future<void> addPaymentMode() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.addPaymentMode({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadPaymentModes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updatePaymentMode(String id) async {
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.updatePaymentMode(id, {
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadPaymentModes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deletePaymentMode(String id) async {
    final res = await settingsRepo.deletePaymentMode(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadPaymentModes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  // ── Departments CRUD ───────────────────────────────────────────────────────

  Future<void> addDepartment() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.addDepartment({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadDepartments();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateDepartment(String id) async {
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.updateDepartment(id, {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadDepartments();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteDepartment(String id) async {
    final res = await settingsRepo.deleteDepartment(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadDepartments();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  // ── Client Groups CRUD ─────────────────────────────────────────────────────

  Future<void> addClientGroup() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res =
        await settingsRepo.addClientGroup({'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadClientGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateClientGroup(String id) async {
    isSubmitLoading = true;
    update();
    final res = await settingsRepo
        .updateClientGroup(id, {'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadClientGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteClientGroup(String id) async {
    final res = await settingsRepo.deleteClientGroup(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadClientGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  // ── Roles CRUD ─────────────────────────────────────────────────────────────

  Future<void> addRole() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res =
        await settingsRepo.addRole({'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadRoles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateRole(String id) async {
    isSubmitLoading = true;
    update();
    final res =
        await settingsRepo.updateRole(id, {'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadRoles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteRole(String id) async {
    final res = await settingsRepo.deleteRole(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadRoles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  // ── Invoice Number Settings ────────────────────────────────────────────────
  Map<String, dynamic> invoiceNumberSettings = {};

  Future<void> loadInvoiceNumberSettings() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getInvoiceNumberSettings();
    if (res.status) {
      invoiceNumberSettings =
          Map<String, dynamic>.from(jsonDecode(res.responseJson)['data'] ?? {});
    } else {
      invoiceNumberSettings = {};
    }
    isLoading = false;
    update();
  }

  Future<void> saveInvoiceNumberSettings(Map<String, dynamic> params) async {
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.updateInvoiceNumberSettings(params);
    isSubmitLoading = false;
    if (res.status) {
      CustomSnackBar.success(successList: ['Invoice number settings saved']);
      await loadInvoiceNumberSettings();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
    update();
  }

  // ── Contract Types ────────────────────────────────────────────────────────
  ContractTypesModel contractTypesModel = ContractTypesModel();

  Future<void> loadContractTypes() async {
    isLoading = true;
    update();
    final res = await settingsRepo.getContractTypes();
    if (res.status) {
      contractTypesModel =
          ContractTypesModel.fromJson(jsonDecode(res.responseJson));
    } else {
      contractTypesModel = ContractTypesModel();
    }
    isLoading = false;
    update();
  }

  Future<void> addContractType() async {
    isSubmitLoading = true;
    update();
    final res = await settingsRepo.addContractType(nameController.text.trim());
    isSubmitLoading = false;
    if (res.status) {
      Get.back();
      clearForm();
      CustomSnackBar.success(successList: ['Contract type added']);
      await loadContractTypes();
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    update();
  }

  Future<void> updateContractType(String id) async {
    isSubmitLoading = true;
    update();
    final res =
        await settingsRepo.updateContractType(id, nameController.text.trim());
    isSubmitLoading = false;
    if (res.status) {
      Get.back();
      clearForm();
      CustomSnackBar.success(successList: ['Contract type updated']);
      await loadContractTypes();
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    update();
  }

  Future<void> deleteContractType(String id) async {
    final res = await settingsRepo.deleteContractType(id);
    if (res.status) {
      CustomSnackBar.success(successList: ['Contract type deleted']);
      await loadContractTypes();
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    update();
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  void clearForm() {
    nameController.clear();
    rateController.clear();
    descController.clear();
    emailController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    rateController.dispose();
    descController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

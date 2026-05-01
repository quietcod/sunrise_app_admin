import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/staff/repo/staff_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffController extends GetxController {
  StaffRepo staffRepo;
  StaffController({required this.staffRepo});

  bool isLoading = true;
  bool isSubmitting = false;
  List<StaffMember> staffList = [];
  List<StaffMember> filteredList = [];
  StaffMember? selectedStaff;
  String searchQuery = '';

  // ── Form controllers ──────────────────────────────────────────────────
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initialData();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    if (shouldLoad) {
      isLoading = true;
      update();
    }
    await _load();
    isLoading = false;
    update();
  }

  Future<void> _load() async {
    final response = await staffRepo.getAllStaff();
    if (response.status) {
      final model = StaffListModel.fromJson(jsonDecode(response.responseJson));
      staffList = model.data ?? [];
      _applyFilter();
    }
  }

  void search(String query) {
    searchQuery = query;
    _applyFilter();
    update();
  }

  void _applyFilter() {
    if (searchQuery.isEmpty) {
      filteredList = List.from(staffList);
    } else {
      filteredList = staffList
          .where((s) =>
              s.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (s.email?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                  false) ||
              (s.position?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }
  }

  Future<void> loadDetails(String id) async {
    isLoading = true;
    update();
    final response = await staffRepo.getStaffDetails(id);
    if (response.status) {
      final json = jsonDecode(response.responseJson);
      selectedStaff = StaffMember.fromJson(json['data']);
    }
    isLoading = false;
    update();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────

  void populateForm(StaffMember staff) {
    firstNameController.text = staff.firstname ?? '';
    lastNameController.text = staff.lastname ?? '';
    emailController.text = staff.email ?? '';
    phoneController.text = staff.phonenumber ?? '';
    positionController.text = staff.position ?? '';
    departmentController.text = staff.department ?? '';
    passwordController.clear();
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    positionController.clear();
    departmentController.clear();
    passwordController.clear();
  }

  Map<String, dynamic> _formData() {
    final data = <String, dynamic>{
      'firstname': firstNameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phonenumber': phoneController.text.trim(),
    };
    if (positionController.text.trim().isNotEmpty) {
      data['position'] = positionController.text.trim();
    }
    if (departmentController.text.trim().isNotEmpty) {
      data['department'] = departmentController.text.trim();
    }
    if (passwordController.text.isNotEmpty) {
      data['password'] = passwordController.text;
    }
    return data;
  }

  Future<bool> addStaff() async {
    if (firstNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return false;
    }
    isSubmitting = true;
    update();
    final response = await staffRepo.addStaff(_formData());
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Staff added successfully']);
      clearForm();
      await initialData(shouldLoad: false);
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
      return false;
    }
  }

  Future<bool> updateStaff(String id) async {
    if (firstNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return false;
    }
    isSubmitting = true;
    update();
    final response = await staffRepo.updateStaff(id, _formData());
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Staff updated successfully']);
      await loadDetails(id);
      await initialData(shouldLoad: false);
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
      return false;
    }
  }

  Future<void> changeStatus(String id, bool activate) async {
    isSubmitting = true;
    update();
    final response =
        await staffRepo.changeStaffStatus(id, activate ? '1' : '0');
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(
          successList: [activate ? 'Staff activated' : 'Staff deactivated']);
      await initialData(shouldLoad: false);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<bool> deleteStaff(String id) async {
    isSubmitting = true;
    update();
    final response = await staffRepo.deleteStaff(id);
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Staff deleted successfully']);
      await initialData(shouldLoad: false);
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
      return false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    positionController.dispose();
    departmentController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

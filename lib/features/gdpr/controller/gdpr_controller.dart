import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/gdpr/model/gdpr_model.dart';
import 'package:flutex_admin/features/gdpr/repo/gdpr_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GdprController extends GetxController {
  GdprRepo gdprRepo;
  GdprController({required this.gdprRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  GdprPurposesModel purposesModel = GdprPurposesModel();
  GdprRemovalRequestsModel removalRequestsModel = GdprRemovalRequestsModel();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  Future<void> loadPurposes() async {
    isLoading = true;
    update();
    final res = await gdprRepo.getPurposes();
    purposesModel = res.status
        ? GdprPurposesModel.fromJson(jsonDecode(res.responseJson))
        : GdprPurposesModel();
    isLoading = false;
    update();
  }

  Future<void> loadRemovalRequests() async {
    isLoading = true;
    update();
    final res = await gdprRepo.getRemovalRequests();
    removalRequestsModel = res.status
        ? GdprRemovalRequestsModel.fromJson(jsonDecode(res.responseJson))
        : GdprRemovalRequestsModel();
    isLoading = false;
    update();
  }

  Future<void> addPurpose() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await gdprRepo.addPurpose({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadPurposes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deletePurpose(String id) async {
    final res = await gdprRepo.deletePurpose(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadPurposes();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> markRequestProcessed(String id) async {
    final res = await gdprRepo.updateRemovalRequest(id, {'status': '1'});
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadRemovalRequests();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  void clearForm() {
    nameController.clear();
    descController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }
}

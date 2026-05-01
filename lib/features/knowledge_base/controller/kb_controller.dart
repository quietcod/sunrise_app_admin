import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/knowledge_base/model/kb_model.dart';
import 'package:flutex_admin/features/knowledge_base/repo/kb_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KbController extends GetxController {
  KbRepo kbRepo;
  KbController({required this.kbRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;

  KbGroupsModel groupsModel = KbGroupsModel();
  KbArticlesModel articlesModel = KbArticlesModel();

  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final descController = TextEditingController();
  String? selectedGroupId;

  Future<void> loadGroups() async {
    isLoading = true;
    update();
    final res = await kbRepo.getGroups();
    groupsModel = res.status
        ? KbGroupsModel.fromJson(jsonDecode(res.responseJson))
        : KbGroupsModel();
    isLoading = false;
    update();
  }

  Future<void> loadArticles({String? groupId}) async {
    isLoading = true;
    update();
    final res = await kbRepo.getArticles(groupId: groupId);
    articlesModel = res.status
        ? KbArticlesModel.fromJson(jsonDecode(res.responseJson))
        : KbArticlesModel();
    isLoading = false;
    update();
  }

  Future<void> addGroup() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await kbRepo.addGroup({'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateGroup(String id) async {
    isSubmitLoading = true;
    update();
    final res =
        await kbRepo.updateGroup(id, {'name': nameController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteGroup(String id) async {
    final res = await kbRepo.deleteGroup(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadGroups();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> addArticle() async {
    if (subjectController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await kbRepo.addArticle({
      'subject': subjectController.text.trim(),
      'description': descController.text.trim(),
      if (selectedGroupId != null) 'group_id': selectedGroupId,
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadArticles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> updateArticle(String id) async {
    isSubmitLoading = true;
    update();
    final res = await kbRepo.updateArticle(id, {
      'subject': subjectController.text.trim(),
      'description': descController.text.trim(),
      if (selectedGroupId != null) 'group_id': selectedGroupId,
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await loadArticles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteArticle(String id) async {
    final res = await kbRepo.deleteArticle(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadArticles();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  void clearForm() {
    nameController.clear();
    subjectController.clear();
    descController.clear();
    selectedGroupId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    subjectController.dispose();
    descController.dispose();
    super.onClose();
  }
}

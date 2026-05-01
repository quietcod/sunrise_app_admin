import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/announcement/model/announcement_model.dart';
import 'package:flutex_admin/features/announcement/repo/announcement_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementController extends GetxController {
  AnnouncementRepo announcementRepo;
  AnnouncementController({required this.announcementRepo});

  bool isLoading = true;
  bool isSubmitting = false;
  List<Announcement> announcementList = [];
  Announcement? selectedAnnouncement;

  // Form controllers
  final nameController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    messageController.dispose();
    super.onClose();
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
    final response = await announcementRepo.getAllAnnouncements();
    if (response.status) {
      final model =
          AnnouncementsModel.fromJson(jsonDecode(response.responseJson));
      announcementList = model.data ?? [];
    }
  }

  Future<void> loadDetails(String id) async {
    isLoading = true;
    update();
    final response = await announcementRepo.getAnnouncementDetails(id);
    if (response.status) {
      final json = jsonDecode(response.responseJson);
      selectedAnnouncement = Announcement.fromJson(json['data']);
    }
    isLoading = false;
    update();
  }

  Future<void> dismiss(String id) async {
    await announcementRepo.dismissAnnouncement(id);
    announcementList.removeWhere((a) => a.id == id);
    update();
  }

  void clearForm() {
    nameController.clear();
    messageController.clear();
  }

  void populateForm(Announcement ann) {
    nameController.text = ann.name ?? '';
    messageController.text = ann.message ?? '';
  }

  Future<void> addAnnouncement() async {
    if (nameController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: ['Title and message are required']);
      return;
    }

    isSubmitting = true;
    update();

    final data = {
      'name': nameController.text.trim(),
      'message': messageController.text.trim(),
      'showto': 'staff',
    };

    final response = await announcementRepo.addAnnouncement(data);
    if (response.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.announcementAddedSuccessfully.tr]);
      clearForm();
      await initialData(shouldLoad: false);
      Get.back();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitting = false;
    update();
  }

  Future<void> updateAnnouncement(String id) async {
    if (nameController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: ['Title and message are required']);
      return;
    }

    isSubmitting = true;
    update();

    final data = {
      'name': nameController.text.trim(),
      'message': messageController.text.trim(),
    };

    final response = await announcementRepo.updateAnnouncement(id, data);
    if (response.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.announcementUpdatedSuccessfully.tr]);
      clearForm();
      await initialData(shouldLoad: false);
      Get.back();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitting = false;
    update();
  }

  Future<void> deleteAnnouncement(String id) async {
    final response = await announcementRepo.deleteAnnouncement(id);
    if (response.status) {
      announcementList.removeWhere((a) => a.id == id);
      CustomSnackBar.success(
          successList: [LocalStrings.announcementDeletedSuccessfully.tr]);
      update();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/profile/model/profile_model.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileRepo profileRepo;
  ProfileController({required this.profileRepo});

  bool isLoading = true;
  bool isSubmitting = false;
  int profileImageNonce = DateTime.now().millisecondsSinceEpoch;
  ProfileModel profileModel = ProfileModel();

  // Edit profile controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final skypeController = TextEditingController();
  final facebookController = TextEditingController();
  final linkedinController = TextEditingController();

  // Change password controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    skypeController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<dynamic> loadData() async {
    ResponseModel responseModel = await profileRepo.getData();
    if (responseModel.status) {
      profileModel =
          ProfileModel.fromJson(jsonDecode(responseModel.responseJson));
      profileImageNonce = DateTime.now().millisecondsSinceEpoch;
      _populateEditControllers();
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  void _populateEditControllers() {
    final s = profileModel.data;
    if (s == null) return;
    firstNameController.text = s.firstName ?? '';
    lastNameController.text = s.lastName ?? '';
    phoneController.text = s.phoneNumber ?? '';
    skypeController.text = s.skype ?? '';
    facebookController.text = s.facebook ?? '';
    linkedinController.text = s.linkedin ?? '';
  }

  Future<void> updateProfile() async {
    isSubmitting = true;
    update();

    final data = {
      'firstname': firstNameController.text.trim(),
      'lastname': lastNameController.text.trim(),
      'phonenumber': phoneController.text.trim(),
      'skype': skypeController.text.trim(),
      'facebook': facebookController.text.trim(),
      'linkedin': linkedinController.text.trim(),
    };

    final response = await profileRepo.updateProfile(data);
    if (response.status) {
      CustomSnackBar.success(successList: ['Profile updated successfully']);
      await loadData();
      Get.back();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitting = false;
    update();
  }

  Future<void> changePassword() async {
    isSubmitting = true;
    update();

    final data = {
      'current_password': currentPasswordController.text,
      'new_password': newPasswordController.text,
      'confirm_password': confirmPasswordController.text,
    };

    final response = await profileRepo.changePassword(data);
    if (response.status) {
      CustomSnackBar.success(successList: ['Password changed successfully']);
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitting = false;
    update();
  }

  Future<void> uploadProfilePicture({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    isSubmitting = true;
    update();

    final response = await profileRepo.uploadProfilePicture(File(picked.path));
    if (response.status) {
      CustomSnackBar.success(
          successList: ['Profile picture updated successfully']);
      await loadData();
      profileImageNonce = DateTime.now().millisecondsSinceEpoch;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitting = false;
    update();
  }

  Future<void> removeProfilePicture() async {
    isSubmitting = true;
    update();
    final response = await profileRepo.removeProfilePicture();
    if (response.status) {
      CustomSnackBar.success(successList: ['Profile picture removed']);
      await loadData();
      profileImageNonce = DateTime.now().millisecondsSinceEpoch;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    isSubmitting = false;
    update();
  }
}

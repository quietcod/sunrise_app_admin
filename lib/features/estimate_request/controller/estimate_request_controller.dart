import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/estimate_request/model/estimate_request_model.dart';
import 'package:flutex_admin/features/estimate_request/repo/estimate_request_repo.dart';
import 'package:get/get.dart';

class EstimateRequestController extends GetxController {
  EstimateRequestRepo estimateRequestRepo;
  EstimateRequestController({required this.estimateRequestRepo});

  bool isLoading = true;
  bool isActionLoading = false;
  EstimateRequestsModel requestsModel = EstimateRequestsModel();

  Future<void> initialData() async {
    isLoading = true;
    update();
    final res = await estimateRequestRepo.getRequests();
    requestsModel = res.status
        ? EstimateRequestsModel.fromJson(jsonDecode(res.responseJson))
        : EstimateRequestsModel();
    isLoading = false;
    update();
  }

  Future<void> updateStatus(String id, String status) async {
    isActionLoading = true;
    update();
    final res = await estimateRequestRepo.updateStatus(id, status);
    isActionLoading = false;
    update();
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.updatedSuccessfully.tr]);
      await initialData();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> convertToEstimate(String id) async {
    isActionLoading = true;
    update();
    final res = await estimateRequestRepo.convertToEstimate(id);
    isActionLoading = false;
    update();
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.convertedToEstimate.tr]);
      await initialData();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteRequest(String id) async {
    final res = await estimateRequestRepo.deleteRequest(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await initialData();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }
}

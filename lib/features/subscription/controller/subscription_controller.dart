import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/subscription/model/subscription_model.dart';
import 'package:flutex_admin/features/subscription/repo/subscription_repo.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  SubscriptionRepo subscriptionRepo;
  SubscriptionController({required this.subscriptionRepo});

  bool isLoading = true;
  bool isActionLoading = false;
  SubscriptionsModel subscriptionsModel = SubscriptionsModel();

  Future<void> initialData() async {
    isLoading = true;
    update();
    final res = await subscriptionRepo.getSubscriptions();
    subscriptionsModel = res.status
        ? SubscriptionsModel.fromJson(jsonDecode(res.responseJson))
        : SubscriptionsModel();
    isLoading = false;
    update();
  }

  Future<void> cancelSubscription(String id) async {
    isActionLoading = true;
    update();
    final res = await subscriptionRepo.cancelSubscription(id);
    isActionLoading = false;
    update();
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.cancelledSuccessfully.tr]);
      await initialData();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteSubscription(String id) async {
    final res = await subscriptionRepo.deleteSubscription(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await initialData();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }
}

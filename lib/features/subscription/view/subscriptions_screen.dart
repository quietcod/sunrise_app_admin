import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/my_permissions.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/util.dart';
import 'package:flutex_admin/features/subscription/controller/subscription_controller.dart';
import 'package:flutex_admin/features/subscription/model/subscription_model.dart';
import 'package:flutex_admin/features/subscription/repo/subscription_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SubscriptionRepo(apiClient: Get.find()));
    final c = Get.put(SubscriptionController(subscriptionRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.initialData());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.subscriptions.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.subscriptionsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : RefreshIndicator(
                    onRefresh: controller.initialData,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      itemCount: controller.subscriptionsModel.data!.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, i) {
                        final sub = controller.subscriptionsModel.data![i];
                        return _SubscriptionCard(
                          sub: sub,
                          onCancel: (sub.status == '1' &&
                                  MyPermissions.canEditSubscriptions)
                              ? () =>
                                  _confirmCancel(context, controller, sub.id!)
                              : null,
                          onDelete: MyPermissions.canDeleteSubscriptions
                              ? () =>
                                  _confirmDelete(context, controller, sub.id!)
                              : null,
                        );
                      },
                    ),
                  ),
      );
    });
  }

  void _confirmCancel(
      BuildContext context, SubscriptionController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.cancelSubscription(id);
      },
      title: LocalStrings.cancelSubscription.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }

  void _confirmDelete(
      BuildContext context, SubscriptionController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteSubscription(id);
      },
      title: LocalStrings.deleteSubscription.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.sub, this.onCancel, this.onDelete});
  final SubscriptionItem sub;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  Color _statusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (sub.status) {
      case '1':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case '2':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade800;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          boxShadow: MyUtils.getCardShadow(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(sub.name ?? '',
                    style: regularDefault.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(sub.statusLabel,
                    style: regularSmall.copyWith(color: _statusColor(context))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if ((sub.clientName ?? '').isNotEmpty)
            Text(sub.clientName!,
                style: regularSmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color)),
          Text(
              '${sub.currency ?? ''} ${sub.amount ?? '0'} × ${sub.quantity ?? '1'}',
              style: regularSmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall!.color)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onCancel != null)
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: Text(LocalStrings.cancel.tr),
                  style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange.shade300
                              : Colors.orange.shade800),
                  onPressed: onCancel,
                ),
              if (onDelete != null)
                IconButton(
                    icon: Icon(Icons.delete_rounded,
                        size: 18, color: Theme.of(context).colorScheme.error),
                    onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

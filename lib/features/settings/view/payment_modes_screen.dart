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
import 'package:flutex_admin/features/settings/controller/settings_controller.dart';
import 'package:flutex_admin/features/settings/model/settings_models.dart';
import 'package:flutex_admin/features/settings/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentModesScreen extends StatefulWidget {
  const PaymentModesScreen({super.key});

  @override
  State<PaymentModesScreen> createState() => _PaymentModesScreenState();
}

class _PaymentModesScreenState extends State<PaymentModesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadPaymentModes());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.paymentModes.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canManageSettings)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.paymentModesModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.paymentModesModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final mode = controller.paymentModesModel.data![i];
                      return _ModeCard(
                        mode: mode,
                        onEdit: () =>
                            _showDialog(context, controller, mode: mode),
                        onDelete: () =>
                            _confirmDelete(context, controller, mode.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showDialog(BuildContext context, SettingsController controller,
      {PaymentModeItem? mode}) {
    if (mode != null) {
      controller.nameController.text = mode.name ?? '';
      controller.descController.text = mode.description ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title: Text(mode == null
              ? LocalStrings.addPaymentMode.tr
              : LocalStrings.editPaymentMode.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c.nameController,
                decoration: InputDecoration(labelText: LocalStrings.name.tr),
              ),
              TextField(
                controller: c.descController,
                decoration:
                    InputDecoration(labelText: LocalStrings.description.tr),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child: Text(LocalStrings.cancel.tr)),
            c.isSubmitLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () => mode == null
                        ? c.addPaymentMode()
                        : c.updatePaymentMode(mode.id!),
                    child: Text(LocalStrings.submit.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))),
          ],
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, SettingsController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deletePaymentMode(id);
      },
      title: LocalStrings.deletePaymentMode.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {required this.mode, required this.onEdit, required this.onDelete});
  final PaymentModeItem mode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15, vertical: Dimensions.space10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          boxShadow: MyUtils.getCardShadow(context)),
      child: Row(
        children: [
          Icon(Icons.payment_rounded,
              color:
                  mode.isActive ? Theme.of(context).primaryColor : Colors.grey,
              size: 20),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.name ?? '',
                    style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
                if ((mode.description ?? '').isNotEmpty)
                  Text(mode.description!,
                      style: regularSmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color)),
              ],
            ),
          ),
          if (MyPermissions.canManageSettings)
            IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit),
          if (MyPermissions.canManageSettings)
            IconButton(
                icon: Icon(Icons.delete_rounded,
                    size: 18, color: Theme.of(context).colorScheme.error),
                onPressed: onDelete),
        ],
      ),
    );
  }
}

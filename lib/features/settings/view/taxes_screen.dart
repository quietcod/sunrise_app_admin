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

class TaxesScreen extends StatefulWidget {
  const TaxesScreen({super.key});

  @override
  State<TaxesScreen> createState() => _TaxesScreenState();
}

class _TaxesScreenState extends State<TaxesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadTaxes());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.taxes.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canManageSettings)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showAddEditDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.taxesModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.taxesModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final tax = controller.taxesModel.data![i];
                      return _TaxCard(
                        tax: tax,
                        onEdit: () =>
                            _showAddEditDialog(context, controller, tax: tax),
                        onDelete: () =>
                            _confirmDelete(context, controller, tax.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showAddEditDialog(BuildContext context, SettingsController controller,
      {TaxItem? tax}) {
    if (tax != null) {
      controller.nameController.text = tax.name ?? '';
      controller.rateController.text = tax.taxrate ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title: Text(
              tax == null ? LocalStrings.addTax.tr : LocalStrings.editTax.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c.nameController,
                decoration: InputDecoration(labelText: LocalStrings.name.tr),
              ),
              TextField(
                controller: c.rateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: LocalStrings.taxRate.tr),
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
                    onPressed: () =>
                        tax == null ? c.addTax() : c.updateTax(tax.id!),
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
        controller.deleteTax(id);
      },
      title: LocalStrings.deleteTax.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _TaxCard extends StatelessWidget {
  const _TaxCard(
      {required this.tax, required this.onEdit, required this.onDelete});
  final TaxItem tax;
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
          Icon(Icons.percent_rounded,
              color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tax.name ?? '',
                    style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
                Text('${tax.taxrate ?? '0'}%',
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

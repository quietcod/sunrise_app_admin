import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/settings/controller/settings_controller.dart';
import 'package:flutex_admin/features/settings/model/settings_models.dart';
import 'package:flutex_admin/features/settings/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContractTypesScreen extends StatefulWidget {
  const ContractTypesScreen({super.key});

  @override
  State<ContractTypesScreen> createState() => _ContractTypesScreenState();
}

class _ContractTypesScreenState extends State<ContractTypesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadContractTypes());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Contract Types',
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              color: Colors.white,
              onPressed: () => _showAddEditDialog(context, controller),
            ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.contractTypesModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.contractTypesModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final type = controller.contractTypesModel.data![i];
                      return _ContractTypeCard(
                        item: type,
                        onEdit: () =>
                            _showAddEditDialog(context, controller, item: type),
                        onDelete: () =>
                            _confirmDelete(context, controller, type.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showAddEditDialog(BuildContext context, SettingsController controller,
      {ContractTypeItem? item}) {
    if (item != null) {
      controller.nameController.text = item.name ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title:
              Text(item == null ? 'Add Contract Type' : 'Edit Contract Type'),
          content: TextField(
            controller: c.nameController,
            decoration: InputDecoration(labelText: LocalStrings.name.tr),
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
                    onPressed: () => item == null
                        ? c.addContractType()
                        : c.updateContractType(item.id!),
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
      () async {
        Navigator.pop(context);
        await controller.deleteContractType(id);
      },
    );
  }
}

class _ContractTypeCard extends StatelessWidget {
  const _ContractTypeCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final ContractTypeItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.description_outlined,
            color: ColorResources.blueGreyColor),
        title: Text(item.name ?? '', style: semiBoldDefault),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: ColorResources.blueGreyColor),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: ColorResources.redColor),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

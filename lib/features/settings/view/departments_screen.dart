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

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadDepartments());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.departments.tr,
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
            : (controller.departmentsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.departmentsModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final dept = controller.departmentsModel.data![i];
                      return _DeptCard(
                        dept: dept,
                        onEdit: () =>
                            _showDialog(context, controller, dept: dept),
                        onDelete: () =>
                            _confirmDelete(context, controller, dept.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showDialog(BuildContext context, SettingsController controller,
      {DepartmentItem? dept}) {
    if (dept != null) {
      controller.nameController.text = dept.name ?? '';
      controller.emailController.text = dept.email ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title: Text(dept == null
              ? LocalStrings.addDepartment.tr
              : LocalStrings.editDepartment.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c.nameController,
                decoration: InputDecoration(labelText: LocalStrings.name.tr),
              ),
              TextField(
                controller: c.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: LocalStrings.email.tr),
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
                    onPressed: () => dept == null
                        ? c.addDepartment()
                        : c.updateDepartment(dept.id!),
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
        controller.deleteDepartment(id);
      },
      title: LocalStrings.deleteDepartment.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _DeptCard extends StatelessWidget {
  const _DeptCard(
      {required this.dept, required this.onEdit, required this.onDelete});
  final DepartmentItem dept;
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
          Icon(Icons.corporate_fare_rounded,
              color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dept.name ?? '',
                    style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
                if ((dept.email ?? '').isNotEmpty)
                  Text(dept.email!,
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

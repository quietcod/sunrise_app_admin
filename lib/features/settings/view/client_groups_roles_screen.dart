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

class ClientGroupsScreen extends StatefulWidget {
  const ClientGroupsScreen({super.key});

  @override
  State<ClientGroupsScreen> createState() => _ClientGroupsScreenState();
}

class _ClientGroupsScreenState extends State<ClientGroupsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadClientGroups());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.clientGroups.tr,
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
            : (controller.clientGroupsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.clientGroupsModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final group = controller.clientGroupsModel.data![i];
                      return _SimpleCard(
                        icon: Icons.group_rounded,
                        title: group.name ?? '',
                        onEdit: () =>
                            _showDialog(context, controller, group: group),
                        onDelete: () =>
                            _confirmDelete(context, controller, group.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showDialog(BuildContext context, SettingsController controller,
      {ClientGroupItem? group}) {
    if (group != null) {
      controller.nameController.text = group.name ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title: Text(group == null
              ? LocalStrings.addClientGroup.tr
              : LocalStrings.editClientGroup.tr),
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
                    onPressed: () => group == null
                        ? c.addClientGroup()
                        : c.updateClientGroup(group.id!),
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
        controller.deleteClientGroup(id);
      },
      title: LocalStrings.deleteClientGroup.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadRoles());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.roles.tr,
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
            : (controller.rolesModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.rolesModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final role = controller.rolesModel.data![i];
                      return _SimpleCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: role.name ?? '',
                        onEdit: () =>
                            _showDialog(context, controller, role: role),
                        onDelete: () =>
                            _confirmDelete(context, controller, role.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showDialog(BuildContext context, SettingsController controller,
      {RoleItem? role}) {
    if (role != null) {
      controller.nameController.text = role.name ?? '';
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => GetBuilder<SettingsController>(builder: (c) {
        return AlertDialog(
          title: Text(role == null
              ? LocalStrings.addRole.tr
              : LocalStrings.editRole.tr),
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
                    onPressed: () =>
                        role == null ? c.addRole() : c.updateRole(role.id!),
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
        controller.deleteRole(id);
      },
      title: LocalStrings.deleteRole.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard(
      {required this.icon,
      required this.title,
      required this.onEdit,
      required this.onDelete});
  final IconData icon;
  final String title;
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
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Text(title,
                style: regularDefault.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color)),
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

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
import 'package:flutex_admin/features/gdpr/controller/gdpr_controller.dart';
import 'package:flutex_admin/features/gdpr/repo/gdpr_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GdprScreen extends StatefulWidget {
  const GdprScreen({super.key});

  @override
  State<GdprScreen> createState() => _GdprScreenState();
}

class _GdprScreenState extends State<GdprScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GdprRepo(apiClient: Get.find()));
    final c = Get.put(GdprController(gdprRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.loadPurposes();
      c.loadRemovalRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GdprController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.gdpr.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canManageGdpr)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showAddPurposeDialog(context, controller),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: LocalStrings.purposes.tr),
              Tab(text: LocalStrings.removalRequests.tr),
            ],
          ),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : TabBarView(
                controller: _tabController,
                children: [
                  // Purposes tab
                  (controller.purposesModel.data?.isEmpty ?? true)
                      ? const NoDataWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.all(Dimensions.space15),
                          itemCount: controller.purposesModel.data!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, i) {
                            final p = controller.purposesModel.data![i];
                            return Container(
                              padding: const EdgeInsets.all(Dimensions.space10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.defaultRadius),
                                  boxShadow: MyUtils.getCardShadow(context)),
                              child: Row(
                                children: [
                                  Icon(Icons.privacy_tip_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name ?? '',
                                            style: regularDefault.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color)),
                                        if ((p.description ?? '').isNotEmpty)
                                          Text(p.description!,
                                              style: regularSmall.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color)),
                                      ],
                                    ),
                                  ),
                                  if (MyPermissions.canManageGdpr)
                                    IconButton(
                                      icon: Icon(Icons.delete_rounded,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      onPressed: () => _confirmDelete(
                                          context, controller, p.id!),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Removal requests tab
                  (controller.removalRequestsModel.data?.isEmpty ?? true)
                      ? const NoDataWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.all(Dimensions.space15),
                          itemCount:
                              controller.removalRequestsModel.data!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, i) {
                            final req =
                                controller.removalRequestsModel.data![i];
                            return Container(
                              padding: const EdgeInsets.all(Dimensions.space10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.defaultRadius),
                                  boxShadow: MyUtils.getCardShadow(context)),
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle_outline_rounded,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.orange.shade300
                                          : Colors.orange.shade800,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(req.email ?? '',
                                            style: regularDefault.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color)),
                                        Text(req.statusLabel,
                                            style: regularSmall.copyWith(
                                                color: req.status == '1'
                                                    ? (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.green.shade300
                                                        : Colors.green.shade700)
                                                    : (Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.orange.shade300
                                                        : Colors
                                                            .orange.shade800))),
                                      ],
                                    ),
                                  ),
                                  if (req.status != '1')
                                    TextButton(
                                      onPressed: () => controller
                                          .markRequestProcessed(req.id!),
                                      child:
                                          Text(LocalStrings.markProcessed.tr),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
      );
    });
  }

  void _showAddPurposeDialog(BuildContext context, GdprController controller) {
    controller.clearForm();
    showDialog(
      context: context,
      builder: (_) => GetBuilder<GdprController>(builder: (c) {
        return AlertDialog(
          title: Text(LocalStrings.addPurpose.tr),
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
                    onPressed: c.addPurpose,
                    child: Text(LocalStrings.submit.tr,
                        style: const TextStyle(color: Colors.white))),
          ],
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, GdprController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deletePurpose(id);
      },
      title: LocalStrings.deletePurpose.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

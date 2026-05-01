import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/invoice/controller/invoice_controller.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutex_admin/features/invoice/widget/invoice_card.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectInvoices extends StatefulWidget {
  const ProjectInvoices({super.key, required this.id});
  final String id;

  @override
  State<ProjectInvoices> createState() => _ProjectInvoicesState();
}

class _ProjectInvoicesState extends State<ProjectInvoices> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadProjectGroup(widget.id, 'invoices');
    });
  }

  void _openAdd() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(InvoiceRepo(apiClient: Get.find()));
    final invCtrl = Get.put(InvoiceController(invoiceRepo: Get.find()));
    invCtrl.fromProjectId = widget.id;
    Get.toNamed(RouteHelper.addInvoiceScreen)?.then((_) {
      Get.find<ProjectController>().loadProjectGroup(widget.id, 'invoices');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            tooltip: 'Add Invoice',
            child: const Icon(Icons.add),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : controller.invoicesModel.data?.isNotEmpty ?? false
                  ? RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        controller.loadProjectGroup(widget.id, 'invoices');
                      },
                      child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space15),
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            return InvoiceCard(
                              invoice: controller.invoicesModel.data![index],
                              isDark: isDark,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Dimensions.space10),
                          itemCount: controller.invoicesModel.data!.length),
                    )
                  : const Center(child: NoDataWidget()),
        );
      },
    );
  }
}

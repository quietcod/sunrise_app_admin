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
import 'package:flutex_admin/features/estimate_request/controller/estimate_request_controller.dart';
import 'package:flutex_admin/features/estimate_request/model/estimate_request_model.dart';
import 'package:flutex_admin/features/estimate_request/repo/estimate_request_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateRequestsScreen extends StatefulWidget {
  const EstimateRequestsScreen({super.key});

  @override
  State<EstimateRequestsScreen> createState() => _EstimateRequestsScreenState();
}

class _EstimateRequestsScreenState extends State<EstimateRequestsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(EstimateRequestRepo(apiClient: Get.find()));
    final c =
        Get.put(EstimateRequestController(estimateRequestRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.initialData());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EstimateRequestController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.estimateRequests.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.requestsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : RefreshIndicator(
                    onRefresh: controller.initialData,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      itemCount: controller.requestsModel.data!.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, i) {
                        final req = controller.requestsModel.data![i];
                        return _RequestCard(
                          request: req,
                          onUpdateStatus: MyPermissions.canEditEstimateRequests
                              ? (status) =>
                                  controller.updateStatus(req.id!, status)
                              : null,
                          onConvert: (req.status != '3' &&
                                  MyPermissions.canEditEstimateRequests)
                              ? () =>
                                  _confirmConvert(context, controller, req.id!)
                              : null,
                          onDelete: MyPermissions.canDeleteEstimateRequests
                              ? () =>
                                  _confirmDelete(context, controller, req.id!)
                              : null,
                        );
                      },
                    ),
                  ),
      );
    });
  }

  void _confirmConvert(
      BuildContext context, EstimateRequestController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.convertToEstimate(id);
      },
      title: LocalStrings.convertToEstimate.tr,
      subTitle: LocalStrings.areYouSure.tr,
    );
  }

  void _confirmDelete(
      BuildContext context, EstimateRequestController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteRequest(id);
      },
      title: LocalStrings.deleteEstimateRequest.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard(
      {required this.request,
      this.onUpdateStatus,
      this.onConvert,
      this.onDelete});
  final EstimateRequest request;
  final void Function(String)? onUpdateStatus;
  final VoidCallback? onConvert;
  final VoidCallback? onDelete;

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
                child: Text(request.subject ?? '',
                    style: regularDefault.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: request.statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(request.statusLabel,
                    style: regularSmall.copyWith(color: request.statusColor)),
              ),
            ],
          ),
          if ((request.email ?? '').isNotEmpty)
            Text(request.email!,
                style: regularSmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color)),
          if ((request.assignedName ?? '').isNotEmpty)
            Text('${LocalStrings.assignedTo.tr}: ${request.assignedName}',
                style: regularSmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color)),
          const SizedBox(height: 8),
          Row(
            children: [
              // Status dropdown
              DropdownButton<String>(
                value: request.status,
                underline: const SizedBox.shrink(),
                style: regularSmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('Pending')),
                  DropdownMenuItem(value: '1', child: Text('In Progress')),
                  DropdownMenuItem(value: '2', child: Text('Done')),
                ],
                onChanged: onUpdateStatus == null
                    ? null
                    : (v) {
                        if (v != null) onUpdateStatus!(v);
                      },
              ),
              const Spacer(),
              if (onConvert != null)
                TextButton.icon(
                  icon: const Icon(Icons.transform_rounded, size: 14),
                  label: Text(LocalStrings.convert.tr,
                      style: const TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor),
                  onPressed: onConvert,
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

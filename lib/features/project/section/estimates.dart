import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/estimate/controller/estimate_controller.dart';
import 'package:flutex_admin/features/estimate/repo/estimate_repo.dart';
import 'package:flutex_admin/features/estimate/widget/estimate_card.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectEstimates extends StatefulWidget {
  const ProjectEstimates({super.key, required this.id});
  final String id;

  @override
  State<ProjectEstimates> createState() => _ProjectEstimatesState();
}

class _ProjectEstimatesState extends State<ProjectEstimates> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadProjectGroup(widget.id, 'estimates');
    });
  }

  void _openAdd() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(EstimateRepo(apiClient: Get.find()));
    final estimateController =
        Get.put(EstimateController(estimateRepo: Get.find()));
    estimateController.fromProjectId = widget.id;
    Get.toNamed(RouteHelper.addEstimateScreen)?.then((_) {
      Get.find<ProjectController>().loadProjectGroup(widget.id, 'estimates');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            tooltip: 'Add Estimate',
            child: const Icon(Icons.add),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async {
                    await controller.loadProjectGroup(widget.id, 'estimates');
                  },
                  child: (controller.estimatesModel.data?.isNotEmpty ?? false)
                      ? ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space15),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return EstimateCard(
                              index: index,
                              estimateModel: controller.estimatesModel,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Dimensions.space10),
                          itemCount: controller.estimatesModel.data!.length,
                        )
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            Center(child: NoDataWidget()),
                          ],
                        ),
                ),
        );
      },
    );
  }
}

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectActivity extends StatefulWidget {
  const ProjectActivity({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectActivity> createState() => _ProjectActivityState();
}

class _ProjectActivityState extends State<ProjectActivity> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectActivity(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isActivityLoading) {
          return const Center(child: CustomLoader());
        }
        if (controller.projectActivityList.isEmpty) {
          return const Center(child: NoDataWidget());
        }
        return ListView.separated(
          padding: const EdgeInsets.all(Dimensions.space15),
          itemCount: controller.projectActivityList.length,
          separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (ctx, i) {
            final item = controller.projectActivityList[i];
            final staffName =
                (item['fullname'] as String? ?? '').trim().isNotEmpty
                    ? item['fullname'] as String
                    : 'Staff';
            final date = item['activity_date'] as String? ?? '';
            final description =
                item['description'] as String? ?? item['description_key'] ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 4, right: Dimensions.space10),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(description,
                            style: regularDefault.copyWith(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '$staffName  •  $date',
                          style: regularDefault.copyWith(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

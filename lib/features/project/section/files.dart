import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/project_files_model.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectFiles extends StatefulWidget {
  const ProjectFiles({super.key, required this.id});
  final String id;

  @override
  State<ProjectFiles> createState() => _ProjectFilesState();
}

class _ProjectFilesState extends State<ProjectFiles> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectGroup(widget.id, 'files');
    });
  }

  IconData _fileIcon(String fileType) {
    final type = fileType.toLowerCase();
    if (type.contains('image') ||
        type.contains('png') ||
        type.contains('jpg')) {
      return Icons.image_outlined;
    } else if (type.contains('pdf')) {
      return Icons.picture_as_pdf_outlined;
    } else if (type.contains('doc') || type.contains('word')) {
      return Icons.description_outlined;
    } else if (type.contains('xls') || type.contains('sheet')) {
      return Icons.table_chart_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: controller.submitLoading
                ? null
                : () => controller.uploadProjectFile(widget.id),
            icon: controller.submitLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file),
            label: Text(controller.submitLoading ? 'Uploading...' : 'Upload'),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : controller.projectFilesModel.data?.isNotEmpty ?? false
                  ? RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        controller.loadProjectGroup(widget.id, 'files');
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.space15),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.projectFilesModel.data!.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Dimensions.space10),
                        itemBuilder: (context, index) {
                          final file =
                              controller.projectFilesModel.data![index];
                          return _FileCard(
                            file: file,
                            icon: _fileIcon(file.fileType),
                          );
                        },
                      ),
                    )
                  : const Center(child: NoDataWidget()),
        );
      },
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.icon});
  final ProjectFile file;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName.isNotEmpty ? file.fileName : file.subject,
                  style: regularDefault.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (file.dateAdded.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(file.dateAdded,
                      style: regularSmall.copyWith(
                          color: ColorResources.contentTextColor,
                          fontSize: 11)),
                ],
              ],
            ),
          ),
          if (file.externalLink != null && file.externalLink!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                final uri = Uri.tryParse(file.externalLink!);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }
}

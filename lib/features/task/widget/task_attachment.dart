import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutex_admin/features/task/model/task_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskAttachments extends StatelessWidget {
  const TaskAttachments({
    super.key,
    required this.taskModel,
  });
  final TaskDetails taskModel;

  String _attachmentUrl(String taskId, Attachments a) {
    final ext = a.externalLink;
    if (ext != null && ext.isNotEmpty) return ext;
    final fileName = a.fileName ?? '';
    if (fileName.isEmpty) return '';
    return '${UrlContainer.domainUrl}uploads/tasks/$taskId/$fileName';
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final taskId = taskModel.id?.toString() ?? '';
    final hasItems =
        taskModel.attachments != null && taskModel.attachments!.isNotEmpty;
    return GetBuilder<TaskController>(builder: (controller) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 80),
            child: hasItems
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      final attachment = taskModel.attachments![index];
                      final attachmentId = attachment.id?.toString() ?? '';
                      final url = _attachmentUrl(taskId, attachment);
                      return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Dimensions.cardRadius),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withValues(alpha: 0.05),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                                Converter.fileType(attachment.fileType ?? '')),
                            title: Text(
                              attachment.fileName ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              attachment.fileType ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: lightSmall.copyWith(
                                  color: ColorResources.blueGreyColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Open / Download',
                                  icon: const Icon(Icons.download),
                                  onPressed:
                                      url.isEmpty ? null : () => _openUrl(url),
                                ),
                                if (attachmentId.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.85),
                                        size: 20),
                                    onPressed: () => _confirmDelete(
                                        context,
                                        taskId,
                                        attachmentId,
                                        attachment.fileName ?? ''),
                                  ),
                              ],
                            ),
                          ));
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Dimensions.space10),
                    itemCount: taskModel.attachments!.length)
                : const NoDataWidget(),
          ),
          Positioned(
            right: Dimensions.space15,
            bottom: Dimensions.space15,
            child: FloatingActionButton.extended(
              heroTag: 'upload_attachment_fab',
              onPressed: controller.isAttachmentUploading
                  ? null
                  : () => controller.uploadTaskAttachment(taskId),
              icon: controller.isAttachmentUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_file),
              label: Text(controller.isAttachmentUploading
                  ? 'Uploading...'
                  : 'Upload File'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    });
  }

  void _confirmDelete(BuildContext context, String taskId, String attachmentId,
      String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: Text('Delete "$fileName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<TaskController>()
                  .deleteTaskAttachment(taskId, attachmentId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

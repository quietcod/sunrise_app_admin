import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerAttachmentsTab extends StatefulWidget {
  const CustomerAttachmentsTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerAttachmentsTab> createState() => _CustomerAttachmentsTabState();
}

class _CustomerAttachmentsTabState extends State<CustomerAttachmentsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerAttachments(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      return Stack(
        children: [
          controller.isAttachmentsLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.customerAttachmentsList.isEmpty
                  ? const NoDataWidget()
                  : ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      itemCount: controller.customerAttachmentsList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, index) {
                        final attachment =
                            controller.customerAttachmentsList[index];
                        final fileName = attachment['file_name'] ??
                            attachment['filename'] ??
                            'File';
                        final fileUrl =
                            attachment['file_url'] ?? attachment['url'] ?? '';
                        final attachmentId = attachment['id']?.toString() ?? '';
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: Text(fileName.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (fileUrl.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.download_outlined),
                                    tooltip: 'Download',
                                    onPressed: () async {
                                      final uri = Uri.parse(fileUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Attachment'),
                                        content: const Text(
                                            'Are you sure you want to delete this attachment?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await controller.deleteCustomerAttachment(
                                          widget.clientId, attachmentId);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          Positioned(
            bottom: Dimensions.space15,
            right: Dimensions.space15,
            child: FloatingActionButton(
              onPressed: controller.isSubmitLoading
                  ? null
                  : () => controller.uploadCustomerAttachment(widget.clientId),
              child: controller.isSubmitLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
            ),
          ),
        ],
      );
    });
  }
}

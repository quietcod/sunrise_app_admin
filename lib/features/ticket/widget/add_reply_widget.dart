import 'package:flutter/material.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:get/get.dart';

class AddReplyWidget extends StatefulWidget {
  final String ticketId;

  const AddReplyWidget({super.key, required this.ticketId});

  @override
  State<AddReplyWidget> createState() => _AddReplyWidgetState();
}

class _AddReplyWidgetState extends State<AddReplyWidget> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(Dimensions.space8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.comment_outlined,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: Dimensions.space8),
                  Text(
                    'Add Reply',
                    style: regularDefault.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space12),
              TextField(
                controller: _replyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your reply here...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(Dimensions.space12),
                ),
              ),
              const SizedBox(height: Dimensions.space12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isReplySubmitting
                      ? null
                      : () async {
                          bool success = await controller.addReply(
                            widget.ticketId,
                            _replyController.text,
                          );
                          if (success) {
                            _replyController.clear();
                          }
                        },
                  icon: controller.isReplySubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    controller.isReplySubmitting
                        ? 'Submitting...'
                        : 'Submit Reply',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

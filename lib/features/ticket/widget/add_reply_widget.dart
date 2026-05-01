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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171A24) : Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.space12),
            border: Border.all(
              color: isDark ? const Color(0xFF34384A) : const Color(0xFFD9DFEA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
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
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space12),
              // Predefined replies picker
              _PredefinedRepliesButton(replyController: _replyController),
              const SizedBox(height: Dimensions.space8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10131C)
                      : const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(Dimensions.space10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2B3142)
                        : const Color(0xFFD5DDEA),
                  ),
                ),
                child: TextField(
                  controller: _replyController,
                  maxLines: 6,
                  minLines: 5,
                  style: regularDefault.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your reply here...',
                    hintStyle: regularDefault.copyWith(
                      color: isDark
                          ? const Color(0xFF7F879B)
                          : const Color(0xFF8A94A6),
                    ),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.all(Dimensions.space15),
                  ),
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
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.space30),
                    ),
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

// ── Predefined replies picker ─────────────────────────────────────────────────
class _PredefinedRepliesButton extends StatefulWidget {
  const _PredefinedRepliesButton({required this.replyController});
  final TextEditingController replyController;

  @override
  State<_PredefinedRepliesButton> createState() =>
      _PredefinedRepliesButtonState();
}

class _PredefinedRepliesButtonState extends State<_PredefinedRepliesButton> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketController>(builder: (controller) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.bookmark_outline, size: 16),
          label:
              const Text('Predefined Replies', style: TextStyle(fontSize: 13)),
          onPressed: () async {
            await controller.loadPredefinedReplies();
            if (!context.mounted) return;
            if (controller.predefinedReplies.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No predefined replies found.')),
              );
              return;
            }
            final selected = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              builder: (ctx) => DraggableScrollableSheet(
                initialChildSize: 0.5,
                maxChildSize: 0.85,
                minChildSize: 0.3,
                expand: false,
                builder: (_, scrollCtrl) => Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text('Predefined Replies',
                          style: regularDefault.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollCtrl,
                        itemCount: controller.predefinedReplies.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final r = controller.predefinedReplies[i];
                          return ListTile(
                            leading: const Icon(Icons.bookmark_outline,
                                size: 18, color: Colors.blue),
                            title: Text(r['name']?.toString() ?? 'Reply',
                                style: regularDefault.copyWith(fontSize: 13)),
                            subtitle: r['message'] != null
                                ? Text(
                                    r['message'].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: regularSmall.copyWith(
                                        color: Colors.grey),
                                  )
                                : null,
                            onTap: () => Navigator.pop(ctx, r),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (selected != null && selected['message'] != null) {
              widget.replyController.text = selected['message'].toString();
            }
          },
        ),
      );
    });
  }
}

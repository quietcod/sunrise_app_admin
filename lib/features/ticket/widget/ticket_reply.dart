import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/features/ticket/model/ticket_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketReplies extends StatelessWidget {
  const TicketReplies({
    super.key,
    required this.reply,
    required this.ticketId,
  });
  final TicketReply reply;
  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE9EEF8) : const Color(0xFF233247);
    final subtleText =
        isDark ? const Color(0xFFBCC8DA) : const Color(0xFF4F6079);

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF343434) : Colors.white)
            .withValues(alpha: isDark ? 0.72 : 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3750) : const Color(0xFFD6E1EF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Converter.parseHtmlString(reply.message ?? ''),
            style: regularDefault.copyWith(color: textColor),
          ),
          reply.attachments?.isNotEmpty ?? false
              ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.space5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                            imageUrl:
                                '${UrlContainer.ticketAttachmentUrl}/${reply.attachments![index].id}/${reply.attachments![index].fileName}',
                            height: 200,
                            errorWidget: (ctx, object, trx) {
                              return Image.asset(MyImages.noDataFound,
                                  height: 30);
                            },
                            placeholder: (ctx, trx) {
                              return Image.asset(
                                MyImages.noDataFound,
                                height: 30,
                                color: Colors.grey,
                              );
                            });
                      },
                      itemCount: reply.attachments!.length),
                )
              : const SizedBox.shrink(),
          const CustomDivider(space: Dimensions.space10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextIcon(
                text: reply.submitter ?? '',
                icon: Icons.account_box_rounded,
                textStyle: regularSmall.copyWith(color: subtleText),
              ),
              Row(
                children: [
                  TextIcon(
                    text: DateConverter.formatValidityDate(reply.date ?? ''),
                    icon: Icons.calendar_month,
                    textStyle: regularSmall.copyWith(color: subtleText),
                  ),
                  const SizedBox(width: Dimensions.space8),
                  _ReplyActions(reply: reply, ticketId: ticketId),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ReplyActions extends StatelessWidget {
  const _ReplyActions({required this.reply, required this.ticketId});
  final TicketReply reply;
  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final replyId = reply.id;
    if (replyId == null || replyId.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showEditDialog(context, replyId),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.edit_outlined, size: 16),
          ),
        ),
        InkWell(
          onTap: () => _confirmDelete(context, replyId),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child:
                Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, String replyId) {
    final controller = TextEditingController(
        text: Converter.parseHtmlString(reply.message ?? ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Enter reply...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<TicketController>()
                  .editReply(ticketId, replyId, controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String replyId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<TicketController>().deleteReply(ticketId, replyId);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

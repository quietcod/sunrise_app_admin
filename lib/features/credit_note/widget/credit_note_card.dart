import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/credit_note/model/credit_note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreditNoteCard extends StatelessWidget {
  const CreditNoteCard({super.key, required this.note, required this.isDark});

  final CreditNote note;
  final bool isDark;

  Color _statusColor(String? status) {
    switch (status) {
      case '1':
        return ColorResources.secondaryColor;
      case '2':
        return const Color(0xFF4CAF50);
      case '3':
        return ColorResources.colorGrey;
      default:
        return ColorResources.blueGreyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(note.status);
    final darkBase = const Color(0xFF343434);
    final lightBase = Colors.white;

    Color blend(Color fg, Color bg, double a) =>
        Color.alphaBlend(fg.withValues(alpha: a), bg);

    final start = isDark
        ? blend(statusColor, darkBase, .18)
        : blend(statusColor, lightBase, .08);
    final end = isDark
        ? blend(statusColor, darkBase, .28)
        : blend(statusColor, lightBase, .16);
    final border = isDark
        ? blend(statusColor, darkBase, .45)
        : blend(statusColor, lightBase, .28);
    final shadow = statusColor.withValues(alpha: isDark ? .16 : .12);
    final iconBg = isDark
        ? blend(statusColor, darkBase, .30)
        : blend(statusColor, lightBase, .18);
    final titleC =
        isDark ? Colors.white : blend(statusColor, Colors.black, .60);
    final bodyC = isDark
        ? Colors.white.withValues(alpha: .80)
        : blend(statusColor, Colors.black, .44);
    final chipBg = isDark
        ? blend(statusColor, darkBase, .32)
        : blend(statusColor, lightBase, .20);

    return GestureDetector(
      onTap: () =>
          Get.toNamed(RouteHelper.creditNoteDetailsScreen, arguments: note.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, end],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                    color: shadow, offset: const Offset(0, 8), blurRadius: 20)
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.credit_card_outlined,
                          size: 20, color: statusColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.formattedNumber,
                              style: semiBoldDefault.copyWith(
                                  color: titleC, fontSize: 14)),
                          Text(note.clientName ?? '',
                              style: regularSmall.copyWith(color: bodyC),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(note.statusLabel,
                          style: semiBoldSmall.copyWith(
                              color: statusColor, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: bodyC),
                    const SizedBox(width: 4),
                    Text(note.date ?? '',
                        style:
                            regularSmall.copyWith(color: bodyC, fontSize: 12)),
                    const Spacer(),
                    Text(
                      '${note.currencySymbol ?? ''}${note.total ?? '0'}',
                      style: boldLarge.copyWith(color: titleC, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

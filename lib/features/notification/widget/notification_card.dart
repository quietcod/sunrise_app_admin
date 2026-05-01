import 'dart:ui';

import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/notification/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.isDark,
    this.onMarkRead,
  });

  final NotificationItem item;
  final bool isDark;
  final VoidCallback? onMarkRead;

  IconData _iconForDescription(String? desc) {
    if (desc == null) return Icons.notifications_outlined;
    final d = desc.toLowerCase();
    if (d.contains('invoice')) return Icons.receipt_long_outlined;
    if (d.contains('payment')) return Icons.account_balance_wallet_outlined;
    if (d.contains('ticket')) return Icons.confirmation_number_outlined;
    if (d.contains('task')) return Icons.task_alt_outlined;
    if (d.contains('project')) return Icons.work_outline;
    if (d.contains('lead')) return Icons.trending_up_outlined;
    if (d.contains('estimate')) return Icons.add_chart_outlined;
    if (d.contains('proposal')) return Icons.document_scanner_outlined;
    if (d.contains('contract')) return Icons.article_outlined;
    if (d.contains('expense')) return Icons.money_off_outlined;
    if (d.contains('credit')) return Icons.credit_card_outlined;
    if (d.contains('reminder')) return Icons.alarm_outlined;
    if (d.contains('comment') || d.contains('reply')) {
      return Icons.chat_bubble_outline;
    }
    return Icons.notifications_outlined;
  }

  Color _colorForDescription(String? desc) {
    if (desc == null) return const Color(0xFF5C9BD6);
    final d = desc.toLowerCase();
    if (d.contains('invoice') || d.contains('payment')) {
      return const Color(0xFF4CAF50);
    }
    if (d.contains('ticket')) return const Color(0xFFFF9800);
    if (d.contains('task')) return const Color(0xFF9C27B0);
    if (d.contains('project')) return const Color(0xFF2196F3);
    if (d.contains('lead')) return const Color(0xFF00BCD4);
    return const Color(0xFF5C9BD6);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = item.isUnread;
    final iconColor = _colorForDescription(item.description);
    final icon = _iconForDescription(item.description);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUnread
                ? (isDark
                    ? const Color(0xFF1A2840).withValues(alpha: .75)
                    : const Color(0xFFE8F4FF).withValues(alpha: .85))
                : (isDark
                    ? const Color(0xFF343434).withValues(alpha: .55)
                    : const Color(0xFFFFFFFF).withValues(alpha: .55)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? iconColor.withValues(alpha: .35)
                  : (isDark ? const Color(0xFF4A5C79) : const Color(0xFFFFFFFF))
                      .withValues(alpha: .5),
              width: isUnread ? 1.2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: semiBoldDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.date),
                      style: regularSmall.copyWith(
                        color: ColorResources.contentTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread && onMarkRead != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onMarkRead,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.done_rounded, size: 16, color: iconColor),
                  ),
                ),
              ],
              if (isUnread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

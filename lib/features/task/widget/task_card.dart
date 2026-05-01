import 'dart:ui';

import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isDark,
  });

  final Task task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = ColorResources.taskStatusColor(task.status ?? '');
    final priorityColor = ColorResources.taskPriorityColor(task.priority ?? '');

    final taskName = task.name ?? '';
    final projectName = task.projectData?.name ?? '';
    final statusLabel = Converter.taskStatusString(task.status ?? '');
    final priorityLabel = Converter.taskPriorityString(task.priority ?? '');
    final dateLabel = DateConverter.formatValidityDate(task.dateAdded ?? '');
    final dueDate = task.dueDate ?? '';

    final bgColor = isDark ? const Color(0xFF343434) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1F2E);
    final bodyColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF2A3347).withValues(alpha: 0.7)
        : const Color(0xFFE2E8F0);
    final iconBg =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9);
    final chipBg =
        isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF8FAFC);

    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.taskDetailsScreen, arguments: task.id!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.blueGrey)
                      .withValues(alpha: isDark ? 0.25 : 0.07),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon + name + priority badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.task_alt_rounded,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              taskName,
                              style: semiBoldLarge.copyWith(color: titleColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (projectName.isNotEmpty)
                              Text(
                                projectName,
                                style: regularSmall.copyWith(color: bodyColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: regularSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (priorityLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                priorityLabel,
                                style: regularSmall.copyWith(
                                    color: priorityColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space10),
                  // Bottom row: date added + due date
                  Row(
                    children: [
                      _MetaItem(
                        icon: Icons.calendar_today_outlined,
                        label: dateLabel,
                        color: bodyColor,
                      ),
                      if (dueDate.isNotEmpty) ...[
                        const SizedBox(width: Dimensions.space15),
                        _MetaItem(
                          icon: Icons.event_busy_outlined,
                          label:
                              'Due: ${DateConverter.formatValidityDate(dueDate)}',
                          color: bodyColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: regularSmall.copyWith(color: color)),
      ],
    );
  }
}

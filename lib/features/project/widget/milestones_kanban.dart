import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/model/milestones_model.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Read-only kanban board where each column is a project milestone
/// (plus an "Uncategorized" column for tasks with no milestone).
class MilestonesKanban extends StatelessWidget {
  const MilestonesKanban({
    super.key,
    required this.milestones,
    required this.tasks,
  });

  final List<MilestoneEntry> milestones;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty && tasks.isEmpty) {
      return const Center(child: Text('No milestones or tasks'));
    }

    final uncategorized = tasks.where((t) {
      final mid = t.milestone?.toString() ?? '';
      return mid.isEmpty || mid == '0';
    }).toList();

    final columns = <_KanbanColumnData>[
      ...milestones.map((m) {
        final colTasks = tasks
            .where((t) => (t.milestone?.toString() ?? '') == (m.id ?? ''))
            .toList();
        return _KanbanColumnData(
          title: m.name ?? 'Milestone',
          color: _parseColor(m.color, Theme.of(context).primaryColor),
          subtitle: m.dueDate ?? '',
          tasks: colTasks,
        );
      }),
      if (uncategorized.isNotEmpty)
        _KanbanColumnData(
          title: 'Uncategorized',
          color: Colors.grey,
          subtitle: '',
          tasks: uncategorized,
        ),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Dimensions.space12),
      itemCount: columns.length,
      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.space12),
      itemBuilder: (ctx, i) => _MilestoneColumn(data: columns[i]),
    );
  }

  static Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

class _KanbanColumnData {
  _KanbanColumnData({
    required this.title,
    required this.color,
    required this.subtitle,
    required this.tasks,
  });
  final String title;
  final Color color;
  final String subtitle;
  final List<Task> tasks;
}

class _MilestoneColumn extends StatelessWidget {
  const _MilestoneColumn({required this.data});
  final _KanbanColumnData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.space10)),
              border: Border(
                top: BorderSide(color: data.color, width: 2),
                left: BorderSide(
                    color: data.color.withValues(alpha: 0.3), width: 0.5),
                right: BorderSide(
                    color: data.color.withValues(alpha: 0.3), width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(data.title,
                          style: semiBoldDefault.copyWith(color: data.color),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space8,
                          vertical: Dimensions.space4),
                      decoration: BoxDecoration(
                        color: data.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${data.tasks.length}',
                          style: regularSmall.copyWith(color: data.color)),
                    ),
                  ],
                ),
                if (data.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(data.subtitle,
                      style: regularSmall.copyWith(
                          color: data.color.withValues(alpha: 0.85),
                          fontSize: 10)),
                ],
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF12181E) : const Color(0xFFF2F5FA),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(Dimensions.space10)),
                border: Border(
                  bottom: BorderSide(
                      color: data.color.withValues(alpha: 0.3), width: 0.5),
                  left: BorderSide(
                      color: data.color.withValues(alpha: 0.3), width: 0.5),
                  right: BorderSide(
                      color: data.color.withValues(alpha: 0.3), width: 0.5),
                ),
              ),
              child: data.tasks.isEmpty
                  ? Center(
                      child: Text('No tasks',
                          style: regularSmall.copyWith(color: Colors.grey)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space8),
                      itemCount: data.tasks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space8),
                      itemBuilder: (ctx, idx) =>
                          _MilestoneTaskCard(task: data.tasks[idx]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneTaskCard extends StatelessWidget {
  const _MilestoneTaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = ColorResources.taskStatusColor(task.status ?? '');
    final statusLabel = Converter.taskStatusString(task.status ?? '');

    return GestureDetector(
      onTap: () =>
          Get.toNamed(RouteHelper.taskDetailsScreen, arguments: task.id!),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2430) : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.space8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name ?? '',
              style: semiBoldDefault,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.space8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Text(
                    statusLabel,
                    style:
                        regularSmall.copyWith(color: statusColor, fontSize: 10),
                  ),
                ),
                if ((task.dueDate ?? '').isNotEmpty) ...[
                  const SizedBox(width: Dimensions.space6),
                  Icon(Icons.event_outlined,
                      size: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      task.dueDate ?? '',
                      style: regularSmall.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

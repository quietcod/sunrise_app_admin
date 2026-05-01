import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kanban board for tasks grouped by status.
class TaskKanban extends StatelessWidget {
  const TaskKanban({super.key, required this.tasks});
  final List<Task> tasks;

  static const _statusOrder = ['1', '2', '3', '4', '5'];

  Map<String, List<Task>> _groupByStatus() {
    final map = <String, List<Task>>{};
    for (final status in _statusOrder) {
      map[Converter.taskStatusString(status)] = [];
    }
    for (final task in tasks) {
      final label = Converter.taskStatusString(task.status ?? '');
      map.putIfAbsent(label, () => []).add(task);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByStatus();
    final columns = grouped.keys.toList();

    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Dimensions.space12),
      itemCount: columns.length,
      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.space12),
      itemBuilder: (context, i) {
        final status = columns[i];
        final items = grouped[status]!;
        final statusCode = _statusOrder.length > i ? _statusOrder[i] : '';
        return _TaskKanbanColumn(
          status: status,
          tasks: items,
          statusColor: ColorResources.taskStatusColor(statusCode),
        );
      },
    );
  }
}

class _TaskKanbanColumn extends StatelessWidget {
  const _TaskKanbanColumn({
    required this.status,
    required this.tasks,
    required this.statusColor,
  });
  final String status;
  final List<Task> tasks;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.space10)),
              border: Border(
                  top: BorderSide(color: statusColor, width: 2),
                  left: BorderSide(
                      color: statusColor.withOpacity(0.3), width: 0.5),
                  right: BorderSide(
                      color: statusColor.withOpacity(0.3), width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(status,
                      style: semiBoldDefault.copyWith(color: statusColor),
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${tasks.length}',
                      style: regularSmall.copyWith(color: statusColor)),
                ),
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
                        color: statusColor.withOpacity(0.3), width: 0.5),
                    left: BorderSide(
                        color: statusColor.withOpacity(0.3), width: 0.5),
                    right: BorderSide(
                        color: statusColor.withOpacity(0.3), width: 0.5)),
              ),
              child: tasks.isEmpty
                  ? Center(
                      child: Text('Empty',
                          style: regularSmall.copyWith(color: Colors.grey)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space8),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space8),
                      itemBuilder: (ctx, idx) =>
                          _TaskKanbanCard(task: tasks[idx]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskKanbanCard extends StatelessWidget {
  const _TaskKanbanCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = ColorResources.taskPriorityColor(task.priority ?? '');
    final priorityLabel = Converter.taskPriorityString(task.priority ?? '');

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
              color: Colors.black.withOpacity(0.06),
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
            if ((task.projectData?.name ?? '').isNotEmpty) ...[
              const SizedBox(height: Dimensions.space4),
              Row(
                children: [
                  Icon(Icons.folder_outlined,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: Dimensions.space4),
                  Expanded(
                    child: Text(
                      task.projectData!.name ?? '',
                      style: regularSmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Dimensions.space8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: priorityColor.withOpacity(0.5), width: 0.5),
                  ),
                  child: Text(
                    priorityLabel,
                    style: regularSmall.copyWith(
                        color: priorityColor, fontSize: 10),
                  ),
                ),
                if ((task.dueDate ?? '').isNotEmpty) ...[
                  const SizedBox(width: Dimensions.space6),
                  Icon(Icons.schedule_outlined,
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

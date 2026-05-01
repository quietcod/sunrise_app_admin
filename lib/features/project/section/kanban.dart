import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kanban board for project tasks — tasks grouped by status in horizontal columns.
class ProjectKanban extends StatefulWidget {
  const ProjectKanban({super.key, required this.id});
  final String id;

  @override
  State<ProjectKanban> createState() => _ProjectKanbanState();
}

class _ProjectKanbanState extends State<ProjectKanban> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectGroup(widget.id, 'tasks');
    });
  }

  static const _statusOrder = ['1', '2', '3', '4', '5'];
  static const _statusLabels = {
    '1': 'Not Started',
    '2': 'Awaiting Feedback',
    '3': 'Testing',
    '4': 'In Progress',
    '5': 'Completed',
  };

  Map<String, List<Task>> _groupByStatus(List<Task>? tasks) {
    final map = <String, List<Task>>{
      for (final s in _statusOrder) s: [],
    };
    for (final t in tasks ?? []) {
      final s = t.status ?? '1';
      map.putIfAbsent(s, () => []).add(t);
      if (_statusOrder.contains(s)) map[s]!.add(t); // already added above
    }
    // Undo the double-add: rebuild cleanly
    final clean = <String, List<Task>>{
      for (final s in _statusOrder) s: [],
    };
    for (final t in tasks ?? []) {
      final s = t.status ?? '1';
      clean.putIfAbsent(s, () => []).add(t);
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isLoading) return const CustomLoader();
        final tasks = controller.tasksModel.data;
        if (tasks == null || tasks.isEmpty) {
          return const Center(child: NoDataWidget());
        }
        final grouped = _groupByStatus(tasks);
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async =>
              controller.loadProjectGroup(widget.id, 'tasks'),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(Dimensions.space12),
            children: _statusOrder.map((status) {
              final columnTasks = grouped[status] ?? [];
              return _KanbanColumn(
                status: status,
                label: _statusLabels[status] ?? status,
                tasks: columnTasks,
                projectId: widget.id,
                onStatusChanged: (taskId, newStatus) async {
                  await _moveTask(controller, taskId, newStatus);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _moveTask(
      ProjectController ctrl, String taskId, String newStatus) async {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TaskRepo(apiClient: Get.find()));
    final taskCtrl = Get.put(TaskController(taskRepo: Get.find()));
    await taskCtrl.changeTaskStatus(taskId, newStatus);
    await ctrl.loadProjectGroup(widget.id, 'tasks');
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.label,
    required this.tasks,
    required this.projectId,
    required this.onStatusChanged,
  });

  final String status;
  final String label;
  final List<Task> tasks;
  final String projectId;
  final void Function(String taskId, String newStatus) onStatusChanged;

  static const _statusOrder = ['1', '2', '3', '4', '5'];
  static const _statusLabels = {
    '1': 'Not Started',
    '2': 'Awaiting Feedback',
    '3': 'Testing',
    '4': 'In Progress',
    '5': 'Completed',
  };

  Color _statusColor(BuildContext context) =>
      ColorResources.taskStatusColor(status);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colBg = isDark ? const Color(0xFF1A2030) : const Color(0xFFF0F3F8);
    final headerColor = _statusColor(context);

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: Dimensions.space12),
      decoration: BoxDecoration(
        color: colBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space10),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom:
                      BorderSide(color: headerColor.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: headerColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: semiBoldDefault.copyWith(color: headerColor)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${tasks.length}',
                      style: regularSmall.copyWith(
                          color: headerColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          // Task cards
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.space20),
                      child: Text('No tasks',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space10),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _KanbanCard(
                        task: task,
                        isDark: isDark,
                        statusOrder: _statusOrder,
                        statusLabels: _statusLabels,
                        onMove: (newStatus) =>
                            onStatusChanged(task.id!, newStatus),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.task,
    required this.isDark,
    required this.statusOrder,
    required this.statusLabels,
    required this.onMove,
  });

  final Task task;
  final bool isDark;
  final List<String> statusOrder;
  final Map<String, String> statusLabels;
  final void Function(String newStatus) onMove;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF252E40) : Colors.white;
    final priorityColor = ColorResources.taskPriorityColor(task.priority ?? '');
    final priorityLabel = Converter.taskPriorityString(task.priority ?? '');

    return GestureDetector(
      onTap: () =>
          Get.toNamed(RouteHelper.taskDetailsScreen, arguments: task.id!),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(width: 3, color: priorityColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.name ?? '',
                    style: semiBoldDefault.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 16),
                  onSelected: onMove,
                  itemBuilder: (_) => statusOrder
                      .where((s) => s != task.status)
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text('→ ${statusLabels[s] ?? s}',
                                style: regularSmall),
                          ))
                      .toList(),
                ),
              ],
            ),
            if (task.dueDate != null && task.dueDate!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 11, color: ColorResources.blueGreyColor),
                  const SizedBox(width: 4),
                  Text(task.dueDate!,
                      style: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor, fontSize: 11)),
                ],
              ),
            ],
            if (priorityLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(priorityLabel,
                    style: regularSmall.copyWith(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

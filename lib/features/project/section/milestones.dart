import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/milestones_model.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/project/widget/milestones_kanban.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMilestones extends StatefulWidget {
  const ProjectMilestones({super.key, required this.id});
  final String id;

  @override
  State<ProjectMilestones> createState() => _ProjectMilestonesState();
}

class _ProjectMilestonesState extends State<ProjectMilestones> {
  bool _kanbanMode = false;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.wait([
        controller.loadProjectGroup(widget.id, 'milestones'),
        controller.loadProjectGroup(widget.id, 'tasks'),
      ]);
    });
  }

  void _showMilestoneDialog(BuildContext context, ProjectController controller,
      {MilestoneEntry? entry}) {
    final nameCtrl = TextEditingController(text: entry?.name ?? '');
    final descCtrl = TextEditingController(text: entry?.description ?? '');
    final dueDateCtrl = TextEditingController(text: entry?.dueDate ?? '');
    String selectedColor = entry?.color ?? '#6c757d';

    final colorOptions = {
      '#3c763d': Colors.green.shade700,
      '#337ab7': Colors.blue,
      '#8e44ad': Colors.purple,
      '#e74c3c': Colors.red,
      '#e67e22': Colors.orange,
      '#6c757d': Colors.grey,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(entry == null ? 'Add Milestone' : 'Edit Milestone'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dueDateCtrl.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dueDateCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Color', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: colorOptions.entries.map((e) {
                    final isSelected = selectedColor == e.key;
                    return GestureDetector(
                      onTap: () => setDlgState(() => selectedColor = e.key),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: e.value,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: e.value.withValues(alpha: 0.6),
                                      blurRadius: 4)
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                if (entry == null) {
                  controller.addMilestone(widget.id, name,
                      description: descCtrl.text.trim(),
                      color: selectedColor,
                      dueDate: dueDateCtrl.text.trim());
                } else {
                  controller.editMilestone(widget.id, entry.id!, name,
                      description: descCtrl.text.trim(),
                      color: selectedColor,
                      dueDate: dueDateCtrl.text.trim());
                }
              },
              child: Text(entry == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignTasksDialog(BuildContext context,
      ProjectController controller, MilestoneEntry milestone) {
    final milestoneId = milestone.id ?? '';
    final allTasks = controller.tasksModel.data ?? [];
    // Build initial selection: tasks whose milestone == milestoneId
    final selected = <String, bool>{};
    for (final t in allTasks) {
      final taskId = t.id?.toString() ?? '';
      final taskMilestone = t.milestone?.toString() ?? '';
      selected[taskId] = (taskMilestone == milestoneId);
    }
    final originalSelected = Map<String, bool>.from(selected);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Tasks for "${milestone.name ?? 'Milestone'}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: allTasks.isEmpty
                ? const Text('No tasks in this project')
                : ListView(
                    shrinkWrap: true,
                    children: allTasks.map((t) {
                      final taskId = t.id?.toString() ?? '';
                      final taskName = t.name ?? 'Task';
                      return CheckboxListTile(
                        dense: true,
                        value: selected[taskId] ?? false,
                        title: Text(taskName,
                            style: const TextStyle(fontSize: 13)),
                        onChanged: (v) =>
                            setDlgState(() => selected[taskId] = v ?? false),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Only update tasks that changed
                for (final t in allTasks) {
                  final taskId = t.id?.toString() ?? '';
                  final wasSelected = originalSelected[taskId] ?? false;
                  final isNowSelected = selected[taskId] ?? false;
                  if (wasSelected != isNowSelected) {
                    controller.updateTaskMilestone(
                      widget.id,
                      taskId,
                      isNowSelected ? milestoneId : null,
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isLoading) return const CustomLoader();
        final entries = controller.milestonesModel.data;
        return Stack(
          children: [
            if (_kanbanMode)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: MilestonesKanban(
                  milestones: entries ?? const [],
                  tasks: controller.tasksModel.data ?? const [],
                ),
              )
            else
              RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async =>
                    controller.loadProjectGroup(widget.id, 'milestones'),
                child: entries == null || entries.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(child: NoDataWidget()),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                            left: Dimensions.space15,
                            right: Dimensions.space15,
                            top: 50,
                            bottom: 80),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Dimensions.space10),
                        itemBuilder: (context, index) => _MilestoneCard(
                          entry: entries[index],
                          onEdit: () => _showMilestoneDialog(
                              context, controller,
                              entry: entries[index]),
                          onDelete: () => controller.deleteMilestone(
                              widget.id, entries[index].id!),
                          onAssignTasks: () => _showAssignTasksDialog(
                              context, controller, entries[index]),
                        ),
                      ),
              ),
            Positioned(
              top: 8,
              right: 12,
              child: Material(
                color: Theme.of(context).cardColor,
                shape: const CircleBorder(),
                elevation: 1,
                child: IconButton(
                  icon: Icon(
                    _kanbanMode
                        ? Icons.view_list_outlined
                        : Icons.view_kanban_outlined,
                    size: 20,
                  ),
                  tooltip: _kanbanMode ? 'List view' : 'Kanban view',
                  onPressed: () => setState(() => _kanbanMode = !_kanbanMode),
                ),
              ),
            ),
            if (!_kanbanMode)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'add_milestone_fab',
                  onPressed: () => _showMilestoneDialog(context, controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Milestone'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.onAssignTasks,
  });
  final MilestoneEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAssignTasks;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE9EEF8) : const Color(0xFF233247);
    final subtleColor =
        isDark ? const Color(0xFFBCC8DA) : const Color(0xFF4F6079);

    Color milestoneColor = Theme.of(context).primaryColor;
    if (entry.color != null && entry.color!.isNotEmpty) {
      try {
        final hex = entry.color!.replaceFirst('#', '');
        milestoneColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
            .withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
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
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: milestoneColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Dimensions.space8),
              Expanded(
                child: Text(
                  entry.name ?? 'Milestone',
                  style:
                      semiBoldDefault.copyWith(color: textColor, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: subtleColor,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.task_alt_outlined, size: 18),
                onPressed: onAssignTasks,
                tooltip: 'Assign Tasks',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: subtleColor,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.red.shade400,
              ),
            ],
          ),
          if (entry.dueDate != null && entry.dueDate!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.space8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: subtleColor),
                const SizedBox(width: 4),
                Text(entry.dueDate!,
                    style: regularSmall.copyWith(color: subtleColor)),
              ],
            ),
          ],
          if (entry.description != null && entry.description!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.space8),
            Text(
              entry.description!,
              style: regularSmall.copyWith(color: subtleColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskChecklist extends StatefulWidget {
  const TaskChecklist({super.key, required this.taskId});
  final String taskId;

  @override
  State<TaskChecklist> createState() => _TaskChecklistState();
}

class _TaskChecklistState extends State<TaskChecklist> {
  final _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TaskController>().loadChecklist(widget.taskId);
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context, controller, String itemId,
      String currentDescription) {
    final editCtrl = TextEditingController(text: currentDescription);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Item description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateChecklistItem(
                  widget.taskId, itemId, editCtrl.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, TaskController controller,
      String itemId, String? currentAssigned) async {
    final staffList = await controller.loadAllStaff();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign to Staff'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: const Text('Unassign'),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.assignChecklistItem(widget.taskId, itemId, null);
                },
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: staffList.length,
                  itemBuilder: (_, i) {
                    final s = staffList[i];
                    final isSelected = s.id?.toString() == currentAssigned;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text(
                          (s.firstname?.isNotEmpty == true
                              ? s.firstname![0]
                              : '?'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                          '${s.firstname ?? ''} ${s.lastname ?? ''}'.trim()),
                      trailing:
                          isSelected ? const Icon(Icons.check, size: 16) : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.assignChecklistItem(
                            widget.taskId, itemId, s.id?.toString());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<TaskController>(builder: (controller) {
      return Column(
        children: [
          // ── Add item input ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.space15,
              Dimensions.space15,
              Dimensions.space15,
              Dimensions.space10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'New checklist item...',
                      hintStyle: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: (isDark
                                    ? const Color(0xFF2A3347)
                                    : const Color(0xFFD0DAE8))
                                .withValues(alpha: 0.7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: (isDark
                                    ? const Color(0xFF2A3347)
                                    : const Color(0xFFD0DAE8))
                                .withValues(alpha: 0.7)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: regularDefault,
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        controller.addChecklistItem(widget.taskId, v.trim());
                        _addController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.space8),
                ElevatedButton(
                  onPressed: () {
                    final text = _addController.text.trim();
                    if (text.isNotEmpty) {
                      controller.addChecklistItem(widget.taskId, text);
                      _addController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────
          if (controller.isChecklistLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.checklistItems.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.checklist_outlined,
                        size: 48,
                        color: ColorResources.blueGreyColor
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: Dimensions.space10),
                    Text('No checklist items yet',
                        style: regularDefault.copyWith(
                            color: ColorResources.blueGreyColor)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space5),
                itemCount: controller.checklistItems.length,
                onReorder: (oldIndex, newIndex) => controller.reorderChecklist(
                    widget.taskId, oldIndex, newIndex),
                proxyDecorator: (child, index, animation) => Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                ),
                itemBuilder: (context, index) {
                  final item = controller.checklistItems[index];
                  final isFinished = item['finished']?.toString() == '1' ||
                      item['finished'] == true;
                  final itemId = item['id']?.toString() ?? '';
                  final description = item['description']?.toString() ?? '';
                  final assigned = item['assigned']?.toString();
                  final hasAssignee = assigned != null &&
                      assigned.isNotEmpty &&
                      assigned != '0';

                  return ListTile(
                    key: ValueKey(itemId),
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: isFinished,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) => controller.toggleChecklistItem(
                          widget.taskId, itemId, val ?? false),
                    ),
                    title: Text(
                      description,
                      style: regularDefault.copyWith(
                        decoration:
                            isFinished ? TextDecoration.lineThrough : null,
                        color: isFinished
                            ? ColorResources.blueGreyColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: hasAssignee
                        ? _AssigneeBadge(
                            staffId: assigned,
                            controller: controller,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.drag_handle,
                                size: 20, color: Colors.grey),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 18,
                            color: hasAssignee
                                ? Theme.of(context).primaryColor
                                : ColorResources.blueGreyColor,
                          ),
                          onPressed: () => _showAssignDialog(
                              context, controller, itemId, assigned),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18,
                              color: Colors.blueAccent.withValues(alpha: 0.8)),
                          onPressed: () => _showEditDialog(
                              context, controller, itemId, description),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent.withValues(alpha: 0.8)),
                          onPressed: () => controller.deleteChecklistItem(
                              widget.taskId, itemId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

// Small badge showing which staff member is assigned to a checklist item.
class _AssigneeBadge extends StatelessWidget {
  const _AssigneeBadge({required this.staffId, required this.controller});
  final String staffId;
  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final match = controller.allStaffList
        .where((s) => s.id?.toString() == staffId)
        .toList();
    final name = match.isNotEmpty
        ? '${match.first.firstname ?? ''} ${match.first.lastname ?? ''}'.trim()
        : 'Staff #$staffId';
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 12, color: Theme.of(context).primaryColor),
          const SizedBox(width: 3),
          Text(name,
              style: regularSmall.copyWith(
                  color: Theme.of(context).primaryColor, fontSize: 11)),
        ],
      ),
    );
  }
}

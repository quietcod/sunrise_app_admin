import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutex_admin/features/task/model/task_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskInformation extends StatefulWidget {
  const TaskInformation({
    super.key,
    required this.taskModel,
  });
  final TaskDetails taskModel;

  @override
  State<TaskInformation> createState() => _TaskInformationState();
}

class _TaskInformationState extends State<TaskInformation> {
  bool _editingDescription = false;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(
        text: Converter.parseHtmlString(widget.taskModel.description ?? ''));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDescription() async {
    setState(() => _saving = true);
    final ctrl = Get.find<TaskController>();
    await ctrl.loadTaskUpdateData(widget.taskModel.id);
    ctrl.descriptionController.text = _descCtrl.text;
    await ctrl.submitTask(taskId: widget.taskModel.id, isUpdate: true);
    if (mounted) {
      setState(() {
        _editingDescription = false;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskModel = widget.taskModel;
    return Padding(
      padding: const EdgeInsets.all(Dimensions.space10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskModel.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            taskModel.projectData?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: lightSmall.copyWith(
                                color: ColorResources.blueGreyColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _showPriorityPicker(context,
                              taskModel.id ?? '', taskModel.priority ?? ''),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ColorResources.taskPriorityColor(
                                      taskModel.priority ?? '')
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: ColorResources.taskPriorityColor(
                                      taskModel.priority ?? ''),
                                  width: 0.8),
                            ),
                            child: Text(
                                Converter.taskPriorityString(
                                    taskModel.priority ?? ''),
                                style: regularDefault.copyWith(
                                  color: ColorResources.taskPriorityColor(
                                      taskModel.priority ?? ''),
                                  fontSize: 11,
                                )),
                          ),
                        ),
                        Text(
                          taskModel.relType?.capitalizeFirst ?? '-',
                          style: lightSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showStatusPicker(
                          context, taskModel.id ?? '', taskModel.status ?? ''),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorResources.taskStatusColor(
                                  taskModel.status ?? '')
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: ColorResources.taskStatusColor(
                                  taskModel.status ?? ''),
                              width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 12,
                                color: ColorResources.taskStatusColor(
                                    taskModel.status ?? '')),
                            const SizedBox(width: 4),
                            Text(
                                Converter.taskStatusString(
                                    taskModel.status ?? ''),
                                style: regularDefault.copyWith(
                                    color: ColorResources.taskStatusColor(
                                        taskModel.status ?? ''),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    TextIcon(
                      text: DateConverter.formatValidityDate(
                          taskModel.dateAdded ?? ''),
                      icon: Icons.calendar_month,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocalStrings.description.tr, style: lightDefault),
                if (_editingDescription) ...[
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 5,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            setState(() => _editingDescription = false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saving ? null : _saveDescription,
                        icon: _saving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check, size: 16),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => setState(() => _editingDescription = true),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(Converter.parseHtmlString(
                              taskModel.description ?? '-')),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined,
                            size: 15, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ],
                const CustomDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.hourlyRate.tr, style: lightDefault),
                    Text(LocalStrings.billable.tr, style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(taskModel.hourlyRate ?? ''),
                    Text(taskModel.billable == '1'
                        ? LocalStrings.billable.tr
                        : LocalStrings.notBillable.tr),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocalStrings.checklistItems.tr),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10),
                taskModel.checklistItems!.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(
                              taskModel.checklistItems![index].description ??
                                  '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            value: taskModel.checklistItems![index].finished ==
                                '1',
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: ColorResources.secondaryColor,
                            checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            onChanged: (bool? value) {},
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Dimensions.space10),
                        itemCount: taskModel.checklistItems!.length)
                    : Text(LocalStrings.checklistNotFound.tr,
                        textAlign: TextAlign.center, style: lightSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(
      BuildContext context, String taskId, String currentStatus) {
    final Map<String, String> statuses = {
      '1': LocalStrings.notStarted.tr,
      '2': LocalStrings.awaitingFeedback.tr,
      '3': LocalStrings.testing.tr,
      '4': LocalStrings.inProgress.tr,
      '5': LocalStrings.completed.tr,
    };
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _OptionBottomSheet(
        title: LocalStrings.status.tr,
        options: statuses,
        currentKey: currentStatus,
        colorFn: ColorResources.taskStatusColor,
        onSelect: (key) {
          Navigator.pop(context);
          Get.find<TaskController>().changeTaskStatus(taskId, key);
        },
      ),
    );
  }

  void _showPriorityPicker(
      BuildContext context, String taskId, String currentPriority) {
    final Map<String, String> priorities = {
      '1': LocalStrings.priorityLow.tr,
      '2': LocalStrings.priorityMedium.tr,
      '3': LocalStrings.priorityHigh.tr,
      '4': LocalStrings.priorityUrgent.tr,
    };
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _OptionBottomSheet(
        title: LocalStrings.priority.tr,
        options: priorities,
        currentKey: currentPriority,
        colorFn: ColorResources.taskPriorityColor,
        onSelect: (key) {
          Navigator.pop(context);
          Get.find<TaskController>().changeTaskPriority(taskId, key);
        },
      ),
    );
  }
}

class _OptionBottomSheet extends StatelessWidget {
  const _OptionBottomSheet({
    required this.title,
    required this.options,
    required this.currentKey,
    required this.colorFn,
    required this.onSelect,
  });

  final String title;
  final Map<String, String> options;
  final String currentKey;
  final Color Function(String) colorFn;
  final void Function(String key) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...options.entries.map((e) {
              final selected = e.key == currentKey;
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                    radius: 6,
                    backgroundColor:
                        selected ? colorFn(e.key) : Colors.transparent,
                    child: CircleAvatar(
                        radius: 5,
                        backgroundColor:
                            selected ? colorFn(e.key) : Colors.grey.shade300)),
                title: Text(e.value,
                    style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? colorFn(e.key) : null)),
                trailing: selected
                    ? Icon(Icons.check, color: colorFn(e.key), size: 18)
                    : null,
                onTap: () => onSelect(e.key),
              );
            }),
          ],
        ),
      ),
    );
  }
}

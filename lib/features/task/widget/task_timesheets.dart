import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskTimesheets extends StatefulWidget {
  const TaskTimesheets({super.key, required this.taskId});
  final String taskId;

  @override
  State<TaskTimesheets> createState() => _TaskTimesheetsState();
}

class _TaskTimesheetsState extends State<TaskTimesheets> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TaskController>().loadTaskTimesheets(widget.taskId);
    });
  }

  String _formatDuration(String? start, String? end) {
    if (start == null) return '';
    try {
      final s = DateTime.parse(start);
      final e = end != null ? DateTime.parse(end) : DateTime.now();
      final diff = e.difference(s);
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      if (h > 0) return '${h}h ${m}m';
      return '${m}m';
    } catch (_) {
      return '';
    }
  }

  void _showLogTimeDialog(BuildContext context, TaskController controller) {
    DateTime? startDt;
    DateTime? endDt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) {
        return AlertDialog(
          title: const Text('Log Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_arrow),
                title: Text(startDt == null
                    ? 'Select start date/time'
                    : DateConverter.localDateTime(startDt!)),
                onTap: () async {
                  final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now());
                  if (d == null) return;
                  final t = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.now());
                  if (t == null) return;
                  setDlgState(() {
                    startDt =
                        DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  });
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop),
                title: Text(endDt == null
                    ? 'Select end date/time'
                    : DateConverter.localDateTime(endDt!)),
                onTap: () async {
                  final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now());
                  if (d == null) return;
                  final t = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.now());
                  if (t == null) return;
                  setDlgState(() {
                    endDt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (startDt == null || endDt == null) return;
                if (endDt!.isBefore(startDt!)) return;
                Navigator.pop(ctx);
                controller.addTimeLog(
                  widget.taskId,
                  startDt!.toIso8601String(),
                  endDt!.toIso8601String(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(builder: (controller) {
      if (controller.isTimesheetsLoading) return const CustomLoader();
      final items = controller.taskTimesheetsList;

      return Stack(
        children: [
          items.isEmpty
              ? const Center(child: NoDataWidget())
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async =>
                      controller.loadTaskTimesheets(widget.taskId),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(Dimensions.space15,
                        Dimensions.space10, Dimensions.space15, 72),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space8),
                    itemBuilder: (context, index) {
                      final entry = items[index];
                      final firstName = entry['firstname']?.toString() ?? '';
                      final lastName = entry['lastname']?.toString() ?? '';
                      final staffName = '$firstName $lastName'.trim().isNotEmpty
                          ? '$firstName $lastName'.trim()
                          : 'Staff';
                      final entryId = entry['id']?.toString() ?? '';
                      final startTime = entry['start_time']?.toString() ?? '';
                      final endTime = entry['end_time']?.toString();
                      final isActive = endTime == null || endTime.isEmpty;
                      final duration = _formatDuration(
                          startTime.isEmpty ? null : startTime, endTime);

                      return Container(
                        padding: const EdgeInsets.all(Dimensions.space12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.4)
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.timer : Icons.timer_off_outlined,
                              color: isActive
                                  ? Colors.green
                                  : ColorResources.blueGreyColor,
                              size: 22,
                            ),
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staffName,
                                      style: regularDefault.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  if (startTime.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text('Start: $startTime',
                                        style: regularSmall.copyWith(
                                            color: ColorResources.blueGreyColor,
                                            fontSize: 11)),
                                  ],
                                  if (!isActive) ...[
                                    Text('End: $endTime',
                                        style: regularSmall.copyWith(
                                            color: ColorResources.blueGreyColor,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.green
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: const Text('Running',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                if (duration.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(duration,
                                      style: regularSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: ColorResources.blueGreyColor)),
                                ],
                                if (entryId.isNotEmpty && !isActive)
                                  GestureDetector(
                                    onTap: () => controller.deleteTimeLog(
                                        widget.taskId, entryId),
                                    child: Icon(Icons.delete_outline,
                                        size: 16,
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.7)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          Positioned(
            right: Dimensions.space15,
            bottom: Dimensions.space15,
            child: FloatingActionButton.extended(
              heroTag: 'log_time_fab',
              onPressed: () => _showLogTimeDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Log Time'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    });
  }
}

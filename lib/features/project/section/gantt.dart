import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Read-only Gantt chart for project tasks.
/// Renders a horizontal timeline — each task occupies a row with a bar
/// spanning its start → due date range.
class ProjectGantt extends StatefulWidget {
  const ProjectGantt({super.key, required this.id});
  final String id;

  @override
  State<ProjectGantt> createState() => _ProjectGanttState();
}

class _ProjectGanttState extends State<ProjectGantt> {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isLoading) return const CustomLoader();
        final tasks = controller.tasksModel.data;
        if (tasks == null || tasks.isEmpty) {
          return const Center(child: NoDataWidget());
        }

        // Determine timeline bounds from tasks that have dates.
        final tasksWithDates = tasks.where((t) {
          return t.startDate != null &&
              t.startDate!.isNotEmpty &&
              t.dueDate != null &&
              t.dueDate!.isNotEmpty;
        }).toList();

        if (tasksWithDates.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Text(
                'No tasks have start/due dates set.',
                style: regularDefault.copyWith(
                    color: ColorResources.blueGreyColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        DateTime minDate = DateTime.parse(tasksWithDates
            .map((t) => t.startDate!)
            .reduce((a, b) => a.compareTo(b) < 0 ? a : b));
        DateTime maxDate = DateTime.parse(tasksWithDates
            .map((t) => t.dueDate!)
            .reduce((a, b) => a.compareTo(b) > 0 ? a : b));

        // Ensure at least a 7-day range.
        if (maxDate.difference(minDate).inDays < 7) {
          maxDate = minDate.add(const Duration(days: 7));
        }

        final totalDays = maxDate.difference(minDate).inDays + 1;
        const dayWidth = 24.0; // pixels per day
        final chartWidth = totalDays * dayWidth;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            // Header row
            Container(
              color: isDark ? const Color(0xFF1A2030) : const Color(0xFFF0F3F8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _GanttHeader(
                  startDate: minDate,
                  totalDays: totalDays,
                  dayWidth: dayWidth,
                  isDark: isDark,
                ),
              ),
            ),
            // Task rows
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 180 + chartWidth,
                    child: Column(
                      children: tasksWithDates.map((task) {
                        DateTime start = DateTime.parse(task.startDate!);
                        DateTime end = DateTime.parse(task.dueDate!);
                        final startOffset = start
                            .difference(minDate)
                            .inDays
                            .clamp(0, totalDays);
                        final duration =
                            end.difference(start).inDays.clamp(1, totalDays);
                        final barColor =
                            ColorResources.taskStatusColor(task.status ?? '');

                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: (isDark
                                        ? const Color(0xFF2A3347)
                                        : const Color(0xFFE2E8F0))
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Task name
                              SizedBox(
                                width: 180,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.space10),
                                  child: Text(
                                    task.name ?? '',
                                    style:
                                        regularDefault.copyWith(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Bar area
                              Expanded(
                                child: Stack(
                                  children: [
                                    // Grid lines
                                    Row(
                                      children: List.generate(
                                        totalDays,
                                        (i) => Container(
                                          width: dayWidth,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: (isDark
                                                        ? const Color(
                                                            0xFF2A3347)
                                                        : const Color(
                                                            0xFFE2E8F0))
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Task bar
                                    Positioned(
                                      left: startOffset * dayWidth,
                                      top: 10,
                                      height: 28,
                                      width: duration * dayWidth - 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              barColor.withValues(alpha: 0.8),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Text(
                                          task.name ?? '',
                                          style: regularSmall.copyWith(
                                              color: Colors.white,
                                              fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GanttHeader extends StatelessWidget {
  const _GanttHeader({
    required this.startDate,
    required this.totalDays,
    required this.dayWidth,
    required this.isDark,
  });

  final DateTime startDate;
  final int totalDays;
  final double dayWidth;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180 + totalDays * dayWidth,
      height: 36,
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(left: Dimensions.space10),
              child: Text('Task',
                  style: regularSmall.copyWith(
                      color: ColorResources.blueGreyColor,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          ...List.generate(totalDays, (i) {
            final day = startDate.add(Duration(days: i));
            final isFirstOfMonth = day.day == 1;
            final isMonday = day.weekday == DateTime.monday;
            return Container(
              width: dayWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: (isDark
                            ? const Color(0xFF2A3347)
                            : const Color(0xFFE2E8F0))
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: (isFirstOfMonth || isMonday)
                  ? Text(
                      isFirstOfMonth ? _monthLabel(day.month) : '${day.day}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isFirstOfMonth
                            ? Theme.of(context).primaryColor
                            : ColorResources.blueGreyColor,
                        fontWeight: isFirstOfMonth
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

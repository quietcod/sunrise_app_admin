import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/timesheet_model.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeSheetWidget extends StatefulWidget {
  const TimeSheetWidget({super.key, required this.id});
  final String id;

  @override
  State<TimeSheetWidget> createState() => _TimeSheetWidgetState();
}

class _TimeSheetWidgetState extends State<TimeSheetWidget> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectGroup(widget.id, 'timesheets');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isLoading) return const CustomLoader();
        final entries = controller.timesheetsModel.data;
        if (entries == null || entries.isEmpty) {
          return const Center(child: NoDataWidget());
        }
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async =>
              controller.loadProjectGroup(widget.id, 'timesheets'),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15, vertical: Dimensions.space10),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space10),
            itemBuilder: (context, index) {
              return _TimesheetCard(entry: entries[index]);
            },
          ),
        );
      },
    );
  }
}

class _TimesheetCard extends StatelessWidget {
  const _TimesheetCard({required this.entry});
  final TimesheetEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE9EEF8) : const Color(0xFF233247);
    final subtleColor =
        isDark ? const Color(0xFFBCC8DA) : const Color(0xFF4F6079);

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
            .withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3750) : const Color(0xFFD6E1EF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.taskName?.isNotEmpty == true
                      ? entry.taskName!
                      : 'Task #${entry.taskId ?? '-'}',
                  style: semiBoldDefault.copyWith(color: textColor),
                ),
              ),
              if (entry.timeSpent?.isNotEmpty == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.timeSpent!,
                    style: regularSmall.copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
            ],
          ),
          if (entry.staffName?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: subtleColor),
                const SizedBox(width: 4),
                Text(entry.staffName!,
                    style: regularSmall.copyWith(color: subtleColor)),
              ],
            ),
          ],
          if (entry.startTime?.isNotEmpty == true ||
              entry.endTime?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: subtleColor),
                const SizedBox(width: 4),
                Text(
                  [entry.startTime, entry.endTime]
                      .where((v) => v?.isNotEmpty == true)
                      .join(' → '),
                  style: regularSmall.copyWith(color: subtleColor),
                ),
              ],
            ),
          ],
          if (entry.note?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(entry.note!, style: lightSmall.copyWith(color: subtleColor)),
          ],
        ],
      ),
    );
  }
}

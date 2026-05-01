import 'dart:ui';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/task/widget/task_attachment.dart';
import 'package:flutex_admin/features/task/widget/task_checklist.dart';
import 'package:flutex_admin/features/task/widget/task_team.dart';
import 'package:flutex_admin/features/task/widget/task_comment.dart';
import 'package:flutex_admin/features/task/widget/task_information.dart';
import 'package:flutex_admin/features/task/widget/task_reminders.dart';
import 'package:flutex_admin/features/task/widget/task_timesheets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TaskRepo(apiClient: Get.find()));
    final controller = Get.put(TaskController(taskRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadTaskDetails(widget.id);
      controller.checkTimer(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF000000), Color(0xFF000000)]
                : const [Color(0xFFEFF3F8), Color(0xFFDDE3EC)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -60,
              child: _BlurOrb(
                size: 200,
                color:
                    (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.25 : 0.62),
              ),
            ),
            Positioned(
              bottom: 160,
              right: -60,
              child: _BlurOrb(
                size: 160,
                color:
                    (isDark ? const Color(0xFF23324A) : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.2 : 0.5),
              ),
            ),
            GetBuilder<TaskController>(
              builder: (controller) {
                if (controller.isLoading ||
                    controller.taskDetailsModel.data == null) {
                  return const CustomLoader();
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                          Dimensions.space15, Dimensions.space10),
                      child: _GlassDetailHeader(
                        isDark: isDark,
                        title: LocalStrings.taskDetails.tr,
                        isTimerRunning: controller.isTimerRunning,
                        isTimerLoading: controller.isTimerLoading,
                        onEdit: () => Get.toNamed(RouteHelper.updateTaskScreen,
                            arguments: widget.id),
                        onDelete: () => const WarningAlertDialog()
                            .warningAlertDialog(context, () {
                          Get.back();
                          Get.find<TaskController>().deleteTask(widget.id);
                          Navigator.pop(context);
                        },
                                title: LocalStrings.deleteTask.tr,
                                subTitle: LocalStrings.deleteTaskWarningMSg.tr,
                                image: MyImages.exclamationImage),
                        onTimer: () {
                          final c = Get.find<TaskController>();
                          if (c.isTimerRunning) {
                            c.stopTimer(widget.id);
                          } else {
                            c.startTimer(widget.id);
                          }
                        },
                        onCopy: () =>
                            Get.find<TaskController>().copyTask(widget.id),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async =>
                            controller.loadTaskDetails(widget.id),
                        child: ContainedTabBarView(
                          tabBarProperties: TabBarProperties(
                              indicatorSize: TabBarIndicatorSize.tab,
                              unselectedLabelColor:
                                  ColorResources.blueGreyColor,
                              labelColor:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              labelStyle: regularDefault,
                              indicatorColor: ColorResources.secondaryColor,
                              labelPadding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.space15)),
                          tabs: [
                            Text(LocalStrings.taskDetails.tr),
                            Text(LocalStrings.comments.tr),
                            Text(LocalStrings.attachments.tr),
                            const Text('Checklist'),
                            const Text('Team'),
                            const Text('Timesheets'),
                            const Text('Reminders'),
                          ],
                          views: [
                            TaskInformation(
                              taskModel: controller.taskDetailsModel.data!,
                            ),
                            TaskComments(
                              taskModel: controller.taskDetailsModel.data!,
                            ),
                            TaskAttachments(
                              taskModel: controller.taskDetailsModel.data!,
                            ),
                            TaskChecklist(
                              taskId: widget.id,
                            ),
                            TaskTeam(
                              taskId: widget.id,
                            ),
                            TaskTimesheets(
                              taskId: widget.id,
                            ),
                            TaskReminders(
                              taskId: widget.id,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _GlassDetailHeader extends StatelessWidget {
  const _GlassDetailHeader(
      {required this.isDark,
      required this.title,
      required this.onEdit,
      required this.onDelete,
      required this.onTimer,
      required this.onCopy,
      required this.isTimerRunning,
      required this.isTimerLoading});
  final bool isDark;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTimer;
  final VoidCallback onCopy;
  final bool isTimerRunning;
  final bool isTimerLoading;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.46 : 0.55)),
          ),
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(width: Dimensions.space8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: boldLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              // Timer button (always visible — primary action)
              isTimerLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: onTimer,
                      tooltip: isTimerRunning ? 'Stop Timer' : 'Start Timer',
                      icon: Icon(
                        isTimerRunning
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        color: isTimerRunning ? Colors.red : Colors.green,
                        size: 24,
                      ),
                    ),
              // Overflow menu — Copy / Edit / Delete
              PopupMenuButton<String>(
                tooltip: 'More',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 22),
                onSelected: (v) {
                  switch (v) {
                    case 'copy':
                      onCopy();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(Icons.copy_outlined, size: 20),
                      title: Text('Copy task'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(Icons.edit_outlined, size: 20),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(Icons.delete_outline,
                          size: 20, color: Colors.redAccent),
                      title: const Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

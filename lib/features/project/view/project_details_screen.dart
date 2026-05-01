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
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/project/section/discussions.dart';
import 'package:flutex_admin/features/project/section/estimates.dart';
import 'package:flutex_admin/features/project/section/invoices.dart';
import 'package:flutex_admin/features/project/section/milestones.dart';
import 'package:flutex_admin/features/project/section/overview.dart';
import 'package:flutex_admin/features/project/section/proposals.dart';
import 'package:flutex_admin/features/project/section/tasks.dart';
import 'package:flutex_admin/features/project/section/members.dart';
import 'package:flutex_admin/features/project/section/notes.dart';
import 'package:flutex_admin/features/project/section/activity.dart';
import 'package:flutex_admin/features/project/section/time_sheet.dart';
import 'package:flutex_admin/features/project/section/files.dart';
import 'package:flutex_admin/features/project/section/expenses.dart'
    as proj_expenses;
import 'package:flutex_admin/features/project/section/kanban.dart';
import 'package:flutex_admin/features/project/section/gantt.dart';
import 'package:flutex_admin/features/invoice/controller/invoice_controller.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.projectDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.projectDetailsModel.data!;
      final statusColor = ColorResources.projectStatusColor(d.status ?? '');
      final progress = double.tryParse(d.progress ?? '0') ?? 0;

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
                  color: (isDark
                          ? const Color(0xFF343434)
                          : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.25 : 0.62),
                ),
              ),
              Positioned(
                bottom: 200,
                right: -60,
                child: _BlurOrb(
                  size: 160,
                  color: (isDark
                          ? const Color(0xFF23324A)
                          : const Color(0xFFD0E7FF))
                      .withValues(alpha: isDark ? 0.2 : 0.5),
                ),
              ),
              Column(
                children: [
                  // Glass header
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _DetailHeader(
                      isDark: isDark,
                      title: (d.name != null && d.name!.trim().isNotEmpty)
                          ? d.name!
                          : LocalStrings.projectDetails.tr,
                      statusColor: statusColor,
                      statusLabel: d.statusName ?? '',
                      progress: progress,
                      onBack: () => Get.back(),
                      onEdit: () => Get.toNamed(RouteHelper.updateProjectScreen,
                          arguments: widget.id),
                      onDelete: () {
                        const WarningAlertDialog().warningAlertDialog(
                          context,
                          () {
                            Get.back();
                            Get.find<ProjectController>()
                                .deleteProject(widget.id);
                            Navigator.pop(context);
                          },
                          title: LocalStrings.deleteProject.tr,
                          subTitle: LocalStrings.deleteProjectWarningMSg.tr,
                          image: MyImages.exclamationImage,
                        );
                      },
                      onCopy: () => controller.copyProject(widget.id),
                      onChangeStatus: (status) =>
                          controller.updateProjectStatus(widget.id, status),
                      onInvoiceProject: () {
                        Get.put(ApiClient(sharedPreferences: Get.find()));
                        Get.put(InvoiceRepo(apiClient: Get.find()));
                        final invCtrl =
                            Get.put(InvoiceController(invoiceRepo: Get.find()));
                        invCtrl.fromProjectId = widget.id;
                        Get.toNamed(RouteHelper.addInvoiceScreen);
                      },
                      onMassStopTimers: () =>
                          controller.massStopTimers(widget.id),
                      onTogglePin: () => controller.togglePinProject(widget.id),
                      isPinned: controller.isProjectPinned(widget.id),
                      onExport: () => controller.exportProjectData(widget.id),
                    ),
                  ),
                  // Tab bar + content
                  Expanded(
                    child: ContainedTabBarView(
                      tabBarProperties: TabBarProperties(
                        isScrollable: true,
                        background: Container(
                          color: (isDark
                                  ? const Color(0xFF343434)
                                  : const Color(0xFFFFFFFF))
                              .withValues(alpha: isDark ? 0.5 : 0.45),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: ColorResources.blueGreyColor,
                        indicatorColor: Theme.of(context).primaryColor,
                        labelColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        labelPadding: const EdgeInsets.symmetric(
                            vertical: Dimensions.space12,
                            horizontal: Dimensions.space15),
                      ),
                      tabs: [
                        if (controller.projectOverviewEnable)
                          _TabItem(
                              icon: Icons.grid_view_outlined,
                              label: LocalStrings.overview.tr),
                        _TabItem(icon: Icons.group_outlined, label: 'Members'),
                        if (controller.projectTasksEnable)
                          _TabItem(
                              icon: Icons.check_circle_outline_outlined,
                              label: LocalStrings.tasks.tr),
                        if (controller.projectInvoicesEnable)
                          _TabItem(
                              icon: Icons.article_outlined,
                              label: LocalStrings.invoices.tr),
                        if (controller.projectEstimatesEnable)
                          _TabItem(
                              icon: Icons.assignment_outlined,
                              label: LocalStrings.estimates.tr),
                        if (controller.projectDiscussionsEnable)
                          _TabItem(
                              icon: Icons.chat_outlined,
                              label: LocalStrings.discussion.tr),
                        if (controller.projectProposalsEnable)
                          _TabItem(
                              icon: Icons.description_outlined,
                              label: LocalStrings.proposals.tr),
                        if (controller.projectTimesheetsEnable)
                          _TabItem(
                              icon: Icons.timer_outlined, label: 'Timesheets'),
                        if (controller.projectMilestonesEnable)
                          _TabItem(
                              icon: Icons.flag_outlined, label: 'Milestones'),
                        if (controller.projectFilesEnable)
                          _TabItem(icon: Icons.folder_outlined, label: 'Files'),
                        if (controller.projectExpensesEnable)
                          _TabItem(
                              icon: Icons.receipt_long_outlined,
                              label: 'Expenses'),
                        _TabItem(
                            icon: Icons.sticky_note_2_outlined, label: 'Notes'),
                        _TabItem(
                            icon: Icons.history_outlined, label: 'Activity'),
                        _TabItem(
                            icon: Icons.view_kanban_outlined, label: 'Kanban'),
                        _TabItem(
                            icon: Icons.bar_chart_outlined, label: 'Gantt'),
                      ],
                      views: [
                        if (controller.projectOverviewEnable)
                          OverviewWidget(
                              projectDetailsModel: d, projectId: d.id!),
                        ProjectMembersWidget(projectId: d.id!),
                        if (controller.projectTasksEnable)
                          ProjectTasks(id: d.id!),
                        if (controller.projectInvoicesEnable)
                          ProjectInvoices(id: d.id!),
                        if (controller.projectEstimatesEnable)
                          ProjectEstimates(id: d.id!),
                        if (controller.projectDiscussionsEnable)
                          ProjectDiscussions(id: d.id!),
                        if (controller.projectProposalsEnable)
                          ProjectProposals(id: d.id!),
                        if (controller.projectTimesheetsEnable)
                          TimeSheetWidget(id: d.id!),
                        if (controller.projectMilestonesEnable)
                          ProjectMilestones(id: d.id!),
                        if (controller.projectFilesEnable)
                          ProjectFiles(id: d.id!),
                        if (controller.projectExpensesEnable)
                          proj_expenses.ProjectExpenses(id: d.id!),
                        ProjectNotes(projectId: d.id!),
                        ProjectActivity(projectId: d.id!),
                        ProjectKanban(id: d.id!),
                        ProjectGantt(id: d.id!),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

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

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 5),
        Text(label, style: regularDefault),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.isDark,
    required this.title,
    required this.statusColor,
    required this.statusLabel,
    required this.progress,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
    required this.onChangeStatus,
    required this.onInvoiceProject,
    required this.onMassStopTimers,
    required this.onTogglePin,
    required this.isPinned,
    required this.onExport,
  });

  final bool isDark;
  final String title;
  final Color statusColor;
  final String statusLabel;
  final double progress;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final void Function(String status) onChangeStatus;
  final VoidCallback onInvoiceProject;
  final VoidCallback onMassStopTimers;
  final VoidCallback onTogglePin;
  final bool isPinned;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: semiBoldLarge.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(statusLabel,
                        style: regularSmall.copyWith(
                            color: statusColor, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20)),
                  IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: ColorResources.redColor)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'copy') {
                        onCopy();
                      } else if (value == 'invoice') {
                        onInvoiceProject();
                      } else if (value == 'stop_timers') {
                        onMassStopTimers();
                      } else if (value == 'pin') {
                        onTogglePin();
                      } else if (value == 'export') {
                        onExport();
                      } else {
                        onChangeStatus(value);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'pin',
                          child: Row(children: [
                            Icon(
                                isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(isPinned ? 'Unpin Project' : 'Pin Project'),
                          ])),
                      const PopupMenuItem(
                          value: 'export',
                          child: Row(children: [
                            Icon(Icons.file_download_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Export Project Data'),
                          ])),
                      const PopupMenuItem(
                          value: 'copy',
                          child: Row(children: [
                            Icon(Icons.copy_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Copy Project'),
                          ])),
                      const PopupMenuItem(
                          value: 'invoice',
                          child: Row(children: [
                            Icon(Icons.article_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Invoice Project'),
                          ])),
                      const PopupMenuItem(
                          value: 'stop_timers',
                          child: Row(children: [
                            Icon(Icons.timer_off_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Stop All Timers'),
                          ])),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                          value: '1',
                          child: Row(children: [
                            Icon(Icons.play_arrow_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Mark Not Started'),
                          ])),
                      const PopupMenuItem(
                          value: '2',
                          child: Row(children: [
                            Icon(Icons.timelapse_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Mark In Progress'),
                          ])),
                      const PopupMenuItem(
                          value: '3',
                          child: Row(children: [
                            Icon(Icons.pause_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Mark On Hold'),
                          ])),
                      const PopupMenuItem(
                          value: '4',
                          child: Row(children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Mark Finished'),
                          ])),
                      const PopupMenuItem(
                          value: '5',
                          child: Row(children: [
                            Icon(Icons.cancel_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Mark Cancelled'),
                          ])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: progress * 0.01,
                          color: statusColor,
                          backgroundColor: (isDark
                                  ? const Color(0xFF2A3347)
                                  : const Color(0xFFD0DAE8))
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space8),
                    Text(
                      '${progress.toInt()}%',
                      style: regularSmall.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/work_report/controller/work_report_controller.dart';
import 'package:flutex_admin/features/work_report/model/work_report_model.dart';
import 'package:flutex_admin/features/work_report/repo/work_report_repo.dart';
import 'package:flutex_admin/features/work_report/view/work_report_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkReportsScreen extends StatefulWidget {
  const WorkReportsScreen({super.key});

  @override
  State<WorkReportsScreen> createState() => _WorkReportsScreenState();
}

class _WorkReportsScreenState extends State<WorkReportsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WorkReportRepo(apiClient: Get.find()));
    final c = Get.put(WorkReportController(workReportRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.initialData());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkReportController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
      final isAdmin = controller.isAdmin;

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
                bottom: 160,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _GlassHeader(
                      isDark: isDark,
                      title: LocalStrings.workReports.tr,
                      // Only staff (non-admin) submit from this screen.
                      // Admins submit/reply from the dedicated detail flow.
                      trailing: isAdmin
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.add_rounded),
                              onPressed: () =>
                                  _showSubmitDialog(context, controller),
                            ),
                    ),
                  ),
                  if (controller.isLoading)
                    const Expanded(child: CustomLoader())
                  else ...[
                    // ── Admin filter bar ─────────────────────────────────
                    if (isAdmin && controller.staffList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Dimensions.space15, 0, Dimensions.space15, 0),
                        child: _FilterBar(
                          isDark: isDark,
                          controller: controller,
                          onPickDate: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) {
                              controller.setFilterDate(
                                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                              );
                            }
                          },
                        ),
                      ),
                    // ── Reports list ─────────────────────────────────────
                    Expanded(
                      child: (controller.reportsModel.data?.isEmpty ?? true)
                          ? const NoDataWidget()
                          : RefreshIndicator(
                              onRefresh: controller.reloadFiltered,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.all(Dimensions.space15),
                                itemCount: controller.reportsModel.data!.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: Dimensions.space10),
                                itemBuilder: (context, i) {
                                  final report =
                                      controller.reportsModel.data![i];
                                  return _WorkReportCard(
                                    report: report,
                                    isDark: isDark,
                                    isAdmin: isAdmin,
                                    onOpen: () => _openDetail(report),
                                    onReply: () =>
                                        _openDetail(report, focusReply: true),
                                    onDelete: isAdmin
                                        ? () => _confirmDelete(
                                            context, controller, report.id!)
                                        : null,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openDetail(WorkReport report, {bool focusReply = false}) {
    Get.to(() => WorkReportDetailScreen(
          reportId: report.id ?? '',
          autoFocusReply: focusReply,
        ));
  }

  void _showSubmitDialog(
      BuildContext context, WorkReportController controller) {
    controller.clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => GetBuilder<WorkReportController>(builder: (c) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: WorkReportSubmitForm(controller: c, sheetMode: true),
          ),
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkReportController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteReport(id);
      },
      title: LocalStrings.deleteWorkReport.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

/// Compact submission form used in both the bottom sheet (reports screen)
/// and the dashboard widget (staff role).
class WorkReportSubmitForm extends StatelessWidget {
  const WorkReportSubmitForm({
    super.key,
    required this.controller,
    this.sheetMode = false,
  });
  final WorkReportController controller;
  final bool sheetMode;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final accent = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sheetMode)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
        if (sheetMode) const SizedBox(height: 12),
        Text(LocalStrings.submitReport.tr,
            style: regularDefault.copyWith(
                fontWeight: FontWeight.w600, fontSize: 16, color: bodyColor)),
        const SizedBox(height: 6),
        // Name (auto, read-only)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.55 : 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.person_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${LocalStrings.reportingAs.tr}: '
                  '${c.currentStaffName ?? '—'}',
                  style: regularSmall.copyWith(
                      color: accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Date picker
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: c.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (d != null) c.changeDate(d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: accent),
                const SizedBox(width: 8),
                Text(_formatDate(c.selectedDate),
                    style: regularSmall.copyWith(color: bodyColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: c.locationController,
          style: TextStyle(color: bodyColor),
          decoration: InputDecoration(
              labelText: '${LocalStrings.location.tr} *',
              prefixIcon:
                  Icon(Icons.location_on_outlined, size: 18, color: accent),
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: c.projectController,
          style: TextStyle(color: bodyColor),
          decoration: InputDecoration(
              labelText: '${LocalStrings.project.tr} *',
              prefixIcon: Icon(Icons.work_outline, size: 18, color: accent),
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: c.detailsController,
          style: TextStyle(color: bodyColor),
          maxLines: 4,
          decoration: InputDecoration(
              labelText: '${LocalStrings.details.tr} *',
              alignLabelWithHint: true,
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: c.isSubmitLoading
              ? Center(child: CircularProgressIndicator(color: accent))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () async {
                    await c.submitReport();
                    if (sheetMode && c.detailsController.text.trim().isEmpty) {
                      // Submission cleared the form on success — close sheet.
                      if (Get.isBottomSheetOpen ?? false) Get.back();
                    }
                  },
                  child: Text(LocalStrings.submit.tr,
                      style: const TextStyle(color: Colors.white))),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.isDark,
    required this.controller,
    required this.onPickDate,
  });
  final bool isDark;
  final WorkReportController controller;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.filterStaffId,
                  decoration: InputDecoration(
                    labelText: 'Staff',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('All Staff')),
                    ...controller.staffList.map((s) => DropdownMenuItem<String>(
                        value: s.id, child: Text(s.fullName))),
                  ],
                  onChanged: (v) => controller.setFilterStaff(v),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onPickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 6),
                      Text(controller.filterDate ?? 'All',
                          style: regularSmall.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color)),
                    ],
                  ),
                ),
              ),
              if (controller.filterStaffId != null ||
                  controller.filterDate != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: controller.clearFilters,
                  tooltip: 'Clear filters',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkReportCard extends StatelessWidget {
  const _WorkReportCard({
    required this.report,
    required this.onOpen,
    required this.onReply,
    required this.isDark,
    required this.isAdmin,
    this.onDelete,
  });
  final WorkReport report;
  final VoidCallback onOpen;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final bool isDark;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined, color: accent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(report.reportDate ?? '',
                        style: regularDefault.copyWith(
                            fontWeight: FontWeight.w600, color: bodyColor)),
                  ),
                  if ((report.staffName ?? '').isNotEmpty)
                    Text(report.staffName!,
                        style: regularSmall.copyWith(color: accent)),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          size: 18, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              if ((report.location ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                _IconLine(
                    icon: Icons.location_on_outlined,
                    text: report.location!,
                    color: isDark ? Colors.white70 : Colors.blueGrey),
              ],
              if ((report.project ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                _IconLine(
                    icon: Icons.work_outline,
                    text: report.project!,
                    color: accent),
              ],
              if (report.displayDetails.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(report.displayDetails,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall!.color)),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (report.repliesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${report.repliesCount} ${LocalStrings.replies.tr}',
                        style: regularSmall.copyWith(
                            color: accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onOpen,
                    style: TextButton.styleFrom(foregroundColor: accent),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(LocalStrings.viewDetails.tr,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  if (isAdmin)
                    TextButton.icon(
                      onPressed: onReply,
                      style: TextButton.styleFrom(foregroundColor: accent),
                      icon: const Icon(Icons.reply_rounded, size: 16),
                      label: Text(LocalStrings.reply.tr,
                          style: const TextStyle(fontSize: 12)),
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

class _IconLine extends StatelessWidget {
  const _IconLine(
      {required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: regularSmall.copyWith(color: color)),
        ),
      ],
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader(
      {required this.isDark, required this.title, this.trailing});
  final bool isDark;
  final String title;
  final Widget? trailing;

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
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  title,
                  style: boldExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

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

String _formatDate(DateTime d) {
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
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
}

/// Helper used by RouteHelper to navigate to detail screen.
Future<void> openWorkReportDetail(String reportId,
    {bool autoFocusReply = false}) async {
  await Get.toNamed(RouteHelper.workReportDetailScreen,
      arguments: {'id': reportId, 'reply': autoFocusReply});
}

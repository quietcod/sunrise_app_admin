import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/work_report/controller/work_report_controller.dart';
import 'package:flutex_admin/features/work_report/model/work_report_model.dart';
import 'package:flutex_admin/features/work_report/repo/work_report_repo.dart';
import 'package:flutex_admin/features/work_report/view/work_report_detail_screen.dart';
import 'package:flutex_admin/features/work_report/view/work_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dashboard widget that adapts to the user's role:
///   • Staff (non-admin): inline form to submit a daily report.
///       Name is auto-filled (read-only) from the server `meta.staff_name`.
///   • Admin: list of latest reports per staff member with
///       "Details" and "Reply" buttons.
///
/// Uses the shared [WorkReportController] so changes elsewhere keep in sync.
class WorkReportDashboardWidget extends StatefulWidget {
  const WorkReportDashboardWidget({super.key});

  @override
  State<WorkReportDashboardWidget> createState() =>
      _WorkReportDashboardWidgetState();
}

class _WorkReportDashboardWidgetState extends State<WorkReportDashboardWidget> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(sharedPreferences: Get.find()));
    }
    if (!Get.isRegistered<WorkReportRepo>()) {
      Get.put(WorkReportRepo(apiClient: Get.find()));
    }
    final c = Get.isRegistered<WorkReportController>()
        ? Get.find<WorkReportController>()
        : Get.put(WorkReportController(workReportRepo: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lightweight initial load: pulls reports + meta to know role,
      // and (if admin) the latest-per-staff overview.
      c.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkReportController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      // Until meta arrives we don't know the role — show a slim loader.
      final hasMeta = controller.meta != null;
      if (!hasMeta) {
        return _GlassFrame(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        );
      }

      return _GlassFrame(
        isDark: isDark,
        child: controller.isAdmin
            ? _AdminLatestReports(controller: controller, isDark: isDark)
            : _StaffSubmitWidget(controller: controller),
      );
    });
  }
}

class _GlassFrame extends StatelessWidget {
  const _GlassFrame({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.7),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StaffSubmitWidget extends StatelessWidget {
  const _StaffSubmitWidget({required this.controller});
  final WorkReportController controller;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined, color: accent),
            const SizedBox(width: 8),
            Text(LocalStrings.dailyReport.tr,
                style: regularDefault.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => Get.toNamed(RouteHelper.workReportsScreen),
              style: TextButton.styleFrom(foregroundColor: accent),
              icon: const Icon(Icons.history, size: 16),
              label: Text(LocalStrings.workReports.tr,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        WorkReportSubmitForm(controller: controller),
      ],
    );
  }
}

class _AdminLatestReports extends StatelessWidget {
  const _AdminLatestReports({required this.controller, required this.isDark});
  final WorkReportController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fact_check_outlined, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(LocalStrings.workReports.tr,
                  style: regularDefault.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
            IconButton(
              tooltip: LocalStrings.workReports.tr,
              onPressed: () => Get.toNamed(RouteHelper.workReportsScreen),
              icon: Icon(Icons.open_in_new_rounded, size: 18, color: accent),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (controller.isLatestLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: accent),
              ),
            ),
          )
        else if (controller.latestPerStaff.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(LocalStrings.noReportsYet.tr,
                style: regularSmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color)),
          )
        else
          ...controller.latestPerStaff
              .take(5)
              .map((r) => _AdminReportRow(report: r, isDark: isDark)),
      ],
    );
  }
}

class _AdminReportRow extends StatelessWidget {
  const _AdminReportRow({required this.report, required this.isDark});
  final WorkReport report;
  final bool isDark;

  void _open({bool focusReply = false}) {
    Get.to(() => WorkReportDetailScreen(
          reportId: report.id ?? '',
          autoFocusReply: focusReply,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Text(
              _initials(report.staffName ?? ''),
              style: regularSmall.copyWith(
                  color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.staffName ?? '—',
                    style: regularDefault.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color)),
                const SizedBox(height: 2),
                Text(
                  '${LocalStrings.lastSubmitted.tr}: ${report.reportDate ?? '—'}',
                  style: regularSmall.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: LocalStrings.viewDetails.tr,
            onPressed: () => _open(),
            icon: Icon(Icons.visibility_outlined, color: accent),
          ),
          IconButton(
            tooltip: LocalStrings.reply.tr,
            onPressed: () => _open(focusReply: true),
            icon: Icon(Icons.reply_rounded, color: accent),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

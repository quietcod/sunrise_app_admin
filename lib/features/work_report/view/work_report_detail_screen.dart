import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/work_report/controller/work_report_controller.dart';
import 'package:flutex_admin/features/work_report/model/work_report_model.dart';
import 'package:flutex_admin/features/work_report/repo/work_report_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkReportDetailScreen extends StatefulWidget {
  const WorkReportDetailScreen({
    super.key,
    required this.reportId,
    this.autoFocusReply = false,
  });

  final String reportId;
  final bool autoFocusReply;

  @override
  State<WorkReportDetailScreen> createState() => _WorkReportDetailScreenState();
}

class _WorkReportDetailScreenState extends State<WorkReportDetailScreen> {
  final FocusNode _replyFocus = FocusNode();

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await c.loadReportDetail(widget.reportId);
      if (widget.autoFocusReply && mounted) {
        _replyFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _replyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      body: GetBuilder<WorkReportController>(builder: (controller) {
        final report = controller.activeReport;
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.space15,
                    Dimensions.space5, Dimensions.space15, Dimensions.space10),
                child: _GlassHeader(
                  isDark: isDark,
                  title: LocalStrings.reportDetails.tr,
                ),
              ),
              if (controller.isDetailLoading || report == null)
                const Expanded(child: CustomLoader())
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    children: [
                      _ReportSummary(report: report, isDark: isDark),
                      const SizedBox(height: Dimensions.space15),
                      Text(
                        '${LocalStrings.replies.tr} (${report.replies?.length ?? 0})',
                        style: regularDefault.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: Dimensions.space8),
                      if ((report.replies ?? []).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No replies yet.',
                            style: regularSmall.copyWith(
                                color: ColorResources.contentTextColor),
                          ),
                        )
                      else
                        ...report.replies!.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ReplyTile(reply: r, isDark: isDark),
                            )),
                    ],
                  ),
                ),
              if (!controller.isDetailLoading && report != null)
                _ReplyComposer(
                  controller: controller,
                  focusNode: _replyFocus,
                  isDark: isDark,
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report, required this.isDark});
  final WorkReport report;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.assignment_outlined,
                      color: Theme.of(context).primaryColor, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.reportDate ?? '',
                      style: regularDefault.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                  ),
                  if ((report.staffName ?? '').isNotEmpty)
                    Text(report.staffName!,
                        style: regularSmall.copyWith(
                            color: Theme.of(context).primaryColor)),
                ],
              ),
              const SizedBox(height: 10),
              _Field(
                  label: LocalStrings.location.tr,
                  value: report.location ?? '—',
                  icon: Icons.location_on_outlined),
              const SizedBox(height: 8),
              _Field(
                  label: LocalStrings.project.tr,
                  value: report.project ?? '—',
                  icon: Icons.work_outline),
              const SizedBox(height: 8),
              _Field(
                  label: LocalStrings.details.tr,
                  value: report.displayDetails.isEmpty
                      ? '—'
                      : report.displayDetails,
                  icon: Icons.description_outlined,
                  multiline: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.icon,
    this.multiline = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: regularSmall.copyWith(
                      color: ColorResources.contentTextColor)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: multiline ? null : 2,
                  overflow:
                      multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: regularDefault.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply, required this.isDark});
  final WorkReportReply reply;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = reply.isAdmin
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium!.color!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
            .withValues(alpha: isDark ? 0.42 : 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (isDark ? const Color(0xFF414A5B) : const Color(0xFFE0E5EC))
                .withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reply.isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  reply.staffName ?? '',
                  style: regularSmall.copyWith(
                      fontWeight: FontWeight.w600, color: color),
                ),
              ),
              if ((reply.createdAt ?? '').isNotEmpty)
                Text(reply.createdAt!,
                    style: regularSmall.copyWith(
                        color: ColorResources.contentTextColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(reply.message ?? '',
              style: regularDefault.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color)),
        ],
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.focusNode,
    required this.isDark,
  });
  final WorkReportController controller;
  final FocusNode focusNode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.space12,
          Dimensions.space8,
          Dimensions.space12,
          MediaQuery.of(context).viewInsets.bottom + Dimensions.space12,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.5 : 0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color:
                    (isDark ? const Color(0xFF414A5B) : const Color(0xFFE0E5EC))
                        .withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.replyController,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: LocalStrings.writeAReply.tr,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              controller.isReplyLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  : IconButton(
                      onPressed: controller.postReply,
                      icon: Icon(Icons.send_rounded,
                          color: Theme.of(context).primaryColor),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.isDark, required this.title});
  final bool isDark;
  final String title;

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
                      .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
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
            ],
          ),
        ),
      ),
    );
  }
}

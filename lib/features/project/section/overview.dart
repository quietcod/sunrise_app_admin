import 'dart:ui';

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/project_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget(
      {super.key, required this.projectDetailsModel, required this.projectId});
  final ProjectDetails projectDetailsModel;
  final String projectId;

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  void _showQuickEditSheet(BuildContext context) {
    final ctrl = Get.find<ProjectController>();
    final deadlineCtrl =
        TextEditingController(text: widget.projectDetailsModel.deadline ?? '');
    String selectedBillingType = widget.projectDetailsModel.billingType ?? '1';
    final billingTypes = {
      '1': LocalStrings.fixedRate.tr,
      '2': LocalStrings.projectHours.tr,
      '3': LocalStrings.taskHours.tr,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.space20,
              Dimensions.space20,
              Dimensions.space20,
              MediaQuery.of(ctx).viewInsets.bottom + Dimensions.space20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Quick Edit', style: semiBoldLarge),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: Dimensions.space15),
                Text(LocalStrings.billingType.tr,
                    style: regularSmall.copyWith(
                        color: ColorResources.blueGreyColor)),
                const SizedBox(height: Dimensions.space8),
                Wrap(
                  spacing: Dimensions.space8,
                  children: billingTypes.entries
                      .map((e) => ChoiceChip(
                            label: Text(e.value),
                            selected: selectedBillingType == e.key,
                            onSelected: (_) => setSheetState(
                                () => selectedBillingType = e.key),
                          ))
                      .toList(),
                ),
                const SizedBox(height: Dimensions.space15),
                Text(LocalStrings.deadline.tr,
                    style: regularSmall.copyWith(
                        color: ColorResources.blueGreyColor)),
                const SizedBox(height: Dimensions.space8),
                GestureDetector(
                  onTap: () async {
                    DateTime initial = DateTime.now();
                    try {
                      if (deadlineCtrl.text.isNotEmpty) {
                        initial = DateTime.parse(deadlineCtrl.text);
                      }
                    } catch (_) {}
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: initial,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setSheetState(() {
                        deadlineCtrl.text =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: deadlineCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // Load current project data into controller, change
                      // the two fields, then submit as update.
                      await ctrl.loadProjectUpdateData(widget.projectId);
                      ctrl.billingTypeController.text = selectedBillingType;
                      ctrl.deadlineController.text = deadlineCtrl.text;
                      await ctrl.submitProject(
                          projectId: widget.projectId, isUpdate: true);
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectDetailsModel = widget.projectDetailsModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor =
        ColorResources.projectStatusColor(projectDetailsModel.status ?? '');
    final progress = double.tryParse(projectDetailsModel.progress ?? '0') ?? 0;

    int daysLeft = 0;
    int totalDays = 0;
    if (projectDetailsModel.deadline != null) {
      daysLeft = DateTime.parse(projectDetailsModel.deadline!)
          .difference(DateTime.now())
          .inDays;
      if (projectDetailsModel.startDate != null) {
        totalDays = DateTime.parse(projectDetailsModel.deadline!)
            .difference(DateTime.parse(projectDetailsModel.startDate!))
            .inDays;
      }
    }

    String billingLabel = projectDetailsModel.billingType == '1'
        ? LocalStrings.fixedRate.tr
        : projectDetailsModel.billingType == '2'
            ? LocalStrings.projectHours.tr
            : LocalStrings.taskHours.tr;

    String rateLabel = projectDetailsModel.billingType == '1'
        ? projectDetailsModel.projectCost ?? '-'
        : projectDetailsModel.billingType == '2'
            ? '${projectDetailsModel.projectRatePerHour ?? '0'} / ${LocalStrings.hours.tr}'
            : projectDetailsModel.projectCost ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.space15),
      child: Column(
        children: [
          // ── Key info card ──────────────────────────────────────
          _GlassCard(
            isDark: isDark,
            accentColor: statusColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoPair(
                      label: LocalStrings.customer.tr,
                      value: projectDetailsModel.clientData?.company ?? '-',
                    ),
                    Row(
                      children: [
                        _InfoPair(
                          label: LocalStrings.billingType.tr,
                          value: billingLabel,
                          align: CrossAxisAlignment.end,
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showQuickEditSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.edit_outlined,
                                size: 14,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space12),
                _HDivider(isDark: isDark),
                const SizedBox(height: Dimensions.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoPair(
                      label: LocalStrings.startDate.tr,
                      value: projectDetailsModel.startDate ?? '-',
                    ),
                    GestureDetector(
                      onTap: () => _showQuickEditSheet(context),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _InfoPair(
                            label: LocalStrings.deadline.tr,
                            value: projectDetailsModel.deadline ?? '-',
                            align: CrossAxisAlignment.end,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined,
                              size: 13, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space12),
                _HDivider(isDark: isDark),
                const SizedBox(height: Dimensions.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoPair(
                      label: LocalStrings.totalRate.tr,
                      value: rateLabel,
                    ),
                    _InfoPair(
                      label: LocalStrings.logged.tr,
                      value: projectDetailsModel.totalLoggedTime ?? '00:00',
                      align: CrossAxisAlignment.end,
                    ),
                  ],
                ),
                if ((Converter.parseHtmlString(
                        projectDetailsModel.description ?? ''))
                    .isNotEmpty) ...[
                  const SizedBox(height: Dimensions.space12),
                  _HDivider(isDark: isDark),
                  const SizedBox(height: Dimensions.space8),
                  Text(LocalStrings.description.tr,
                      style: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor)),
                  const SizedBox(height: 4),
                  Text(
                    Converter.parseHtmlString(
                        projectDetailsModel.description ?? ''),
                    style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space12),

          // ── Progress ───────────────────────────────────────────
          _GlassCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.projectProgress.tr,
                        style: semiBoldDefault.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    Text(
                      '${progress.toInt()}%',
                      style: semiBoldDefault.copyWith(color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress * 0.01,
                    color: statusColor,
                    backgroundColor: (isDark
                            ? const Color(0xFF2A3347)
                            : const Color(0xFFD0DAE8))
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space12),

          // ── Days left ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _GlassCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalStrings.daysLeft.tr,
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor)),
                      const SizedBox(height: 4),
                      Text(
                        '${daysLeft > 0 ? daysLeft : 0} / $totalDays',
                        style: semiBoldDefault.copyWith(
                            color: ColorResources.greenColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: _GlassCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalStrings.logged.tr,
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor)),
                      const SizedBox(height: 4),
                      Text(
                        projectDetailsModel.totalLoggedTime ?? '00:00',
                        style: semiBoldDefault.copyWith(
                            color: ColorResources.blueColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space12),

          // ── Expenses row ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  isDark: isDark,
                  label: LocalStrings.totalExpenses.tr,
                  value: '0.00',
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: _StatCard(
                  isDark: isDark,
                  label: LocalStrings.billableExpenses.tr,
                  value: '0.00',
                  color: ColorResources.colorOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  isDark: isDark,
                  label: LocalStrings.billedExpenses.tr,
                  value: '0.00',
                  color: ColorResources.greenColor,
                ),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: _StatCard(
                  isDark: isDark,
                  label: LocalStrings.unbilledExpenses.tr,
                  value: '0.00',
                  color: ColorResources.redColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space25),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.isDark,
    required this.child,
    this.accentColor,
  });

  final bool isDark;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF343434), const Color(0xFF343434)]
                  : [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                      const Color(0xFFEFF3F8).withValues(alpha: 0.65),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF2A3347) : const Color(0xFFD8E2F0))
                      .withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.blueGrey)
                    .withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: accentColor != null
                ? BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 4, color: accentColor!)),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Divider(
        color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
            .withValues(alpha: 0.7),
        height: 1,
      );
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });
  final String label;
  final String value;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: regularSmall.copyWith(color: ColorResources.blueGreyColor)),
        const SizedBox(height: 2),
        Text(value, style: semiBoldDefault),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.color,
  });
  final bool isDark;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  regularSmall.copyWith(color: ColorResources.blueGreyColor)),
          const SizedBox(height: 4),
          Text(value, style: semiBoldDefault.copyWith(color: color)),
        ],
      ),
    );
  }
}

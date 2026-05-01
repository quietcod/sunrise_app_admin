import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/extras/entity_extras_section.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/expense/controller/expense_controller.dart';
import 'package:flutex_admin/features/expense/repo/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ExpenseRepo(apiClient: Get.find()));
    final controller = Get.put(ExpenseController(expenseRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadExpenseDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.expenseDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.expenseDetailsModel.data!;
      final isBillable = (d.billable ?? '0') == '1';
      final accentColor =
          isBillable ? ColorResources.colorOrange : ColorResources.darkColor;
      final cur = d.currencySymbol ?? '';
      final amount = double.tryParse(d.amount ?? '0') ?? 0;

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadExpenseDetails(widget.id),
          child: Container(
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
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.space15,
                    topPad,
                    Dimensions.space15,
                    Dimensions.space25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────────────────────────
                      _DetailHeader(
                        isDark: isDark,
                        title: LocalStrings.expenseDetails.tr,
                        onBack: () => Get.back(),
                        onEdit: () => Get.toNamed(
                          RouteHelper.updateExpenseScreen,
                          arguments: widget.id,
                        ),
                        onDelete: () {
                          const WarningAlertDialog().warningAlertDialog(
                            context,
                            () {
                              Get.back();
                              Get.find<ExpenseController>()
                                  .deleteExpense(widget.id);
                              Navigator.pop(context);
                            },
                            title: LocalStrings.deleteExpense.tr,
                            subTitle: LocalStrings.deleteExpenseWarningMsg.tr,
                            image: MyImages.exclamationImage,
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.space15),

                      // ── Hero card ──────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        accentColor: accentColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.receipt_outlined,
                                  color: accentColor, size: 26),
                            ),
                            const SizedBox(width: Dimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.expenseName ?? '-',
                                    style: boldExtraLarge.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                  if ((d.categoryName ?? '').isNotEmpty)
                                    Text(
                                      d.categoryName!,
                                      style: regularDefault.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$cur${amount.toStringAsFixed(2)}',
                                  style: boldExtraLarge.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            accentColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    isBillable ? 'Billable' : 'Not Billable',
                                    style: regularSmall.copyWith(
                                        color: accentColor,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Date row ───────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: _InfoRow(
                          label: LocalStrings.expenseDate.tr,
                          value: d.date ?? '-',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Financial info ─────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FinancialRow(
                              label: LocalStrings.expenseAmount.tr,
                              value: '$cur${amount.toStringAsFixed(2)}',
                              isDark: isDark,
                            ),
                            if ((d.tax ?? '').isNotEmpty && d.tax != '0') ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                label: '${LocalStrings.tax.tr} 1',
                                value: d.tax!,
                                isDark: isDark,
                              ),
                            ],
                            if ((d.tax2 ?? '').isNotEmpty && d.tax2 != '0') ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                label: '${LocalStrings.tax.tr} 2',
                                value: d.tax2!,
                                isDark: isDark,
                              ),
                            ],
                            if ((d.currencyName ?? '').isNotEmpty) ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                label: LocalStrings.currency.tr,
                                value:
                                    '${d.currencyName ?? ''} (${d.currencySymbol ?? ''})',
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Client / Project ───────────────────────────
                      if ((d.clientName ?? '').isNotEmpty ||
                          (d.projectName ?? '').isNotEmpty) ...[
                        _GlassCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((d.clientName ?? '').isNotEmpty) ...[
                                _SectionLabel(
                                    label: LocalStrings.client.tr,
                                    isDark: isDark),
                                const SizedBox(height: 4),
                                Text(d.clientName!, style: semiBoldDefault),
                              ],
                              if ((d.projectName ?? '').isNotEmpty) ...[
                                const SizedBox(height: Dimensions.space10),
                                _SectionLabel(
                                    label: LocalStrings.project.tr,
                                    isDark: isDark),
                                const SizedBox(height: 4),
                                Text(d.projectName!, style: semiBoldDefault),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space12),
                      ],

                      // ── Reference No ───────────────────────────────
                      if ((d.referenceNo ?? '').isNotEmpty) ...[
                        _GlassCard(
                          isDark: isDark,
                          child: _InfoRow(
                            label: LocalStrings.expenseReferenceNo.tr,
                            value: d.referenceNo!,
                            icon: Icons.tag_outlined,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space12),
                      ],

                      // ── Note ───────────────────────────────────────
                      if ((d.note ?? '').isNotEmpty) ...[
                        _NoteCard(
                          isDark: isDark,
                          label: LocalStrings.note.tr,
                          content: d.note!,
                          icon: Icons.notes_outlined,
                        ),
                        const SizedBox(height: Dimensions.space12),
                      ],

                      // ── Invoice info (if billed) ───────────────────
                      if ((d.invoiceId ?? '').isNotEmpty &&
                          d.invoiceId != '0' &&
                          d.invoiceId != null) ...[
                        _GlassCard(
                          isDark: isDark,
                          child: _InfoRow(
                            label: 'Invoice ID',
                            value: d.invoiceId!,
                            icon: Icons.description_outlined,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space12),
                      ],
                      // ── PDF & Convert actions ─────────────────────
                      const SizedBox(height: Dimensions.space12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'View PDF',
                              color: const Color(0xFFE53935),
                              onPressed: () => controller.openPdf(widget.id),
                              isDark: isDark,
                            ),
                          ),
                          if (isBillable &&
                              (d.invoiceId == null ||
                                  d.invoiceId == '0' ||
                                  d.invoiceId!.isEmpty)) ...[
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: _ActionOutlineButton(
                                icon: Icons.receipt_long_outlined,
                                label: LocalStrings.convertToInvoice.tr,
                                color: const Color(0xFF43A047),
                                isLoading: controller.isSubmitLoading,
                                onPressed: () {
                                  const WarningAlertDialog().warningAlertDialog(
                                    context,
                                    () {
                                      Get.back();
                                      controller.convertToInvoice(widget.id);
                                    },
                                    title: LocalStrings.convertToInvoice.tr,
                                    subTitle:
                                        LocalStrings.convertToInvoiceMsg.tr,
                                    image: MyImages.exclamationImage,
                                  );
                                },
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: Dimensions.space20),
                      EntityExtrasSection(
                        relType: 'expense',
                        relId: widget.id,
                      ),
                      const SizedBox(height: Dimensions.space25),
                    ],
                  ),
                ),
              ],
            ),
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.isDark,
    required this.title,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDark;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  title,
                  style: boldExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: ColorResources.redColor),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF343434).withValues(alpha: 0.65),
                      const Color(0xFF282828).withValues(alpha: 0.55),
                    ]
                  : [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                      const Color(0xFFF5F8FF).withValues(alpha: 0.60),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (accentColor ??
                      (isDark
                          ? const Color(0xFF414A5B)
                          : const Color(0xFFD8E4F0)))
                  .withValues(alpha: accentColor != null ? 0.35 : 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorResources.blueGreyColor),
        const SizedBox(width: Dimensions.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: regularSmall.copyWith(
                      color: ColorResources.blueGreyColor)),
              const SizedBox(height: 2),
              Text(value, style: semiBoldDefault),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinancialRow extends StatelessWidget {
  const _FinancialRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                regularDefault.copyWith(color: ColorResources.blueGreyColor)),
        Text(
          value,
          style: semiBoldDefault.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: regularSmall.copyWith(
        color: ColorResources.blueGreyColor,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.isDark,
    required this.label,
    required this.content,
    required this.icon,
  });

  final bool isDark;
  final String label;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ColorResources.blueGreyColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: regularSmall.copyWith(
                  color: ColorResources.blueGreyColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space8),
          Text(content,
              style: regularDefault.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }
}

class _ActionOutlineButton extends StatelessWidget {
  const _ActionOutlineButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isDark,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withValues(alpha: isDark ? 0.08 : 0.05),
      ),
    );
  }
}

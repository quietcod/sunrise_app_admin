import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/extras/entity_extras_section.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/invoice/controller/invoice_controller.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(InvoiceRepo(apiClient: Get.find()));
    final controller = Get.put(InvoiceController(invoiceRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInvoiceDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.invoiceDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.invoiceDetailsModel.data!;
      final statusColor = ColorResources.invoiceStatusColor(d.status ?? '');
      final statusLabel = Converter.invoiceStatusString(d.status ?? '');
      final invoiceNumber = '${d.prefix ?? ''}${d.number ?? ''}';
      final cur = d.currencySymbol ?? '';
      final hasPayments = d.payments?.isNotEmpty ?? false;
      final hasBilling = [
        d.billingStreet,
        d.billingCity,
        d.billingState,
        d.billingCountry
      ].any((v) => v != null && v.isNotEmpty);

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadInvoiceDetails(widget.id),
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
                // Blur orbs
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
                      // ── Header bar ─────────────────────────────────
                      _DetailHeader(
                        isDark: isDark,
                        title: LocalStrings.invoiceDetails.tr,
                        onBack: () => Get.back(),
                        onEdit: () => Get.toNamed(
                            RouteHelper.updateInvoiceScreen,
                            arguments: widget.id),
                        onDelete: () {
                          const WarningAlertDialog().warningAlertDialog(
                            context,
                            () {
                              Get.back();
                              Get.find<InvoiceController>()
                                  .deleteInvoice(widget.id);
                              Navigator.pop(context);
                            },
                            title: LocalStrings.deleteInvoice.tr,
                            subTitle: LocalStrings.deleteInvoiceWarningMSg.tr,
                            image: MyImages.exclamationImage,
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.space15),

                      // ── Hero card ──────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        accentColor: statusColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.receipt_long_outlined,
                                  color: statusColor, size: 26),
                            ),
                            const SizedBox(width: Dimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(invoiceNumber,
                                      style: boldExtraLarge.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color)),
                                  if ((d.clientData?.company ?? '').isNotEmpty)
                                    Text(d.clientData!.company!,
                                        style: regularDefault.copyWith(
                                            color:
                                                ColorResources.blueGreyColor)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$cur${d.total ?? '0'}',
                                    style: boldExtraLarge.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            statusColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(statusLabel,
                                      style: regularSmall.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Dates ──────────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Row(
                          children: [
                            Expanded(
                              child: _InfoColumn(
                                label: LocalStrings.invoiceDate.tr,
                                value: d.date ?? '-',
                                icon: Icons.calendar_today_outlined,
                                isDark: isDark,
                              ),
                            ),
                            _Divider(isDark: isDark),
                            Expanded(
                              child: _InfoColumn(
                                label: LocalStrings.dueDate.tr,
                                value: d.duedate ?? '-',
                                icon: Icons.event_busy_outlined,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Client / Project ───────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                                label: LocalStrings.company.tr, isDark: isDark),
                            const SizedBox(height: 4),
                            Text(d.clientData?.company ?? '-',
                                style: semiBoldDefault),
                            if ((d.clientData?.website ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.language_outlined,
                                    size: 13,
                                    color: ColorResources.blueGreyColor),
                                const SizedBox(width: 4),
                                Text(d.clientData!.website!,
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor)),
                              ]),
                            ],
                            if ((d.projectData?.name ?? '').isNotEmpty) ...[
                              const SizedBox(height: Dimensions.space10),
                              _SectionLabel(
                                  label: LocalStrings.project.tr,
                                  isDark: isDark),
                              const SizedBox(height: 4),
                              Text(d.projectData!.name!,
                                  style: semiBoldDefault),
                            ],
                            if ((d.saleAgent ?? '').isNotEmpty) ...[
                              const SizedBox(height: Dimensions.space10),
                              _SectionLabel(
                                  label: 'Sale Agent', isDark: isDark),
                              const SizedBox(height: 4),
                              Text(d.saleAgent!, style: semiBoldDefault),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Billing address ────────────────────────────
                      if (hasBilling) ...[
                        _GlassCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                  label: 'Billing Address', isDark: isDark),
                              const SizedBox(height: 6),
                              Text(
                                [
                                  d.billingStreet,
                                  d.billingCity,
                                  d.billingState,
                                  d.billingZip,
                                  d.billingCountry
                                ]
                                    .where((v) => v != null && v.isNotEmpty)
                                    .join(', '),
                                style: regularDefault.copyWith(
                                    color: ColorResources.blueGreyColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space12),
                      ],

                      // ── Items ──────────────────────────────────────
                      _SectionTitle(
                          title: LocalStrings.items.tr, isDark: isDark),
                      const SizedBox(height: Dimensions.space8),
                      _GlassCard(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF343434)
                                        : const Color(0xFFEFF3F8))
                                    .withValues(alpha: 0.6),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text('Description',
                                        style: regularSmall.copyWith(
                                            color: ColorResources.blueGreyColor,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  _TableHeaderCell('Qty'),
                                  _TableHeaderCell('Rate'),
                                  _TableHeaderCell('Total'),
                                ],
                              ),
                            ),
                            ...List.generate(d.items!.length, (index) {
                              final item = d.items![index];
                              final itemTotal =
                                  (double.tryParse(item.rate ?? '0') ?? 0) *
                                      (double.tryParse(item.qty ?? '0') ?? 0);
                              final isLast = index == d.items!.length - 1;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  border: isLast
                                      ? null
                                      : Border(
                                          bottom: BorderSide(
                                            color: (isDark
                                                    ? const Color(0xFF2A3347)
                                                    : const Color(0xFFD8E2EF))
                                                .withValues(alpha: 0.6),
                                            width: 0.5,
                                          ),
                                        ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.description ?? '',
                                              style: semiBoldDefault),
                                          if ((item.unit ?? '').isNotEmpty)
                                            Text(item.unit ?? '',
                                                style: regularSmall.copyWith(
                                                    color: ColorResources
                                                        .blueGreyColor)),
                                        ],
                                      ),
                                    ),
                                    _TableCell(item.qty ?? '0'),
                                    _TableCell('$cur${item.rate ?? '0'}'),
                                    _TableCell(
                                        '$cur${itemTotal.toStringAsFixed(2)}',
                                        bold: true),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Financial summary ──────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            _FinancialRow(
                                label: LocalStrings.subtotal.tr,
                                value: '$cur${d.subtotal ?? '0'}',
                                isDark: isDark),
                            if ((d.discountTotal ?? '0') != '0') ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                  label:
                                      '${LocalStrings.discount.tr}${(d.discountPercent ?? '0') != '0' ? ' (${d.discountPercent}%)' : ''}',
                                  value: '-$cur${d.discountTotal ?? '0'}',
                                  isDark: isDark),
                            ],
                            if ((d.totalTax ?? '0') != '0') ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                  label: LocalStrings.tax.tr,
                                  value: '$cur${d.totalTax ?? '0'}',
                                  isDark: isDark),
                            ],
                            if ((d.adjustment ?? '0') != '0') ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                  label: 'Adjustment',
                                  value: '$cur${d.adjustment ?? '0'}',
                                  isDark: isDark),
                            ],
                            if (hasPayments) ...[
                              const SizedBox(height: Dimensions.space8),
                              _FinancialRow(
                                label: LocalStrings.totalPaid.tr,
                                value:
                                    '- $cur${((double.tryParse(d.total ?? '0') ?? 0) - (double.tryParse(d.totalLeftToPay ?? '0') ?? 0)).toStringAsFixed(2)}',
                                isDark: isDark,
                                valueColor:
                                    ColorResources.invoiceStatusColor('5'),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.space10),
                              child: Divider(
                                color: (isDark
                                        ? const Color(0xFF2A3347)
                                        : const Color(0xFFD0DAE8))
                                    .withValues(alpha: 0.7),
                                height: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hasPayments
                                      ? LocalStrings.amountDue.tr
                                      : LocalStrings.total.tr,
                                  style: semiBoldLarge.copyWith(
                                      color: ColorResources.redColor),
                                ),
                                Text(
                                  '$cur${hasPayments ? (d.totalLeftToPay ?? '0') : (d.total ?? '0')}',
                                  style: boldExtraLarge.copyWith(
                                      color: ColorResources.redColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Payments / transactions ────────────────────
                      if (hasPayments) ...[
                        const SizedBox(height: Dimensions.space15),
                        _SectionTitle(
                            title: LocalStrings.transactions.tr,
                            isDark: isDark),
                        const SizedBox(height: Dimensions.space8),
                        ...d.payments!.map((p) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.space10),
                              child: _GlassCard(
                                isDark: isDark,
                                accentColor:
                                    ColorResources.invoiceStatusColor('5'),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            ColorResources.invoiceStatusColor(
                                                    '5')
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.payment_outlined,
                                          color:
                                              ColorResources.invoiceStatusColor(
                                                  '5'),
                                          size: 20),
                                    ),
                                    const SizedBox(width: Dimensions.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.methodName ?? '',
                                            style: semiBoldDefault,
                                          ),
                                          Text(
                                            p.dateRecorded ?? '',
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor),
                                          ),
                                          if ((p.note ?? '').isNotEmpty)
                                            Text(
                                              p.note!,
                                              style: regularSmall.copyWith(
                                                  color: ColorResources
                                                      .blueGreyColor),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '$cur${p.amount ?? ''}',
                                      style: semiBoldLarge.copyWith(
                                          color:
                                              ColorResources.invoiceStatusColor(
                                                  '5')),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],

                      // ── Terms ──────────────────────────────────────
                      if ((d.terms ?? '').isNotEmpty) ...[
                        const SizedBox(height: Dimensions.space12),
                        _NoteCard(
                          isDark: isDark,
                          label: LocalStrings.terms.tr,
                          content: d.terms!,
                          icon: Icons.gavel_outlined,
                        ),
                      ],

                      // ── Client note ────────────────────────────────
                      if ((d.clientNote ?? '').isNotEmpty) ...[
                        const SizedBox(height: Dimensions.space12),
                        _NoteCard(
                          isDark: isDark,
                          label: LocalStrings.clientNote.tr,
                          content: d.clientNote!,
                          icon: Icons.person_outline,
                        ),
                      ],

                      // ── Admin note ─────────────────────────────────
                      if ((d.adminNote ?? '').isNotEmpty) ...[
                        const SizedBox(height: Dimensions.space12),
                        _NoteCard(
                          isDark: isDark,
                          label: LocalStrings.adminNote.tr,
                          content: d.adminNote!,
                          icon: Icons.admin_panel_settings_outlined,
                        ),
                      ],

                      // ── Record Payment button ─────────────────────
                      // Perfex invoice status codes:
                      // 1=Unpaid, 2=Paid, 3=Partially Paid, 4=Overdue,
                      // 5=Cancelled, 6=Draft. Allow recording a payment for
                      // anything that still has a balance.
                      if (d.status == '1' ||
                          d.status == '3' ||
                          d.status == '4') ...[
                        const SizedBox(height: Dimensions.space20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showRecordPaymentSheet(
                                context, controller, widget.id, isDark),
                            icon: const Icon(Icons.payment_outlined, size: 18),
                            label: Text(LocalStrings.recordPayment.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],

                      // ── Email & PDF actions ───────────────────────
                      const SizedBox(height: Dimensions.space12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.email_outlined,
                              label: 'Send Email',
                              color: const Color(0xFF2196F3),
                              isLoading: controller.isSendingEmail,
                              onPressed: () =>
                                  controller.sendByEmail(widget.id),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'View PDF',
                              color: const Color(0xFFE53935),
                              onPressed: () => controller.openPdf(widget.id),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      // ── Mark as Sent / Cancel actions ─────────────
                      const SizedBox(height: Dimensions.space10),
                      Row(
                        children: [
                          if ((d.sent ?? '0') != '1') ...[
                            Expanded(
                              child: _ActionOutlineButton(
                                icon: Icons.mark_email_read_outlined,
                                label: 'Mark as Sent',
                                color: const Color(0xFF43A047),
                                isLoading: controller.isMarkingSent,
                                onPressed: () =>
                                    controller.markAsSent(widget.id),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: Dimensions.space10),
                          ],
                          Expanded(
                            child: d.status == '5'
                                ? _ActionOutlineButton(
                                    icon: Icons.restore_outlined,
                                    label: 'Uncancel',
                                    color: const Color(0xFF7B61FF),
                                    isLoading: controller.isCancelling,
                                    onPressed: () => controller.markCancelled(
                                        widget.id,
                                        cancel: false),
                                    isDark: isDark,
                                  )
                                : _ActionOutlineButton(
                                    icon: Icons.cancel_outlined,
                                    label: 'Cancel',
                                    color: ColorResources.colorGrey,
                                    isLoading: controller.isCancelling,
                                    onPressed: () =>
                                        controller.markCancelled(widget.id),
                                    isDark: isDark,
                                  ),
                          ),
                        ],
                      ),

                      // ── Copy & Overdue actions ────────────────────
                      const SizedBox(height: Dimensions.space10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.copy_outlined,
                              label: 'Copy Invoice',
                              color: const Color(0xFF00ACC1),
                              isLoading: controller.isCopyingInvoice,
                              onPressed: () =>
                                  controller.copyInvoice(widget.id),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.notification_important_outlined,
                              label: 'Send Overdue',
                              color: const Color(0xFFFF7043),
                              isLoading: controller.isSendingOverdue,
                              onPressed: () =>
                                  controller.sendOverdueNotice(widget.id),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      // ── Pause / Resume overdue reminders ─────────
                      const SizedBox(height: Dimensions.space10),
                      SizedBox(
                        width: double.infinity,
                        child: _ActionOutlineButton(
                          icon: (d.cancelOverdueReminders ?? '0') == '1'
                              ? Icons.play_circle_outline
                              : Icons.pause_circle_outline,
                          label: (d.cancelOverdueReminders ?? '0') == '1'
                              ? 'Resume Overdue Reminders'
                              : 'Pause Overdue Reminders',
                          color: const Color(0xFFEF6C00),
                          isLoading: controller.isTogglingReminders,
                          onPressed: () => controller.toggleOverdueReminders(
                            widget.id,
                            (d.cancelOverdueReminders ?? '0') != '1',
                          ),
                          isDark: isDark,
                        ),
                      ),

                      // ── Apply Credits & Merge ─────────────────────
                      const SizedBox(height: Dimensions.space10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.credit_score_outlined,
                              label: 'Apply Credits',
                              color: const Color(0xFF8E24AA),
                              isLoading: controller.isApplyingCredits,
                              onPressed: () => _showApplyCreditsSheet(
                                  context, controller, widget.id, isDark),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.merge_outlined,
                              label: 'Merge Invoices',
                              color: const Color(0xFF00897B),
                              isLoading: controller.isMergingInvoices,
                              onPressed: () => _showMergeInvoicesSheet(
                                  context, controller, widget.id, isDark),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      // ── Recurring info ────────────────────────────
                      if ((d.recurring ?? '0') != '0') ...[
                        const SizedBox(height: Dimensions.space15),
                        _SectionTitle(title: 'Recurring Info', isDark: isDark),
                        const SizedBox(height: Dimensions.space8),
                        _GlassCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              _FinancialRow(
                                  label: 'Recurring Every',
                                  value:
                                      '${d.recurring} ${_recurringTypeLabel(d.recurringType ?? '')}',
                                  isDark: isDark),
                              if ((d.cycles ?? '0') != '0') ...[
                                const SizedBox(height: Dimensions.space8),
                                _FinancialRow(
                                    label: 'Cycles',
                                    value:
                                        '${d.totalCycles ?? '0'} / ${d.cycles}',
                                    isDark: isDark),
                              ],
                              if ((d.lastRecurringDate ?? '').isNotEmpty) ...[
                                const SizedBox(height: Dimensions.space8),
                                _FinancialRow(
                                    label: 'Last Recurring Date',
                                    value: d.lastRecurringDate!,
                                    isDark: isDark),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // ── Attachments ───────────────────────────────
                      const SizedBox(height: Dimensions.space15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(title: 'Attachments', isDark: isDark),
                          TextButton.icon(
                            onPressed: () => _showUploadAttachmentSheet(
                                context, controller, widget.id, isDark),
                            icon: const Icon(Icons.attach_file, size: 16),
                            label: const Text('Add File'),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space8),
                      if (d.attachments == null || d.attachments!.isEmpty)
                        _GlassCard(
                          isDark: isDark,
                          child: Center(
                            child: Text('No attachments',
                                style: regularDefault.copyWith(
                                    color: ColorResources.blueGreyColor)),
                          ),
                        )
                      else
                        ...d.attachments!.map((att) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.space8),
                              child: _GlassCard(
                                isDark: isDark,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                          _attachmentIcon(att.fileType ?? ''),
                                          color: Theme.of(context).primaryColor,
                                          size: 20),
                                    ),
                                    const SizedBox(width: Dimensions.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(att.fileName ?? '',
                                              style: semiBoldDefault,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          Text(att.dateAdded ?? '',
                                              style: regularSmall.copyWith(
                                                  color: ColorResources
                                                      .blueGreyColor)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: ColorResources.redColor,
                                          size: 20),
                                      onPressed: () {
                                        const WarningAlertDialog()
                                            .warningAlertDialog(
                                          context,
                                          () {
                                            Get.back();
                                            controller.deleteAttachment(
                                                widget.id, att.id ?? '');
                                          },
                                          title: 'Delete Attachment',
                                          subTitle:
                                              'Are you sure you want to delete this attachment?',
                                          image: MyImages.exclamationImage,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),

                      const SizedBox(height: Dimensions.space20),
                      EntityExtrasSection(
                        relType: 'invoice',
                        relId: widget.id,
                        // attachments already shown above as a dedicated card
                        show: const {'reminders', 'activity', 'custom_fields'},
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

  IconData _attachmentIcon(String ext) {
    final e = ext.replaceAll('.', '').toLowerCase();
    if (['pdf'].contains(e)) return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(e)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(e)) return Icons.table_chart_outlined;
    if (['png', 'jpg', 'jpeg', 'gif'].contains(e)) return Icons.image_outlined;
    if (['zip'].contains(e)) return Icons.folder_zip_outlined;
    return Icons.attach_file;
  }

  String _recurringTypeLabel(String type) {
    switch (type) {
      case '1':
        return 'day(s)';
      case '2':
        return 'week(s)';
      case '3':
        return 'month(s)';
      case '4':
        return 'year(s)';
      default:
        return type;
    }
  }

  void _showUploadAttachmentSheet(BuildContext context,
      InvoiceController controller, String invoiceId, bool isDark) {
    bool visibleToCustomer = false;
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Upload Attachment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible to customer'),
                value: visibleToCustomer,
                onChanged: (v) => setState(() => visibleToCustomer = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Choose & Upload File'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    controller.pickAndUploadAttachment(
                        invoiceId, visibleToCustomer);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showRecordPaymentSheet(BuildContext context,
      InvoiceController controller, String invoiceId, bool isDark) async {
    final modes = await controller.loadPaymentModes();
    final modeList = modes.data ?? [];

    if (modeList.isEmpty) {
      CustomSnackBar.error(errorList: ['No payment modes available']);
      return;
    }

    final amountCtrl = TextEditingController(
        text: controller.invoiceDetailsModel.data?.totalLeftToPay ?? '');
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final noteCtrl = TextEditingController();
    String selectedModeId = modeList.first.id ?? '';

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(LocalStrings.recordPayment.tr,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: LocalStrings.amount.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        dateCtrl.text =
                            picked.toIso8601String().substring(0, 10);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: LocalStrings.date.tr,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedModeId,
                  decoration: InputDecoration(
                    labelText: LocalStrings.paymentMode.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  items: modeList
                      .map((m) => DropdownMenuItem(
                          value: m.id, child: Text(m.name ?? '')))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedModeId = v ?? selectedModeId;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: LocalStrings.note.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (amountCtrl.text.isEmpty) {
                        CustomSnackBar.error(
                            errorList: [LocalStrings.enterAmount.tr]);
                        return;
                      }
                      Navigator.pop(ctx);
                      controller.recordPayment(
                        invoiceId,
                        amountCtrl.text,
                        dateCtrl.text,
                        selectedModeId,
                        note: noteCtrl.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(LocalStrings.submit.tr),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Apply Credits sheet ───────────────────────────────────────────────────
  void _showApplyCreditsSheet(BuildContext context,
      InvoiceController controller, String invoiceId, bool isDark) async {
    await controller.loadAvailableCredits(invoiceId);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => GetBuilder<InvoiceController>(builder: (ctrl) {
        final credits = ctrl.availableCreditsList;
        final amountControllers = <int, TextEditingController>{};
        return StatefulBuilder(builder: (ctx, setS) {
          final bottomPad = MediaQuery.of(ctx).padding.bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apply Credits', style: semiBoldExtraLarge),
                const SizedBox(height: 12),
                if (ctrl.isCreditsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (credits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                        child: Text('No available credits for this customer',
                            style: regularDefault.copyWith(
                                color: ColorResources.blueGreyColor))),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: credits.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space8),
                      itemBuilder: (ctx2, i) {
                        final cr = credits[i];
                        final cnId = cr['id']?.toString() ?? '';
                        final ref = cr['prefix']?.toString() ?? '';
                        final num = cr['number']?.toString() ?? '';
                        final balance =
                            cr['remaining_amount']?.toString() ?? '0';
                        amountControllers.putIfAbsent(
                            i, () => TextEditingController(text: balance));
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$ref$num', style: semiBoldDefault),
                                  Text('Available: $balance',
                                      style: regularSmall.copyWith(
                                          color: ColorResources.blueGreyColor)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: amountControllers[i],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    isDense: true,
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: ctrl.isSubmitLoading
                                  ? null
                                  : () async {
                                      final amt =
                                          amountControllers[i]?.text ?? '';
                                      final ok = await ctrl.applyCredit(
                                          invoiceId, cnId, amt);
                                      if (ok && ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8E24AA),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8)),
                              child: ctrl.isSubmitLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Apply'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        });
      }),
    );
  }

  // ── Merge Invoices sheet ──────────────────────────────────────────────────
  void _showMergeInvoicesSheet(BuildContext context,
      InvoiceController controller, String currentInvoiceId, bool isDark) {
    final allInvoices = controller.invoicesModel.data ?? [];
    final currentInvoice = controller.invoiceDetailsModel.data;
    final clientId = currentInvoice?.clientId ?? '';
    final sameClientInvoices = allInvoices
        .where((inv) =>
            inv.clientId?.toString() == clientId &&
            inv.id?.toString() != currentInvoiceId &&
            inv.status != '5')
        .toList();

    final selected = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final bottomPad = MediaQuery.of(ctx).padding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merge Invoices', style: semiBoldExtraLarge),
              const SizedBox(height: 4),
              Text(
                  'Select invoices from the same customer to merge with the current invoice.',
                  style: regularSmall.copyWith(
                      color: ColorResources.blueGreyColor)),
              const SizedBox(height: 12),
              if (sameClientInvoices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('No other invoices for this customer',
                          style: regularDefault.copyWith(
                              color: ColorResources.blueGreyColor))),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sameClientInvoices.length,
                    itemBuilder: (ctx2, i) {
                      final inv = sameClientInvoices[i];
                      final id = inv.id?.toString() ?? '';
                      final label =
                          '${inv.prefix ?? ''}${inv.number ?? ''} — ${inv.total ?? ''}';
                      final isChecked = selected.contains(id);
                      return CheckboxListTile(
                        dense: true,
                        value: isChecked,
                        title: Text(label, style: regularDefault),
                        onChanged: (v) => setS(() {
                          if (v == true) {
                            selected.add(id);
                          } else {
                            selected.remove(id);
                          }
                        }),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selected.isEmpty || controller.isSubmitLoading
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await controller
                              .mergeInvoices([currentInvoiceId, ...selected]);
                        },
                  icon: controller.isSubmitLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.merge_outlined),
                  label: Text(
                      'Merge ${selected.isEmpty ? '' : '(${selected.length + 1} invoices)'}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
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
    this.padding,
  });

  final bool isDark;
  final Widget child;
  final Color? accentColor;
  final EdgeInsets? padding;

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
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: semiBoldLarge.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color),
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
      label,
      style: regularSmall.copyWith(color: ColorResources.blueGreyColor),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 13, color: ColorResources.blueGreyColor),
          const SizedBox(width: 4),
          Text(label,
              style:
                  regularSmall.copyWith(color: ColorResources.blueGreyColor)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: semiBoldDefault),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: VerticalDivider(
          width: 1,
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.7),
        ),
      );
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 70,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: regularSmall.copyWith(
              color: ColorResources.blueGreyColor, fontWeight: FontWeight.w600),
        ),
      );
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {this.bold = false});
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 70,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: bold ? semiBoldDefault : regularDefault,
        ),
      );
}

class _FinancialRow extends StatelessWidget {
  const _FinancialRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

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
              color:
                  valueColor ?? Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
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
          Row(children: [
            Icon(icon, size: 15, color: ColorResources.blueGreyColor),
            const SizedBox(width: 6),
            Text(label,
                style: semiBoldDefault.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ]),
          const SizedBox(height: Dimensions.space8),
          Divider(
            color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
                .withValues(alpha: 0.7),
            height: 1,
          ),
          const SizedBox(height: Dimensions.space8),
          Text(content,
              style:
                  regularDefault.copyWith(color: ColorResources.blueGreyColor)),
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

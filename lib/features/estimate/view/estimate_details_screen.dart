import 'dart:ui';

import 'package:flutex_admin/common/components/card/custom_card.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/extras/entity_extras_section.dart';
import 'package:flutex_admin/common/components/table_item.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/estimate/controller/estimate_controller.dart';
import 'package:flutex_admin/features/estimate/repo/estimate_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateDetailsScreen extends StatefulWidget {
  const EstimateDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<EstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<EstimateDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(EstimateRepo(apiClient: Get.find()));
    final controller = Get.put(EstimateController(estimateRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadEstimateDetails(widget.id);
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
            GetBuilder<EstimateController>(
              builder: (controller) {
                if (controller.isLoading ||
                    controller.estimateDetailsModel.data == null) {
                  return const CustomLoader();
                }
                final d = controller.estimateDetailsModel.data!;
                final statusColor =
                    ColorResources.estimateStatusColor(d.status ?? '');
                final statusLabel =
                    Converter.estimateStatusString(d.status ?? '');
                final cur = d.currencySymbol ?? '';
                final estimateNumber =
                    d.formattedNumber ?? '${d.prefix ?? ''}${d.number ?? ''}';
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                          Dimensions.space15, Dimensions.space10),
                      child: _GlassDetailHeader(
                        isDark: isDark,
                        title: LocalStrings.estimateDetails.tr,
                        onEdit: () => Get.toNamed(
                            RouteHelper.updateEstimateScreen,
                            arguments: widget.id),
                        onConvert: () {
                          const WarningAlertDialog().warningAlertDialog(
                            context,
                            () {
                              Get.back();
                              Get.find<EstimateController>()
                                  .convertToInvoice(widget.id);
                            },
                            title: LocalStrings.convertToInvoice.tr,
                            subTitle: LocalStrings.convertToInvoiceMsg.tr,
                            image: MyImages.exclamationImage,
                          );
                        },
                        onDelete: () => const WarningAlertDialog()
                            .warningAlertDialog(context, () {
                          Get.back();
                          Get.find<EstimateController>()
                              .deleteEstimate(widget.id);
                          Navigator.pop(context);
                        },
                                title: LocalStrings.deleteEstimate.tr,
                                subTitle:
                                    LocalStrings.deleteEstimateWarningMSg.tr,
                                image: MyImages.exclamationImage),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).cardColor,
                        onRefresh: () async =>
                            controller.loadEstimateDetails(widget.id),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Hero card ──────────────────────────
                                _GlassCard(
                                  isDark: isDark,
                                  accentColor: statusColor,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.18),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(Icons.assignment_outlined,
                                            color: statusColor, size: 26),
                                      ),
                                      const SizedBox(width: Dimensions.space12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              estimateNumber,
                                              style: boldExtraLarge.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color),
                                            ),
                                            if ((d.clientData?.company ?? '')
                                                .isNotEmpty)
                                              Text(
                                                d.clientData!.company!,
                                                style: regularDefault.copyWith(
                                                    color: ColorResources
                                                        .blueGreyColor),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$cur${d.total ?? '0'}',
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
                                              color: statusColor.withValues(
                                                  alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: statusColor.withValues(
                                                      alpha: 0.4)),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: regularSmall.copyWith(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space12),
                                // ── Dates ─────────────────────────────
                                _GlassCard(
                                  isDark: isDark,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _InfoColumn(
                                          label: LocalStrings.estimateDate.tr,
                                          value: d.date ?? '-',
                                          icon: Icons.calendar_today_outlined,
                                          isDark: isDark,
                                        ),
                                      ),
                                      _VerticalDivider(isDark: isDark),
                                      Expanded(
                                        child: _InfoColumn(
                                          label: LocalStrings.dueDate.tr,
                                          value: d.expiryDate ?? '-',
                                          icon: Icons.event_busy_outlined,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space12),
                                // ── Client info ────────────────────────
                                _GlassCard(
                                  isDark: isDark,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionLabel(
                                          label: LocalStrings.company.tr,
                                          isDark: isDark),
                                      const SizedBox(height: 4),
                                      Text(d.clientData?.company ?? '-',
                                          style: semiBoldDefault),
                                      if ((d.referenceNo ?? '').isNotEmpty) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _SectionLabel(
                                            label: LocalStrings.referenceNo.tr,
                                            isDark: isDark),
                                        const SizedBox(height: 4),
                                        Text(d.referenceNo!,
                                            style: regularDefault),
                                      ],
                                      if ((d.clientData?.phoneNumber ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _SectionLabel(
                                            label: 'Phone', isDark: isDark),
                                        const SizedBox(height: 4),
                                        Text(d.clientData!.phoneNumber!,
                                            style: regularDefault),
                                      ],
                                      if ([
                                        d.clientData?.address,
                                        d.clientData?.city,
                                        d.clientData?.state,
                                        d.clientData?.country,
                                      ].any((v) =>
                                          v != null && v.isNotEmpty)) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _SectionLabel(
                                            label: 'Address', isDark: isDark),
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            d.clientData?.address,
                                            d.clientData?.city,
                                            d.clientData?.state,
                                            d.clientData?.country,
                                          ]
                                              .where((v) =>
                                                  v != null && v.isNotEmpty)
                                              .join(', '),
                                          style: regularDefault.copyWith(
                                              color:
                                                  ColorResources.blueGreyColor),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space12),
                                // ── Items ─────────────────────────────
                                _SectionTitle(
                                    title: LocalStrings.items.tr,
                                    isDark: isDark),
                                const SizedBox(height: Dimensions.space8),
                                _GlassCard(
                                  isDark: isDark,
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: (isDark
                                                  ? const Color(0xFF343434)
                                                  : const Color(0xFFEFF3F8))
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Description',
                                                style: regularSmall.copyWith(
                                                    color: ColorResources
                                                        .blueGreyColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            _TableHeaderCell('Qty'),
                                            _TableHeaderCell('Rate'),
                                            _TableHeaderCell('Total'),
                                          ],
                                        ),
                                      ),
                                      ...List.generate(d.items!.length,
                                          (index) {
                                        final item = d.items![index];
                                        final itemTotal = (double.tryParse(
                                                    item.rate ?? '0') ??
                                                0) *
                                            (double.tryParse(item.qty ?? '0') ??
                                                0);
                                        final isLast =
                                            index == d.items!.length - 1;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: isLast
                                                ? null
                                                : Border(
                                                    bottom: BorderSide(
                                                      color: (isDark
                                                              ? const Color(
                                                                  0xFF2A3347)
                                                              : const Color(
                                                                  0xFFD8E2EF))
                                                          .withValues(
                                                              alpha: 0.6),
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
                                                    if ((item.unit ?? '')
                                                        .isNotEmpty)
                                                      Text(
                                                        item.unit ?? '',
                                                        style: regularSmall.copyWith(
                                                            color: ColorResources
                                                                .blueGreyColor),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              _TableCell(item.qty ?? '0'),
                                              _TableCell(
                                                  '$cur${item.rate ?? '0'}'),
                                              _TableCell(
                                                '$cur${itemTotal.toStringAsFixed(2)}',
                                                bold: true,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space12),
                                // ── Financial summary ──────────────────
                                _GlassCard(
                                  isDark: isDark,
                                  child: Column(
                                    children: [
                                      _FinancialRow(
                                        label: LocalStrings.subtotal.tr,
                                        value: '$cur${d.subTotal ?? '0'}',
                                        isDark: isDark,
                                      ),
                                      if ((d.discountTotal ?? '0') != '0' &&
                                          (d.discountTotal ?? '')
                                              .isNotEmpty) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _FinancialRow(
                                          label:
                                              '${LocalStrings.discount.tr}${(d.discountPercent ?? '0') != '0' ? ' (${d.discountPercent}%)' : ''}',
                                          value:
                                              '-$cur${d.discountTotal ?? '0'}',
                                          isDark: isDark,
                                        ),
                                      ],
                                      if ((d.totalTax ?? '0') != '0' &&
                                          (d.totalTax ?? '').isNotEmpty) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _FinancialRow(
                                          label: LocalStrings.tax.tr,
                                          value: '$cur${d.totalTax ?? '0'}',
                                          isDark: isDark,
                                        ),
                                      ],
                                      if ((d.adjustment ?? '0') != '0' &&
                                          (d.adjustment ?? '').isNotEmpty) ...[
                                        const SizedBox(
                                            height: Dimensions.space8),
                                        _FinancialRow(
                                          label: 'Adjustment',
                                          value: '$cur${d.adjustment ?? '0'}',
                                          isDark: isDark,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            LocalStrings.total.tr,
                                            style: semiBoldLarge.copyWith(
                                                color: ColorResources.redColor),
                                          ),
                                          Text(
                                            '$cur${d.total ?? '0'}',
                                            style: boldExtraLarge.copyWith(
                                                color: ColorResources.redColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space10),
                                if (controller.estimateDetailsModel.data!
                                        .clientNote !=
                                    '')
                                  CustomCard(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LocalStrings.clientNote.tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const Divider(
                                          color: ColorResources.blueGreyColor,
                                          thickness: 0.50,
                                        ),
                                        Text(
                                          controller.estimateDetailsModel.data!
                                                  .clientNote ??
                                              '-',
                                          style: lightSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: Dimensions.space10),
                                if (controller
                                        .estimateDetailsModel.data!.terms !=
                                    '')
                                  CustomCard(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LocalStrings.terms.tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const Divider(
                                          color: ColorResources.blueGreyColor,
                                          thickness: 0.50,
                                        ),
                                        Text(
                                          controller.estimateDetailsModel.data!
                                                  .terms ??
                                              '-',
                                          style: lightSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: Dimensions.space15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionButton(
                                        icon: Icons.email_outlined,
                                        label: 'Send Email',
                                        color: const Color(0xFF2196F3),
                                        isLoading: controller.isSendingEmail,
                                        onPressed: () =>
                                            controller.sendByEmail(widget.id),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            controller.openPdf(widget.id),
                                        icon: const Icon(
                                            Icons.picture_as_pdf_outlined,
                                            size: 18),
                                        label: const Text('View PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFE53935),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _EstimateStatusButton(
                                        icon: Icons.check_circle_outline,
                                        label: 'Accepted',
                                        color: const Color(0xFF43A047),
                                        isActive: controller
                                                .estimateDetailsModel
                                                .data
                                                ?.status ==
                                            '4',
                                        onPressed: () => controller
                                            .markActionStatus(widget.id, '4'),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space8),
                                    Expanded(
                                      child: _EstimateStatusButton(
                                        icon: Icons.send_outlined,
                                        label: 'Sent',
                                        color: const Color(0xFF2196F3),
                                        isActive: controller
                                                .estimateDetailsModel
                                                .data
                                                ?.status ==
                                            '2',
                                        onPressed: () => controller
                                            .markActionStatus(widget.id, '2'),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space8),
                                    Expanded(
                                      child: _EstimateStatusButton(
                                        icon: Icons.cancel_outlined,
                                        label: 'Declined',
                                        color: const Color(0xFFE53935),
                                        isActive: controller
                                                .estimateDetailsModel
                                                .data
                                                ?.status ==
                                            '3',
                                        onPressed: () => controller
                                            .markActionStatus(widget.id, '3'),
                                      ),
                                    ),
                                  ],
                                ),

                                // ── Copy & Expiry Reminder ──────────────
                                const SizedBox(height: Dimensions.space10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionButton(
                                        icon: Icons.copy_outlined,
                                        label: 'Copy Estimate',
                                        color: const Color(0xFF00ACC1),
                                        isLoading: controller.isCopyingEstimate,
                                        onPressed: () =>
                                            controller.copyEstimate(widget.id),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space10),
                                    Expanded(
                                      child: _ActionButton(
                                        icon: Icons.schedule_send_outlined,
                                        label: 'Expiry Reminder',
                                        color: const Color(0xFFFF7043),
                                        isLoading:
                                            controller.isSendingExpiryReminder,
                                        onPressed: () => controller
                                            .sendExpiryReminder(widget.id),
                                      ),
                                    ),
                                  ],
                                ),

                                // ── Admin Note ──────────────────────────
                                const SizedBox(height: Dimensions.space10),
                                CustomCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Admin Note',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18),
                                            color:
                                                Theme.of(context).primaryColor,
                                            tooltip: 'Edit admin note',
                                            onPressed: () =>
                                                _showAdminNoteSheet(context,
                                                    controller, widget.id),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          color: ColorResources.blueGreyColor,
                                          thickness: 0.5),
                                      if ((controller.estimateDetailsModel.data
                                                  ?.adminNote ??
                                              '')
                                          .isNotEmpty)
                                        Text(
                                          controller.estimateDetailsModel.data!
                                                  .adminNote ??
                                              '',
                                          style: lightSmall,
                                        )
                                      else
                                        Text('No admin note',
                                            style: lightSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor)),
                                    ],
                                  ),
                                ),

                                // ── Acceptance / Signature info ─────────
                                if (_hasAcceptanceInfo(
                                    controller.estimateDetailsModel.data)) ...[
                                  const SizedBox(height: Dimensions.space10),
                                  CustomCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Acceptance Info',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                            const Spacer(),
                                            TextButton.icon(
                                              onPressed: controller
                                                      .isSubmitLoading
                                                  ? null
                                                  : () {
                                                      const WarningAlertDialog()
                                                          .warningAlertDialog(
                                                        context,
                                                        () {
                                                          Get.back();
                                                          controller
                                                              .clearSignature(
                                                                  widget.id);
                                                        },
                                                        title:
                                                            'Clear Signature',
                                                        subTitle:
                                                            'This will remove the acceptance signature and reset the status. Continue?',
                                                        image: MyImages
                                                            .exclamationImage,
                                                      );
                                                    },
                                              icon: const Icon(
                                                  Icons.delete_sweep_outlined,
                                                  size: 16,
                                                  color:
                                                      ColorResources.redColor),
                                              label: const Text(
                                                  'Clear Signature',
                                                  style: TextStyle(
                                                      color: ColorResources
                                                          .redColor,
                                                      fontSize: 13)),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                            color: ColorResources.blueGreyColor,
                                            thickness: 0.5),
                                        _AcceptanceRow(
                                          label: 'Accepted by',
                                          value: [
                                            controller.estimateDetailsModel.data
                                                    ?.acceptanceFirstname ??
                                                '',
                                            controller.estimateDetailsModel.data
                                                    ?.acceptanceLastname ??
                                                '',
                                          ]
                                              .where((s) => s.isNotEmpty)
                                              .join(' '),
                                        ),
                                        if ((controller.estimateDetailsModel
                                                    .data?.acceptanceEmail ??
                                                '')
                                            .isNotEmpty)
                                          _AcceptanceRow(
                                            label: 'Email',
                                            value: controller
                                                    .estimateDetailsModel
                                                    .data!
                                                    .acceptanceEmail ??
                                                '',
                                          ),
                                        if ((controller.estimateDetailsModel
                                                    .data?.acceptanceDate ??
                                                '')
                                            .isNotEmpty)
                                          _AcceptanceRow(
                                            label: 'Date',
                                            value: controller
                                                    .estimateDetailsModel
                                                    .data!
                                                    .acceptanceDate ??
                                                '',
                                          ),
                                        if ((controller.estimateDetailsModel
                                                    .data?.acceptanceIp ??
                                                '')
                                            .isNotEmpty)
                                          _AcceptanceRow(
                                            label: 'IP',
                                            value: controller
                                                    .estimateDetailsModel
                                                    .data!
                                                    .acceptanceIp ??
                                                '',
                                          ),
                                      ],
                                    ),
                                  ),
                                ],

                                // ── Attachments ─────────────────────────
                                const SizedBox(height: Dimensions.space15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Attachments',
                                        style: mediumLarge.copyWith(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor)),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _showUploadAttachmentSheet(
                                              context, controller, widget.id),
                                      icon: const Icon(Icons.attach_file,
                                          size: 16),
                                      label: const Text('Add File'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space8),
                                if ((controller.estimateDetailsModel.data
                                            ?.attachments ??
                                        [])
                                    .isEmpty)
                                  CustomCard(
                                    child: Center(
                                      child: Text('No attachments',
                                          style: regularDefault.copyWith(
                                              color: ColorResources
                                                  .blueGreyColor)),
                                    ),
                                  )
                                else
                                  ...controller
                                      .estimateDetailsModel.data!.attachments!
                                      .map((att) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions.space8),
                                            child: CustomCard(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Icon(
                                                        _attachmentIcon(
                                                            att.fileType ?? ''),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 20),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          Dimensions.space12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(att.fileName ?? '',
                                                            style:
                                                                semiBoldDefault,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        Text(
                                                            att.dateAdded ?? '',
                                                            style: regularSmall
                                                                .copyWith(
                                                                    color: ColorResources
                                                                        .blueGreyColor)),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: ColorResources
                                                            .redColor,
                                                        size: 20),
                                                    onPressed: () {
                                                      const WarningAlertDialog()
                                                          .warningAlertDialog(
                                                        context,
                                                        () {
                                                          Get.back();
                                                          controller
                                                              .deleteAttachment(
                                                                  widget.id,
                                                                  att.id ?? '');
                                                        },
                                                        title:
                                                            'Delete Attachment',
                                                        subTitle:
                                                            'Are you sure you want to delete this attachment?',
                                                        image: MyImages
                                                            .exclamationImage,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                const SizedBox(height: Dimensions.space20),
                                EntityExtrasSection(
                                  relType: 'estimate',
                                  relId: widget.id,
                                  show: const {
                                    'reminders',
                                    'activity',
                                    'custom_fields'
                                  },
                                ),
                                const SizedBox(height: Dimensions.space25),
                              ],
                            ),
                          ),
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

  IconData _attachmentIcon(String ext) {
    final e = ext.replaceAll('.', '').toLowerCase();
    if (['pdf'].contains(e)) return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(e)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(e)) return Icons.table_chart_outlined;
    if (['png', 'jpg', 'jpeg', 'gif'].contains(e)) return Icons.image_outlined;
    if (['zip'].contains(e)) return Icons.folder_zip_outlined;
    return Icons.attach_file;
  }

  void _showUploadAttachmentSheet(
      BuildContext context, EstimateController controller, String estimateId) {
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
                        estimateId, visibleToCustomer);
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

  bool _hasAcceptanceInfo(dynamic data) {
    if (data == null) return false;
    return (data.acceptanceFirstname ?? '').isNotEmpty ||
        (data.acceptanceLastname ?? '').isNotEmpty ||
        (data.acceptanceEmail ?? '').isNotEmpty;
  }

  void _showAdminNoteSheet(
      BuildContext ctx, EstimateController controller, String estimateId) {
    final existing = controller.estimateDetailsModel.data?.adminNote ?? '';
    final noteController = TextEditingController(text: existing);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: ColorResources.blueGreyColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Admin Note',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter admin note...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(bCtx);
                    controller.updateAdminNote(
                        estimateId, noteController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Note'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _AcceptanceRow extends StatelessWidget {
  const _AcceptanceRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: lightSmall.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: lightSmall)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
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
        backgroundColor: color.withValues(alpha: 0.06),
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

class _GlassDetailHeader extends StatelessWidget {
  const _GlassDetailHeader({
    required this.isDark,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    this.onConvert,
  });
  final bool isDark;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onConvert;

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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: Dimensions.space10),
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
              ),
              if (onConvert != null)
                Tooltip(
                  message: LocalStrings.convertToInvoice.tr,
                  child: IconButton(
                    onPressed: onConvert,
                    icon: Icon(Icons.receipt_long_outlined,
                        size: 20, color: Colors.blue.withValues(alpha: 0.85)),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimateStatusButton extends StatelessWidget {
  const _EstimateStatusButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: isActive ? color.withValues(alpha: 0.12) : null,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color)),
        ],
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

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: regularSmall.copyWith(
            color: ColorResources.blueGreyColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {this.bold = false});
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: bold ? semiBoldDefault : regularDefault,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
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
        Text(label, style: lightDefault),
        Text(value,
            style: semiBoldDefault.copyWith(
                color: valueColor ??
                    Theme.of(context).textTheme.bodyLarge?.color)),
      ],
    );
  }
}

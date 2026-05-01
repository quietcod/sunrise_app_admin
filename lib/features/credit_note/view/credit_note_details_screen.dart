import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/credit_note/controller/credit_note_controller.dart';
import 'package:flutex_admin/features/credit_note/repo/credit_note_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreditNoteDetailsScreen extends StatefulWidget {
  const CreditNoteDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<CreditNoteDetailsScreen> createState() =>
      _CreditNoteDetailsScreenState();
}

class _CreditNoteDetailsScreenState extends State<CreditNoteDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => CreditNoteRepo(apiClient: Get.find()));
    final controller =
        Get.put(CreditNoteController(creditNoteRepo: Get.find()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDetails(widget.id);
    });
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: regularSmall.copyWith(
                color: ColorResources.contentTextColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: semiBoldDefault.copyWith(
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : Colors.white)
                .withValues(alpha: .45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isDark ? const Color(0xFF4A5C79) : Colors.white)
                  .withValues(alpha: .55),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreditNoteController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (controller.isLoading || controller.selectedCreditNote == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final note = controller.selectedCreditNote!;

      Color statusColor;
      switch (note.status) {
        case '1':
          statusColor = ColorResources.secondaryColor;
          break;
        case '2':
          statusColor = const Color(0xFF4CAF50);
          break;
        default:
          statusColor = ColorResources.colorGrey;
      }

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
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: isDark ? .12 : .08),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => controller.loadDetails(widget.id),
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.space15,
                      0,
                      Dimensions.space15,
                      Dimensions.space25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_rounded),
                                onPressed: () => Get.back(),
                              ),
                              Expanded(
                                child: Text(
                                  note.formattedNumber,
                                  style: boldLarge.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              // Edit action
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => Get.toNamed(
                                  RouteHelper.updateCreditNoteScreen,
                                  arguments: note.id,
                                ),
                              ),
                              // Delete action
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  const WarningAlertDialog().warningAlertDialog(
                                    context,
                                    () async {
                                      Get.back();
                                      final ok = await controller
                                          .deleteCreditNote(note.id!);
                                      if (ok) Get.back();
                                    },
                                    title: LocalStrings.deleteCreditNote.tr,
                                    subTitle: LocalStrings
                                        .deleteCreditNoteWarningMsg.tr,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Status chip
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: .4)),
                            ),
                            child: Text(note.statusLabel,
                                style: semiBoldDefault.copyWith(
                                    color: statusColor)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Amount hero
                        _glassCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              Text(
                                '${note.currencySymbol ?? ''}${note.total ?? '0'}',
                                style: boldLarge.copyWith(
                                  color: statusColor,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LocalStrings.total.tr,
                                style: regularSmall.copyWith(
                                  color: ColorResources.contentTextColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _amountChip(
                                    LocalStrings.subtotal.tr,
                                    '${note.currencySymbol ?? ''}${note.subtotal ?? '0'}',
                                    isDark,
                                    statusColor,
                                  ),
                                  _amountChip(
                                    LocalStrings.discount.tr,
                                    '${note.discountPercent ?? '0'}%',
                                    isDark,
                                    statusColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Details card
                        _glassCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocalStrings.creditNoteDetails.tr,
                                style: semiBoldLarge.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              const Divider(height: 20),
                              _infoRow(LocalStrings.client.tr,
                                  note.clientName ?? '', isDark),
                              _infoRow(LocalStrings.creditNoteNumber.tr,
                                  note.formattedNumber, isDark),
                              _infoRow(LocalStrings.date.tr, note.date ?? '',
                                  isDark),
                              if (note.expirydate?.isNotEmpty == true)
                                _infoRow(LocalStrings.expiryDate.tr,
                                    note.expirydate!, isDark),
                              if (note.referenceNo?.isNotEmpty == true)
                                _infoRow(LocalStrings.referenceNo.tr,
                                    note.referenceNo!, isDark),
                            ],
                          ),
                        ),
                        // Items
                        if (note.items?.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          _glassCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalStrings.addItems.tr,
                                  style: semiBoldLarge.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                const Divider(height: 20),
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: ColorResources
                                                .contentTextColor
                                                .withValues(alpha: .25),
                                          ),
                                        ),
                                      ),
                                      children: [
                                        _th(LocalStrings.itemName.tr),
                                        _th(LocalStrings.qty.tr),
                                        _th(LocalStrings.rate.tr),
                                        _th(LocalStrings.total.tr,
                                            align: TextAlign.right),
                                      ],
                                    ),
                                    ...note.items!.map((item) {
                                      final qty = double.tryParse(
                                              item['qty']?.toString() ?? '1') ??
                                          1;
                                      final rate = double.tryParse(
                                              item['rate']?.toString() ??
                                                  '0') ??
                                          0;
                                      final rowTotal = qty * rate;
                                      return TableRow(
                                        children: [
                                          _td(item['description']?.toString() ??
                                              ''),
                                          _td(item['qty']?.toString() ?? ''),
                                          _td(item['rate']?.toString() ?? ''),
                                          _td('${note.currencySymbol ?? ''}${rowTotal.toStringAsFixed(2)}',
                                              align: TextAlign.right),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Notes
                        if (note.adminnote?.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          _glassCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(LocalStrings.adminNote.tr,
                                    style: semiBoldDefault.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)),
                                const SizedBox(height: 8),
                                Text(note.adminnote!,
                                    style: regularDefault.copyWith(
                                        color:
                                            ColorResources.contentTextColor)),
                              ],
                            ),
                          ),
                        ],
                        // ── Action buttons ──────────────────────────
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _actionOutlineButton(
                                icon: Icons.picture_as_pdf_outlined,
                                label: 'View PDF',
                                color: const Color(0xFFE53935),
                                onPressed: () => controller.openPdf(widget.id),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionOutlineButton(
                                icon: Icons.email_outlined,
                                label: 'Send Email',
                                color: const Color(0xFF1E88E5),
                                isLoading: controller.isSubmitting,
                                onPressed: () =>
                                    controller.sendByEmail(widget.id),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _actionOutlineButton(
                                icon: Icons.receipt_long_outlined,
                                label: 'Apply to Invoice',
                                color: const Color(0xFF43A047),
                                onPressed: () => _showApplyToInvoiceDialog(
                                    context, controller, widget.id),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionOutlineButton(
                                icon: Icons.money_off_outlined,
                                label: 'Refund',
                                color: const Color(0xFFFF9800),
                                onPressed: () => _showRefundDialog(
                                    context, controller, widget.id),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _amountChip(String label, String value, bool isDark, Color color) {
    return Column(
      children: [
        Text(value,
            style: semiBoldDefault.copyWith(color: color, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style: regularSmall.copyWith(
                color: ColorResources.contentTextColor, fontSize: 11)),
      ],
    );
  }

  Widget _th(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(text,
          style: semiBoldSmall.copyWith(
              color: ColorResources.contentTextColor, fontSize: 11),
          textAlign: align),
    );
  }

  Widget _td(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(text,
          style: regularSmall.copyWith(fontSize: 12), textAlign: align),
    );
  }

  Widget _actionOutlineButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
    bool isLoading = false,
  }) {
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

  void _showApplyToInvoiceDialog(
      BuildContext context, CreditNoteController controller, String id) {
    final invoiceIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply to Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: invoiceIdCtrl,
              decoration: const InputDecoration(labelText: 'Invoice ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocalStrings.cancel.tr),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.applyToInvoice(
                  id, invoiceIdCtrl.text, amountCtrl.text);
            },
            child: Text(LocalStrings.submit.tr),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(
      BuildContext context, CreditNoteController controller, String id) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocalStrings.cancel.tr),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.refund(id, amountCtrl.text, noteCtrl.text);
            },
            child: Text(LocalStrings.submit.tr),
          ),
        ],
      ),
    );
  }
}

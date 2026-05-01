import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/payment/controller/payment_controller.dart';
import 'package:flutex_admin/features/payment/repo/payment_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PaymentRepo(apiClient: Get.find()));
    final controller = Get.put(PaymentController(paymentRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPaymentDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.paymentDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.paymentDetailsModel.data!;
      final isActive = d.active != '0';
      final accentColor =
          isActive ? ColorResources.greenColor : ColorResources.blueColor;

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
                      title: LocalStrings.paymentDetails.tr,
                      isActive: isActive,
                      accentColor: accentColor,
                    ),
                  ),
                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async =>
                          controller.loadPaymentDetails(widget.id),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.space15),
                        child: Column(
                          children: [
                            // Amount hero card
                            _GlassCard(
                              isDark: isDark,
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      LocalStrings.totalAmount.tr,
                                      style: regularDefault.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                    const SizedBox(height: Dimensions.space8),
                                    Text(
                                      d.amount ?? '-',
                                      style: boldExtraLarge.copyWith(
                                          color: accentColor, fontSize: 32),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.space12),
                            // Details card
                            _GlassCard(
                              isDark: isDark,
                              child: Column(
                                children: [
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.paymentMode.tr,
                                    value: d.name ?? '-',
                                    icon: Icons.payments_outlined,
                                  ),
                                  _HDivider(isDark: isDark),
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.paymentDate.tr,
                                    value: d.date ?? '-',
                                    icon: Icons.calendar_today_outlined,
                                  ),
                                  _HDivider(isDark: isDark),
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.invoice.tr,
                                    value: '#${d.invoiceId ?? '-'}',
                                    icon: Icons.receipt_outlined,
                                  ),
                                  _HDivider(isDark: isDark),
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.transactionId.tr,
                                    value: d.transactionId?.isNotEmpty == true
                                        ? d.transactionId!
                                        : '-',
                                    icon: Icons.tag_outlined,
                                  ),
                                  if ((d.note ?? '').isNotEmpty) ...[
                                    _HDivider(isDark: isDark),
                                    _InfoRow(
                                      isDark: isDark,
                                      label: LocalStrings.clientNote.tr,
                                      value: d.note!,
                                      icon: Icons.notes_outlined,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.space15),
                            // ── Action buttons ──────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.email_outlined,
                                    label: 'Send Receipt',
                                    color: const Color(0xFF2196F3),
                                    isLoading: controller.isSubmitLoading,
                                    isDark: isDark,
                                    onPressed: () =>
                                        controller.sendReceipt(widget.id),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space10),
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.picture_as_pdf_outlined,
                                    label: 'View PDF',
                                    color: const Color(0xFFE53935),
                                    isDark: isDark,
                                    onPressed: () =>
                                        controller.openPdf(widget.id),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space25),
                          ],
                        ),
                      ),
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.isDark,
    required this.title,
    required this.isActive,
    required this.accentColor,
  });
  final bool isDark;
  final String title;
  final bool isActive;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isActive ? LocalStrings.active.tr : LocalStrings.notActive.tr,
                  style: regularSmall.copyWith(
                      color: accentColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.space15),
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
          child: child,
        ),
      ),
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space8),
        child: Divider(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.7),
          height: 1,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
  });
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ColorResources.blueGreyColor),
        const SizedBox(width: Dimensions.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: regularSmall.copyWith(
                      color: ColorResources.blueGreyColor)),
              const SizedBox(height: 2),
              Text(value,
                  style: semiBoldDefault.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        backgroundColor: color.withValues(alpha: 0.06),
      ),
    );
  }
}

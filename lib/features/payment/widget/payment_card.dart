import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/payment/model/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.index,
    required this.paymentModel,
  });
  final int index;
  final PaymentsModel paymentModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payment = paymentModel.data![index];
    final isActive = payment.active != '0';
    final accentColor =
        isActive ? ColorResources.greenColor : ColorResources.blueColor;

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.paymentDetailsScreen,
          arguments: payment.paymentId!),
      child: ClipRRect(
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
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${LocalStrings.payment.tr} #${payment.paymentId ?? payment.id}',
                          style: semiBoldDefault.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isActive
                              ? LocalStrings.active.tr
                              : LocalStrings.notActive.tr,
                          style: regularSmall.copyWith(
                              color: accentColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.receipt_outlined,
                            size: 13, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          '${LocalStrings.invoice.tr} #${payment.invoiceId ?? ''}',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ]),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 13, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          payment.date ?? '',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space8),
                  Row(
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 13, color: ColorResources.blueGreyColor),
                      const SizedBox(width: 4),
                      Text(
                        payment.name ?? '',
                        style: regularSmall.copyWith(
                            color: ColorResources.blueGreyColor),
                      ),
                      const Spacer(),
                      Text(
                        payment.amount ?? '',
                        style: semiBoldDefault.copyWith(color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

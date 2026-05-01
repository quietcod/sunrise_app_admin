import 'dart:ui';

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateCard extends StatelessWidget {
  const EstimateCard({
    super.key,
    required this.index,
    required this.estimateModel,
  });
  final int index;
  final EstimatesModel estimateModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estimate = estimateModel.data![index];
    final statusColor =
        ColorResources.estimateStatusColor(estimate.status ?? '');
    final number = estimate.formattedNumber ??
        '${estimate.prefix ?? ''}${estimate.number ?? ''}';
    final total = '${estimate.currencySymbol ?? ''}${estimate.total ?? ''}';
    final statusLabel = Converter.estimateStatusString(estimate.status ?? '1');

    return GestureDetector(
      onTap: () {
        if (estimate.id == null) return;
        Get.toNamed(RouteHelper.estimateDetailsScreen, arguments: estimate.id);
      },
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
                      .withValues(alpha: isDark ? 0.25 : 0.07),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                ),
              ],
            ),
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      number,
                      style: semiBoldDefault.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    Text(
                      total,
                      style: semiBoldDefault.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space10),
                Divider(
                  color: (isDark
                          ? const Color(0xFF2A3347)
                          : const Color(0xFFD0DAE8))
                      .withValues(alpha: 0.7),
                  height: 1,
                ),
                const SizedBox(height: Dimensions.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: regularSmall.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 14, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          estimate.expiryDate ?? '',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

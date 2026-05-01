import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersCard extends StatelessWidget {
  const CustomersCard({
    super.key,
    required this.customer,
    required this.isDark,
  });

  final Customer customer;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isActive = customer.active == '1';
    final accentColor =
        isActive ? ColorResources.greenColor : ColorResources.redColor;

    final company = customer.company ?? '?';
    final initial = company.isNotEmpty ? company[0].toUpperCase() : '?';

    bool hasValue(String? v) => v != null && v.isNotEmpty && v != '0';

    return GestureDetector(
      onTap: () {
        if (customer.userId != null) {
          Get.toNamed(RouteHelper.customerDetailsScreen,
              arguments: customer.userId!);
        }
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
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15, vertical: Dimensions.space12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: semiBoldLarge.copyWith(
                        color: accentColor, fontSize: 20),
                  ),
                ),
                const SizedBox(width: Dimensions.space12),
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: semiBoldDefault.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (hasValue(customer.phoneNumber)) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 12,
                                color: ColorResources.blueColor
                                    .withValues(alpha: 0.8)),
                            const SizedBox(width: 4),
                            Text(
                              customer.phoneNumber!,
                              style: regularSmall.copyWith(
                                  color: ColorResources.blueColor
                                      .withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ],
                      if (hasValue(customer.city) ||
                          hasValue(customer.country)) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [customer.city, customer.country]
                                    .where(hasValue)
                                    .join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: regularSmall.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.space8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    isActive
                        ? LocalStrings.active.tr
                        : LocalStrings.notActive.tr,
                    style: regularSmall.copyWith(
                        color: accentColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

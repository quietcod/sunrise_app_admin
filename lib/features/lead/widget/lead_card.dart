import 'dart:ui';

import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.index,
    required this.leadModel,
    this.onTapOverride,
    this.onLongPress,
    this.isSelected = false,
  });
  final int index;
  final LeadsModel leadModel;
  final VoidCallback? onTapOverride;
  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lead = leadModel.data![index];
    final statusColor = Converter.hexStringToColor(lead.color ?? '');
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTapOverride ??
          () => Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id!),
      onLongPress: onLongPress,
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
                color: isSelected
                    ? primary
                    : (isDark
                            ? const Color(0xFF2A3347)
                            : const Color(0xFFD8E2F0))
                        .withValues(alpha: 0.7),
                width: isSelected ? 2 : 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.person_outline_rounded,
                        color: isSelected ? Colors.white : statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: semiBoldDefault.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if ((lead.title ?? '').isNotEmpty ||
                              (lead.company ?? '').isNotEmpty)
                            Text(
                              [lead.title, lead.company]
                                  .where((v) => v != null && v.isNotEmpty)
                                  .join(' – '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: regularSmall.copyWith(
                                  color: ColorResources.blueGreyColor),
                            ),
                        ],
                      ),
                    ),
                    if ((lead.leadValue ?? '').isNotEmpty)
                      Text(
                        lead.leadValue!,
                        style: semiBoldDefault.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
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
                          lead.statusName ?? '',
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
                          DateConverter.formatValidityDate(
                              lead.dateAdded ?? ''),
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

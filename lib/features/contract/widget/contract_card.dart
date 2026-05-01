import 'dart:ui';

import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/contract/model/contract_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContractCard extends StatelessWidget {
  const ContractCard({
    super.key,
    required this.index,
    required this.contractModel,
  });
  final int index;
  final ContractsModel contractModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contract = contractModel.data![index];
    final signed = contract.signed ?? '0';
    final statusColor = ColorResources.contractStatusColor(signed);

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.contractDetailsScreen,
          arguments: contract.id),
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
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        contract.subject ?? '',
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
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        signed == '0'
                            ? LocalStrings.notSigned.tr
                            : LocalStrings.signed.tr,
                        style: regularSmall.copyWith(
                            color: statusColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if ((contract.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: Dimensions.space5),
                  Text(
                    contract.description ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: regularSmall.copyWith(
                        color: ColorResources.blueGreyColor),
                  ),
                ],
                const SizedBox(height: Dimensions.space10),
                Divider(
                  color: (isDark
                          ? const Color(0xFF2A3347)
                          : const Color(0xFFD0DAE8))
                      .withValues(alpha: 0.7),
                  height: 1,
                ),
                const SizedBox(height: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.account_box_rounded,
                          size: 13, color: ColorResources.blueGreyColor),
                      const SizedBox(width: 4),
                      Text(
                        contract.company ?? '',
                        style: regularSmall.copyWith(
                            color: ColorResources.blueGreyColor),
                      ),
                    ]),
                    Row(children: [
                      Icon(Icons.attach_money,
                          size: 14, color: ColorResources.blueGreyColor),
                      Text(
                        contract.contractValue ?? '',
                        style: semiBoldDefault.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: Dimensions.space5),
                Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 13, color: ColorResources.blueGreyColor),
                    const SizedBox(width: 4),
                    Text(
                      DateConverter.formatValidityDate(
                          contract.dateAdded ?? ''),
                      style: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor),
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

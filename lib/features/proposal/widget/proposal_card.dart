import 'dart:ui';

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.index,
    required this.proposalModel,
  });
  final int index;
  final ProposalsModel proposalModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proposal = proposalModel.data![index];
    final statusColor =
        ColorResources.proposalStatusColor(proposal.status ?? '');
    final statusLabel = Converter.proposalStatusString(proposal.status ?? '');

    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.proposalDetailsScreen, arguments: proposal.id!);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        proposal.subject ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: semiBoldDefault.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${proposal.total ?? ''} ${proposal.currencyName ?? ''}',
                          style: semiBoldDefault.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            statusLabel,
                            style: regularSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
                        Icon(Icons.account_box_rounded,
                            size: 14, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          proposal.proposalTo ?? '',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 14, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          proposal.date ?? '',
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

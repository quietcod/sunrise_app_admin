import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/item/model/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.index,
    required this.itemModel,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onCardTap,
    this.onDelete,
    this.onToggleSelect,
  });

  final int index;
  final ItemsModel itemModel;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onCardTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = itemModel.data![index];

    void handleTap() {
      if (isSelectionMode) {
        onToggleSelect?.call();
      } else {
        if (onCardTap != null) {
          onCardTap!();
        } else {
          Get.toNamed(RouteHelper.itemDetailsScreen, arguments: item.itemId!);
        }
      }
    }

    return GestureDetector(
      onTap: handleTap,
      onLongPress: isSelectionMode ? null : onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? (isDark
                        ? [const Color(0xFF1A2E4A), const Color(0xFF1E3560)]
                        : [
                            const Color(0xFFD6E8FF).withValues(alpha: 0.75),
                            const Color(0xFFBDD6FF).withValues(alpha: 0.85),
                          ])
                    : (isDark
                        ? [const Color(0xFF343434), const Color(0xFF343434)]
                        : [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                            const Color(0xFFEFF3F8).withValues(alpha: 0.65),
                          ]),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ColorResources.blueColor.withValues(alpha: 0.55)
                    : (isDark
                            ? const Color(0xFF2A3347)
                            : const Color(0xFFD8E2F0))
                        .withValues(alpha: 0.7),
                width: isSelected ? 1.5 : 1.0,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox in selection mode
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(
                          right: Dimensions.space10, top: 2),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onToggleSelect?.call(),
                          activeColor: ColorResources.blueColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.description ?? item.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: semiBoldDefault.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.longDescription ?? item.subText ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: lightSmall.copyWith(
                                        color: ColorResources.blueGreyColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: Dimensions.space8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.rate}',
                                  style: semiBoldDefault.copyWith(
                                      color: ColorResources.blueColor),
                                ),
                                Text(
                                  item.unit ?? '',
                                  style: lightSmall.copyWith(
                                      color: ColorResources.blueGreyColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.space8),
                        Divider(
                          color: (isDark
                                  ? const Color(0xFF2A3347)
                                  : const Color(0xFFD0DAE8))
                              .withValues(alpha: 0.7),
                          height: 1,
                        ),
                        const SizedBox(height: Dimensions.space8),
                        Row(
                          children: [
                            Icon(Icons.layers_rounded,
                                size: 13, color: ColorResources.blueGreyColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.groupName ?? '',
                                style: regularSmall.copyWith(
                                    color: ColorResources.blueGreyColor),
                              ),
                            ),
                            // Delete button (normal mode only)
                            if (!isSelectionMode && onDelete != null)
                              GestureDetector(
                                onTap: onDelete,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 13,
                                          color: Colors.red
                                              .withValues(alpha: 0.75)),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Delete',
                                        style: regularSmall.copyWith(
                                            color: Colors.red
                                                .withValues(alpha: 0.8),
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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

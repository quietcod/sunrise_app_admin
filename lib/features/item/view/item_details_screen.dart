import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/item/controller/item_controller.dart';
import 'package:flutex_admin/features/item/repo/item_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ItemRepo(apiClient: Get.find()));
    final controller = Get.put(ItemController(itemRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadItemDetails(widget.id);
    });
  }

  void _showEditItemSheet(
      BuildContext context, ItemController controller, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF343434), const Color(0xFF343434)]
                        : [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.88),
                            const Color(0xFFEFF3F8).withValues(alpha: 0.95),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: (isDark
                              ? const Color(0xFF2A3347)
                              : const Color(0xFFD8E2F0))
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(Dimensions.space20,
                    Dimensions.space20, Dimensions.space20, Dimensions.space25),
                child: GetBuilder<ItemController>(
                  builder: (c) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocalStrings.updateItem.tr,
                              style: boldExtraLarge.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space15),
                      _SheetTextField(
                        isDark: isDark,
                        controller: c.editNameController,
                        label: LocalStrings.itemName.tr,
                        hint: LocalStrings.itemName.tr,
                      ),
                      const SizedBox(height: Dimensions.space12),
                      _SheetTextField(
                        isDark: isDark,
                        controller: c.editLongDescController,
                        label: LocalStrings.longDescription.tr,
                        hint: LocalStrings.longDescription.tr,
                        maxLines: 3,
                      ),
                      const SizedBox(height: Dimensions.space12),
                      Row(
                        children: [
                          Expanded(
                            child: _SheetTextField(
                              isDark: isDark,
                              controller: c.editRateController,
                              label: LocalStrings.rate.tr,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: Dimensions.space12),
                          Expanded(
                            child: _SheetTextField(
                              isDark: isDark,
                              controller: c.editUnitController,
                              label: LocalStrings.unit.tr,
                              hint: LocalStrings.unit.tr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.isSubmitLoading
                              ? null
                              : () => c.updateItem(widget.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: c.isSubmitLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(LocalStrings.updateItem.tr,
                                  style: regularDefault.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.itemDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.itemDetailsModel.data!;

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
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _DetailHeader(
                      isDark: isDark,
                      title: LocalStrings.itemDetails.tr,
                      onEdit: () {
                        controller.populateForEdit();
                        _showEditItemSheet(context, controller, isDark);
                      },
                      onDelete: () {
                        const WarningAlertDialog().warningAlertDialog(
                          context,
                          () => controller.deleteItem(widget.id),
                          title: LocalStrings.deleteItem.tr,
                          subTitle: LocalStrings.deleteItemWarningMsg.tr,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async =>
                          controller.loadItemDetails(widget.id),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.space15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header info card
                            _GlassCard(
                              isDark: isDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          d.description ?? '',
                                          style: boldExtraLarge.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((d.longDescription ?? '').isNotEmpty) ...[
                                    const SizedBox(height: Dimensions.space10),
                                    _HDivider(isDark: isDark),
                                    const SizedBox(height: Dimensions.space8),
                                    Text(
                                      '${LocalStrings.description.tr}:',
                                      style: regularSmall.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                    const SizedBox(height: Dimensions.space5),
                                    Text(
                                      d.longDescription!,
                                      style: regularDefault.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.space12),
                            // Rate hero card
                            _GlassCard(
                              isDark: isDark,
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      LocalStrings.rate.tr,
                                      style: regularDefault.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                    const SizedBox(height: Dimensions.space8),
                                    Text(
                                      '${d.rate ?? '-'} / ${d.unit ?? ''}',
                                      style: boldExtraLarge.copyWith(
                                          color: ColorResources.blueColor,
                                          fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.space12),
                            // Tax info card
                            if ((d.taxName ?? '').isNotEmpty ||
                                (d.taxNameTwo ?? '').isNotEmpty)
                              _GlassCard(
                                isDark: isDark,
                                child: Column(
                                  children: [
                                    if ((d.taxName ?? '').isNotEmpty)
                                      _InfoRow(
                                        isDark: isDark,
                                        label: LocalStrings.tax.tr,
                                        value:
                                            '${d.taxName} (${d.taxRate ?? '0'}%)',
                                        icon: Icons.percent_outlined,
                                      ),
                                    if ((d.taxName ?? '').isNotEmpty &&
                                        (d.taxNameTwo ?? '').isNotEmpty)
                                      _HDivider(isDark: isDark),
                                    if ((d.taxNameTwo ?? '').isNotEmpty)
                                      _InfoRow(
                                        isDark: isDark,
                                        label: '${LocalStrings.tax.tr} 2',
                                        value:
                                            '${d.taxNameTwo} (${d.taxRateTwo ?? '0'}%)',
                                        icon: Icons.percent_outlined,
                                      ),
                                  ],
                                ),
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
  const _DetailHeader(
      {required this.isDark, required this.title, this.onEdit, this.onDelete});
  final bool isDark;
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
              if (onEdit != null)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: ColorResources.blueColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined,
                        color: ColorResources.blueColor, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
              if (onDelete != null)
                Container(
                  decoration: BoxDecoration(
                    color: ColorResources.redColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: ColorResources.redColor, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
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
  Widget build(BuildContext context) => Divider(
        color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
            .withValues(alpha: 0.7),
        height: 1,
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

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.isDark,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });
  final bool isDark;
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: regularSmall.copyWith(color: ColorResources.blueGreyColor)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color:
                    (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.5 : 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isDark
                          ? const Color(0xFF2A3347)
                          : const Color(0xFFD8E2F0))
                      .withValues(alpha: 0.7),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle:
                      const TextStyle(color: ColorResources.blueGreyColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

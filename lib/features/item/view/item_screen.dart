import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/item/controller/item_controller.dart';
import 'package:flutex_admin/features/item/repo/item_repo.dart';
import 'package:flutex_admin/features/item/widget/item_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ItemRepo(apiClient: Get.find()));
    final controller = Get.put(ItemController(itemRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddItemSheet(
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
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocalStrings.createItem.tr,
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
                      // Name field
                      _SheetTextField(
                        isDark: isDark,
                        controller: c.nameController,
                        label: LocalStrings.itemName.tr,
                        hint: LocalStrings.itemName.tr,
                      ),
                      const SizedBox(height: Dimensions.space12),
                      // Long description
                      _SheetTextField(
                        isDark: isDark,
                        controller: c.longDescController,
                        label: LocalStrings.longDescription.tr,
                        hint: LocalStrings.longDescription.tr,
                        maxLines: 3,
                      ),
                      const SizedBox(height: Dimensions.space12),
                      // Rate & Unit row
                      Row(
                        children: [
                          Expanded(
                            child: _SheetTextField(
                              isDark: isDark,
                              controller: c.rateController,
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
                              controller: c.unitController,
                              label: LocalStrings.unit.tr,
                              hint: LocalStrings.unit.tr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space20),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.isSubmitLoading ? null : c.submitItem,
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
                              : Text(LocalStrings.createItem.tr,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

    return GetBuilder<ItemController>(builder: (controller) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        floatingActionButton: controller.isSelectionMode
            ? FloatingActionButton.extended(
                onPressed: controller.isSubmitLoading
                    ? null
                    : () {
                        const WarningAlertDialog().warningAlertDialog(
                          context,
                          () => controller.deleteSelectedItems(),
                          title: 'Delete Selected',
                          subTitle:
                              'Are you sure you want to delete ${controller.selectedIds.length} selected item${controller.selectedIds.length == 1 ? '' : 's'}?',
                        );
                      },
                backgroundColor: Colors.red,
                icon: controller.isSubmitLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.delete_rounded, color: Colors.white),
                label: Text(
                  'Delete (${controller.selectedIds.length})',
                  style: regularDefault.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              )
            : FloatingActionButton(
                onPressed: () => _showAddItemSheet(context, controller, isDark),
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
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
                bottom: 180,
                right: -60,
                child: _BlurOrb(
                  size: 160,
                  color: (isDark
                          ? const Color(0xFF23324A)
                          : const Color(0xFFD0E7FF))
                      .withValues(alpha: isDark ? 0.2 : 0.5),
                ),
              ),
              controller.isLoading
                  ? const CustomLoader()
                  : RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async =>
                          controller.initialData(shouldLoad: false),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  Dimensions.space15,
                                  topPad,
                                  Dimensions.space15,
                                  Dimensions.space10),
                              child: _GlassHeader(
                                isDark: isDark,
                                title: controller.isSelectionMode
                                    ? '${controller.selectedIds.length} selected'
                                    : LocalStrings.items.tr,
                                isSearch: controller.isSearch,
                                isSelectionMode: controller.isSelectionMode,
                                onSearchToggle: () =>
                                    controller.changeSearchIcon(),
                                onExitSelection: () =>
                                    controller.exitSelectionMode(),
                                onEnterSelection:
                                    controller.itemsModel.data?.isNotEmpty ==
                                            true
                                        ? () => controller.enterSelectionMode()
                                        : null,
                                onSelectAll: () {
                                  final all = controller.itemsModel.data ?? [];
                                  final allSel = all.every((e) => controller
                                      .selectedIds
                                      .contains(e.itemId!));
                                  if (allSel) {
                                    controller.deselectAll();
                                  } else {
                                    controller.selectAll();
                                  }
                                },
                                allSelected: (controller.itemsModel.data ?? [])
                                        .isNotEmpty &&
                                    (controller.itemsModel.data ?? []).every(
                                        (e) => controller.selectedIds
                                            .contains(e.itemId!)),
                              ),
                            ),
                          ),
                          if (controller.isSearch)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    Dimensions.space15,
                                    0,
                                    Dimensions.space15,
                                    Dimensions.space10),
                                child: _SearchBar(
                                  isDark: isDark,
                                  controller: controller.searchController,
                                  onSearch: () => controller.searchItem(),
                                ),
                              ),
                            ),
                          controller.itemsModel.data?.isNotEmpty ?? false
                              ? SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.space15),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: Dimensions.space10),
                                        child: ItemCard(
                                          index: index,
                                          itemModel: controller.itemsModel,
                                          isSelectionMode:
                                              controller.isSelectionMode,
                                          isSelected: controller.selectedIds
                                              .contains(controller.itemsModel
                                                  .data![index].itemId!),
                                          onLongPress: () => controller
                                              .enterSelectionMode(controller
                                                  .itemsModel
                                                  .data![index]
                                                  .itemId!),
                                          onToggleSelect: () => controller
                                              .toggleSelection(controller
                                                  .itemsModel
                                                  .data![index]
                                                  .itemId!),
                                          onDelete: () {
                                            const WarningAlertDialog()
                                                .warningAlertDialog(
                                              context,
                                              () => controller.deleteItemInList(
                                                  controller.itemsModel
                                                      .data![index].itemId!),
                                              title: LocalStrings.deleteItem.tr,
                                              subTitle: LocalStrings
                                                  .deleteItemWarningMsg.tr,
                                            );
                                          },
                                        ),
                                      ),
                                      childCount:
                                          controller.itemsModel.data!.length,
                                    ),
                                  ),
                                )
                              : const SliverFillRemaining(
                                  child: Center(child: NoDataWidget())),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: Dimensions.space25)),
                        ],
                      ),
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

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({
    required this.isDark,
    required this.title,
    required this.isSearch,
    required this.onSearchToggle,
    this.isSelectionMode = false,
    this.onExitSelection,
    this.onEnterSelection,
    this.onSelectAll,
    this.allSelected = false,
  });
  final bool isDark;
  final String title;
  final bool isSearch;
  final VoidCallback onSearchToggle;
  final bool isSelectionMode;
  final VoidCallback? onExitSelection;
  final VoidCallback? onEnterSelection;
  final VoidCallback? onSelectAll;
  final bool allSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                onPressed: isSelectionMode ? onExitSelection : () => Get.back(),
                icon: Icon(isSelectionMode
                    ? Icons.close
                    : Icons.arrow_back_ios_new_rounded),
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
              if (!isSelectionMode) ...[
                IconButton(
                  onPressed: onEnterSelection,
                  icon: const Icon(Icons.checklist_rounded,
                      color: ColorResources.blueGreyColor),
                  tooltip: 'Select items',
                ),
                IconButton(
                  onPressed: onSearchToggle,
                  icon: Icon(isSearch ? Icons.close : Icons.search,
                      color: ColorResources.blueGreyColor),
                ),
              ],
              if (isSelectionMode)
                TextButton(
                  onPressed: onSelectAll,
                  child: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    style: regularSmall.copyWith(
                        color: ColorResources.blueColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.isDark,
    required this.controller,
    required this.onSearch,
  });
  final bool isDark;
  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF2A3347) : const Color(0xFFD8E2F0))
                      .withValues(alpha: 0.7),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.search, color: ColorResources.blueGreyColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSearch(),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: ColorResources.blueGreyColor),
                  ),
                ),
              ),
              TextButton(
                onPressed: onSearch,
                child: Text('Search',
                    style: regularSmall.copyWith(
                        color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
      ),
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

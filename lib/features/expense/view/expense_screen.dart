import 'dart:ui';

import 'package:flutex_admin/common/components/custom_fab.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/common/components/search_field.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/expense/controller/expense_controller.dart';
import 'package:flutex_admin/features/expense/model/expense_model.dart';
import 'package:flutex_admin/features/expense/repo/expense_repo.dart';
import 'package:flutex_admin/features/expense/widget/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String? selectedBillable;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ExpenseRepo(apiClient: Get.find()));
    final controller = Get.put(ExpenseController(expenseRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    handleScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialData();
    });
  }

  bool showFab = true;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  void handleScroll() {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showFab) setState(() => showFab = false);
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showFab) setState(() => showFab = true);
      }
    });
  }

  List<Expense> _filteredExpenses(ExpenseController controller) {
    final list =
        List<Expense>.from(controller.expensesModel.data ?? <Expense>[]);

    final filtered = list.where((e) {
      if (selectedBillable == null) return true;
      final b = (e.billable ?? '0') == '1' ? 'Billable' : 'Not Billable';
      return b == selectedBillable;
    }).toList();

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse((a.date ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse((b.date ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  Future<void> _openFilterSheet(ExpenseController controller) async {
    String? tempBillable = selectedBillable;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          final bottomSafeSpace = MediaQuery.of(ctx).padding.bottom;
          final keyboardInset = MediaQuery.of(ctx).viewInsets.bottom;

          Widget chip(
              {required String label,
              required bool selected,
              required VoidCallback onTap}) {
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onTap(),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.space15,
              Dimensions.space15,
              Dimensions.space15,
              (keyboardInset > 0 ? keyboardInset : bottomSafeSpace) +
                  Dimensions.space15,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(LocalStrings.filter.tr, style: semiBoldExtraLarge),
                  const SizedBox(height: Dimensions.space12),
                  Text('Billable', style: semiBoldDefault),
                  const SizedBox(height: Dimensions.space8),
                  Wrap(
                    spacing: Dimensions.space8,
                    runSpacing: Dimensions.space8,
                    children: [
                      chip(
                          label: 'All',
                          selected: tempBillable == null,
                          onTap: () =>
                              setModalState(() => tempBillable = null)),
                      chip(
                          label: 'Billable',
                          selected: tempBillable == 'Billable',
                          onTap: () =>
                              setModalState(() => tempBillable = 'Billable')),
                      chip(
                          label: 'Not Billable',
                          selected: tempBillable == 'Not Billable',
                          onTap: () => setModalState(
                              () => tempBillable = 'Not Billable')),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => selectedBillable = null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => selectedBillable = tempBillable);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topSafePadding =
          MediaQuery.of(context).padding.top + Dimensions.space5;
      final filteredList = _filteredExpenses(controller);
      final isFilterActive = selectedBillable != null;

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        floatingActionButton: AnimatedSlide(
          offset: showFab ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: showFab ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: CustomFAB(
              isShowIcon: true,
              isShowText: false,
              press: () => Get.toNamed(RouteHelper.addExpenseScreen),
            ),
          ),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async {
                  await controller.initialData(shouldLoad: false);
                },
                child: Container(
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
                        top: -80,
                        left: -70,
                        child: _BlurOrb(
                          size: 180,
                          color: (isDark
                                  ? const Color(0xFF343434)
                                  : const Color(0xFFFFFFFF))
                              .withValues(alpha: isDark ? 0.25 : 0.62),
                        ),
                      ),
                      Positioned(
                        bottom: 120,
                        right: -60,
                        child: _BlurOrb(
                          size: 170,
                          color: (isDark
                                  ? const Color(0xFF23324A)
                                  : const Color(0xFFD0E7FF))
                              .withValues(alpha: isDark ? 0.2 : 0.5),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          Dimensions.space15,
                          topSafePadding,
                          Dimensions.space15,
                          Dimensions.space25,
                        ),
                        child: Column(
                          children: [
                            _GlassHeader(
                              title: LocalStrings.expenses.tr,
                              isDark: isDark,
                              onBack: () => Get.back(),
                              onSearch: () => controller.changeSearchIcon(),
                              isSearching: controller.isSearch,
                            ),
                            if (controller.isSearch)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.space10),
                                child: SearchField(
                                  title: LocalStrings.expenses.tr,
                                  searchController: controller.searchController,
                                  onTap: () => controller.searchExpense(),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.space12,
                                  bottom: Dimensions.space10),
                              child: Row(
                                children: [
                                  Text(
                                    LocalStrings.expenses.tr,
                                    style: semiBoldExtraLarge.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  _FilterChipBtn(
                                    isDark: isDark,
                                    isActive: isFilterActive,
                                    onTap: () => _openFilterSheet(controller),
                                  ),
                                ],
                              ),
                            ),
                            filteredList.isNotEmpty
                                ? ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ExpenseCard(
                                        expense: filteredList[index],
                                        isDark: isDark,
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                            height: Dimensions.space10),
                                    itemCount: filteredList.length,
                                  )
                                : const NoDataWidget(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

// ── Glass header ──────────────────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({
    required this.title,
    required this.isDark,
    required this.onBack,
    required this.onSearch,
    required this.isSearching,
  });

  final String title;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  title,
                  style: boldExtraLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              IconButton(
                onPressed: onSearch,
                icon: Icon(isSearching ? Icons.clear : Icons.search_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter chip button ────────────────────────────────────────────────────────

class _FilterChipBtn extends StatelessWidget {
  const _FilterChipBtn({
    required this.isDark,
    required this.isActive,
    required this.onTap,
  });

  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fgColor = isActive
        ? Colors.white
        : (isDark ? const Color(0xFFE3E9F2) : ColorResources.primaryColor);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor
              : (isDark ? const Color(0xFF18202E) : const Color(0xFFFFFFFF))
                  .withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : (isDark ? const Color(0xFF3B4658) : const Color(0xFFDAE2EE)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: fgColor),
            const SizedBox(width: 6),
            Text(
              LocalStrings.filter.tr,
              style: regularSmall.copyWith(
                  color: fgColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blur orb ──────────────────────────────────────────────────────────────────

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

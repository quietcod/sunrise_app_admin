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
import 'package:flutex_admin/features/proposal/controller/proposal_controller.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutex_admin/features/proposal/repo/proposal_repo.dart';
import 'package:flutex_admin/features/proposal/widget/proposal_card.dart';
import 'package:flutex_admin/features/proposal/widget/proposal_kanban.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  String? selectedStatus;
  bool _kanbanMode = false;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProposalRepo(apiClient: Get.find()));
    final controller = Get.put(ProposalController(proposalRepo: Get.find()));
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

  List<Proposal> _filteredProposals(ProposalController controller) {
    final list =
        List<Proposal>.from(controller.proposalsModel.data ?? <Proposal>[]);
    if (selectedStatus == null || selectedStatus!.isEmpty) return list;
    return list.where((p) {
      final label =
          controller.proposalStatus[p.status ?? ''] ?? (p.status ?? '');
      return label.toLowerCase() == selectedStatus!.toLowerCase();
    }).toList();
  }

  Future<void> _openFilterSheet(ProposalController controller) async {
    final overviewItems = controller.proposalsModel.overview ?? [];
    final statusOptions = overviewItems
        .map((e) => (e.status ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String? tempStatus = selectedStatus;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        final bottomSafeSpace = MediaQuery.of(ctx).padding.bottom;
        final keyboardInset = MediaQuery.of(ctx).viewInsets.bottom;

        Widget statusChip(
                {required String label,
                required bool selected,
                required VoidCallback onTap}) =>
            ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => onTap());

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
                Text('Status', style: semiBoldDefault),
                const SizedBox(height: Dimensions.space8),
                Wrap(
                  spacing: Dimensions.space8,
                  runSpacing: Dimensions.space8,
                  children: [
                    statusChip(
                      label: 'All',
                      selected: tempStatus == null,
                      onTap: () => setModalState(() => tempStatus = null),
                    ),
                    ...statusOptions.map((s) => statusChip(
                          label: s,
                          selected: tempStatus == s,
                          onTap: () => setModalState(() => tempStatus = s),
                        )),
                  ],
                ),
                const SizedBox(height: Dimensions.space20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => selectedStatus = null);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => selectedStatus = tempStatus);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProposalController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topSafePadding =
          MediaQuery.of(context).padding.top + Dimensions.space5;
      final filteredList = _filteredProposals(controller);
      final activeFilterCount = selectedStatus != null ? 1 : 0;

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
              press: () => Get.toNamed(RouteHelper.addProposalScreen)
                  ?.then((_) => controller.loadProposals()),
            ),
          ),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async =>
                    controller.initialData(shouldLoad: false),
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
                              title: LocalStrings.proposals.tr,
                              isDark: isDark,
                              onBack: () => Get.back(),
                              onSearch: () => controller.changeSearchIcon(),
                              isSearching: controller.isSearch,
                            ),
                            if (controller.isSearch)
                              SearchField(
                                title: LocalStrings.proposalDetails.tr,
                                searchController: controller.searchController,
                                onTap: () => controller.searchProposal(),
                              ),
                            if (controller.proposalsModel.overview != null &&
                                controller.proposalsModel.overview!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.space10,
                                    bottom: Dimensions.space8),
                                child: SizedBox(
                                  height: 78,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final item = controller
                                          .proposalsModel.overview![index];
                                      final label = item.status ?? '';
                                      final isSelected =
                                          selectedStatus != null &&
                                              selectedStatus!.toLowerCase() ==
                                                  label.toLowerCase();
                                      return _SummaryChip(
                                        isDark: isDark,
                                        title: label.tr,
                                        value: item.total ?? '0',
                                        isSelected: isSelected,
                                        onTap: () => setState(() {
                                          selectedStatus =
                                              isSelected ? null : label;
                                        }),
                                      );
                                    },
                                    separatorBuilder: (_, __) => const SizedBox(
                                        width: Dimensions.space8),
                                    itemCount: controller
                                        .proposalsModel.overview!.length,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.space8,
                                  bottom: Dimensions.space10),
                              child: Row(
                                children: [
                                  Text(
                                    LocalStrings.proposals.tr,
                                    style: semiBoldExtraLarge.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: _kanbanMode
                                        ? 'List view'
                                        : 'Kanban view',
                                    icon: Icon(
                                      _kanbanMode
                                          ? Icons.view_list_rounded
                                          : Icons.view_column_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () => setState(
                                        () => _kanbanMode = !_kanbanMode),
                                  ),
                                  _FilterChip(
                                    isDark: isDark,
                                    activeFilterCount: activeFilterCount,
                                    onTap: () => _openFilterSheet(controller),
                                  ),
                                ],
                              ),
                            ),
                            if (_kanbanMode)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: filteredList.isNotEmpty
                                    ? ProposalKanban(proposals: filteredList)
                                    : const NoDataWidget(),
                              )
                            else
                              filteredList.isNotEmpty
                                  ? ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) =>
                                          ProposalCard(
                                            index: index,
                                            proposalModel: ProposalsModel(
                                                data: filteredList),
                                          ),
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(
                                              height: Dimensions.space10),
                                      itemCount: filteredList.length)
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

// ── Private widgets ───────────────────────────────────────────────────────────

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      );
}

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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.isDark,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });
  final bool isDark;
  final String title;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 96,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.42 : 0.34),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (isDark
                            ? const Color(0xFF414A5B)
                            : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.46 : 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: semiBoldExtraLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : ColorResources.secondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: regularSmall.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : Theme.of(context).textTheme.bodyLarge?.color,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.isDark,
    required this.activeFilterCount,
    required this.onTap,
  });
  final bool isDark;
  final int activeFilterCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = activeFilterCount > 0;
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
                : (isDark ? const Color(0xFF3B4658) : const Color(0xFFDAE2EE))
                    .withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.sort_outlined, size: Dimensions.space20, color: fgColor),
            const SizedBox(width: Dimensions.space5),
            Text(LocalStrings.filter.tr,
                style: regularDefault.copyWith(color: fgColor)),
            if (activeFilterCount > 0) ...[
              const SizedBox(width: Dimensions.space5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(activeFilterCount.toString(),
                    style: regularOverSmall.copyWith(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

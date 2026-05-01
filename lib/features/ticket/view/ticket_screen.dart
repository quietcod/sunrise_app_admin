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
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/features/ticket/model/ticket_model.dart';
import 'package:flutex_admin/features/ticket/repo/ticket_repo.dart';
import 'package:flutex_admin/features/ticket/widget/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String? selectedStatus;
  String? selectedPriority;
  bool showAllStatuses = false;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TicketRepo(apiClient: Get.find()));
    final controller = Get.put(TicketController(ticketRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    handleScroll();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  bool showFab = true;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  void handleScroll() async {
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

  List<Ticket> _filteredTickets(TicketController controller) {
    final list = List<Ticket>.from(controller.ticketsModel.data ?? <Ticket>[]);

    final filtered = list.where((ticket) {
      final ticketStatus = (ticket.statusName ?? '').trim().toLowerCase();
      final ticketStatusId = (ticket.status ?? '').trim();
      final statusOk = selectedStatus != null && selectedStatus!.isNotEmpty
          ? ticketStatus == selectedStatus!.toLowerCase()
          : (showAllStatuses ||
              ticketStatusId == '1' ||
              ticketStatusId == '2' ||
              ticketStatus == 'open' ||
              ticketStatus == 'in progress');
      final priorityOk = selectedPriority == null ||
          selectedPriority!.isEmpty ||
          (ticket.priorityName ?? '').toLowerCase() ==
              selectedPriority!.toLowerCase();

      return statusOk && priorityOk;
    }).toList();

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse((a.dateCreated ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse((b.dateCreated ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  void _showManageMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).padding.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Manage Priorities'),
              onTap: () {
                Navigator.pop(ctx);
                Get.toNamed(RouteHelper.ticketPrioritiesScreen);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle_outlined),
              title: const Text('Manage Statuses'),
              onTap: () {
                Navigator.pop(ctx);
                Get.toNamed(RouteHelper.ticketStatusesScreen);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Manage Services'),
              onTap: () {
                Navigator.pop(ctx);
                Get.toNamed(RouteHelper.ticketServicesScreen);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Spam Filters'),
              onTap: () {
                Navigator.pop(ctx);
                Get.toNamed(RouteHelper.ticketSpamFiltersScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(TicketController controller) async {
    final tickets = controller.ticketsModel.data ?? <Ticket>[];
    final statusOptions = tickets
        .map((e) => (e.statusName ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final priorityOptions = tickets
        .map((e) => (e.priorityName ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    String? tempStatus = selectedStatus;
    String? tempPriority = selectedPriority;
    bool tempShowAllStatuses = showAllStatuses;

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

          Widget chip({
            required String label,
            required bool selected,
            required VoidCallback onTap,
          }) {
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
                  Text('Status', style: semiBoldDefault),
                  const SizedBox(height: Dimensions.space8),
                  Wrap(
                    spacing: Dimensions.space8,
                    runSpacing: Dimensions.space8,
                    children: [
                      chip(
                        label: 'All',
                        selected: tempShowAllStatuses,
                        onTap: () => setModalState(() {
                          tempStatus = null;
                          tempShowAllStatuses = true;
                        }),
                      ),
                      ...statusOptions.map(
                        (s) => chip(
                          label: s,
                          selected: tempStatus == s,
                          onTap: () => setModalState(() {
                            tempStatus = s;
                            tempShowAllStatuses = false;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space15),
                  Text('Priority', style: semiBoldDefault),
                  const SizedBox(height: Dimensions.space8),
                  Wrap(
                    spacing: Dimensions.space8,
                    runSpacing: Dimensions.space8,
                    children: [
                      chip(
                        label: 'All',
                        selected: tempPriority == null,
                        onTap: () => setModalState(() => tempPriority = null),
                      ),
                      ...priorityOptions.map(
                        (p) => chip(
                          label: p,
                          selected: tempPriority == p,
                          onTap: () => setModalState(() => tempPriority = p),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedStatus = null;
                              selectedPriority = null;
                              showAllStatuses = false;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedStatus = tempStatus;
                              selectedPriority = tempPriority;
                              showAllStatuses = tempShowAllStatuses;
                            });
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
    return GetBuilder<TicketController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topSafePadding =
          MediaQuery.of(context).padding.top + Dimensions.space5;
      final filteredList = _filteredTickets(controller);
      final activeFilterCount =
          ((selectedStatus != null || showAllStatuses) ? 1 : 0) +
              (selectedPriority != null ? 1 : 0);

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
                press: () {
                  Get.toNamed(RouteHelper.addTicketScreen);
                }),
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
                              title: controller.isBulkMode
                                  ? '${controller.selectedTicketIds.length} selected'
                                  : LocalStrings.tickets.tr,
                              isDark: isDark,
                              onBack: controller.isBulkMode
                                  ? () {
                                      controller.clearSelection();
                                    }
                                  : () => Get.back(),
                              onSearch: controller.isBulkMode
                                  ? null
                                  : () => controller.changeSearchIcon(),
                              isSearching: controller.isSearch,
                              isBulkMode: controller.isBulkMode,
                              selectedCount:
                                  controller.selectedTicketIds.length,
                              onBulkDelete: controller.isBulkMode
                                  ? () => controller.bulkDeleteSelected()
                                  : null,
                              onSelectAll: controller.isBulkMode
                                  ? () => controller.selectAllTickets(
                                        filteredList
                                            .map((t) => t.id?.toString() ?? '')
                                            .where((id) => id.isNotEmpty)
                                            .toList(),
                                      )
                                  : null,
                              onMenu: controller.isBulkMode
                                  ? null
                                  : () => _showManageMenu(context),
                            ),
                            if (controller.isSearch)
                              SearchField(
                                title: LocalStrings.ticketDetails.tr,
                                searchController: controller.searchController,
                                onTap: () => controller.searchTicket(),
                              ),
                            if (controller.ticketsModel.overview != null)
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
                                          .ticketsModel.overview![index];
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
                                        onTap: () {
                                          setState(() {
                                            selectedStatus =
                                                isSelected ? null : label;
                                            showAllStatuses = false;
                                          });
                                        },
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                            width: Dimensions.space8),
                                    itemCount: controller
                                        .ticketsModel.overview!.length,
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
                                    LocalStrings.tickets.tr,
                                    style: semiBoldExtraLarge.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const Spacer(),
                                  _FilterChip(
                                    isDark: isDark,
                                    activeFilterCount: activeFilterCount,
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
                                      final ticketId =
                                          filteredList[index].id?.toString() ??
                                              '';
                                      final isSelected = controller
                                          .selectedTicketIds
                                          .contains(ticketId);
                                      return GestureDetector(
                                        onLongPress: () {
                                          controller.toggleBulkMode();
                                          if (controller.isBulkMode &&
                                              ticketId.isNotEmpty) {
                                            controller.toggleTicketSelection(
                                                ticketId);
                                          }
                                        },
                                        onTap: controller.isBulkMode
                                            ? () => controller
                                                .toggleTicketSelection(ticketId)
                                            : null,
                                        child: Stack(
                                          children: [
                                            AbsorbPointer(
                                              absorbing: controller.isBulkMode,
                                              child: TicketCard(
                                                index: index,
                                                ticketModel: TicketsModel(
                                                    data: filteredList),
                                              ),
                                            ),
                                            if (controller.isBulkMode)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.white
                                                            .withValues(
                                                                alpha: 0.8),
                                                    border: Border.all(
                                                        color: isSelected
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.grey,
                                                        width: 2),
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(Icons.check,
                                                          size: 14,
                                                          color: Colors.white)
                                                      : null,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
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

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({
    required this.title,
    required this.isDark,
    required this.onBack,
    this.onSearch,
    required this.isSearching,
    this.isBulkMode = false,
    this.selectedCount = 0,
    this.onBulkDelete,
    this.onSelectAll,
    this.onMenu,
  });

  final String title;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback? onSearch;
  final bool isSearching;
  final bool isBulkMode;
  final int selectedCount;
  final VoidCallback? onBulkDelete;
  final VoidCallback? onSelectAll;
  final VoidCallback? onMenu;

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
                icon: Icon(isBulkMode
                    ? Icons.close
                    : Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  title,
                  style: boldExtraLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (isBulkMode) ...[
                if (onSelectAll != null)
                  IconButton(
                    onPressed: onSelectAll,
                    icon: const Icon(Icons.select_all_rounded),
                    tooltip: 'Select all',
                  ),
                if (onBulkDelete != null)
                  IconButton(
                    onPressed: selectedCount > 0 ? onBulkDelete : null,
                    icon: const Icon(Icons.delete_outline),
                    color: selectedCount > 0 ? Colors.redAccent : null,
                    tooltip: 'Delete selected',
                  ),
              ] else ...[
                if (onSearch != null)
                  IconButton(
                    onPressed: onSearch,
                    icon:
                        Icon(isSearching ? Icons.clear : Icons.search_rounded),
                  ),
                if (onMenu != null)
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: 'Manage',
                  ),
              ],
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
            Icon(
              Icons.sort_outlined,
              size: Dimensions.space20,
              color: fgColor,
            ),
            const SizedBox(width: Dimensions.space5),
            Text(
              LocalStrings.filter.tr,
              style: regularDefault.copyWith(color: fgColor),
            ),
            if (activeFilterCount > 0) ...[
              const SizedBox(width: Dimensions.space5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activeFilterCount.toString(),
                  style: regularOverSmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
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
}

import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/project/widget/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showFab = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    _scrollController.addListener(() {
      final dir = _scrollController.position.userScrollDirection;
      if (dir == ScrollDirection.reverse && _showFab) {
        setState(() => _showFab = false);
      } else if (dir == ScrollDirection.forward && !_showFab) {
        setState(() => _showFab = true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

    return GetBuilder<ProjectController>(builder: (controller) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        floatingActionButton: AnimatedSlide(
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(RouteHelper.addProjectScreen),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
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
                                title: LocalStrings.projects.tr,
                                isSearch: controller.isSearch,
                                onSearchToggle: () =>
                                    controller.changeSearchIcon(),
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
                                  onSearch: () => controller.searchProject(),
                                ),
                              ),
                            ),
                          // Overview summary chips
                          if (controller.projectsModel.overview != null &&
                              controller.projectsModel.overview!.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    Dimensions.space15,
                                    0,
                                    Dimensions.space15,
                                    Dimensions.space10),
                                child: SizedBox(
                                  height: 78,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller
                                        .projectsModel.overview!.length,
                                    separatorBuilder: (_, __) => const SizedBox(
                                        width: Dimensions.space8),
                                    itemBuilder: (context, index) {
                                      final item = controller
                                          .projectsModel.overview![index];
                                      final label = item.status ?? '';
                                      final isSelected =
                                          controller.selectedStatus == label;
                                      return _SummaryChip(
                                        isDark: isDark,
                                        title: label.tr,
                                        value: item.total?.toString() ?? '0',
                                        isSelected: isSelected,
                                        onTap: () => controller.filterByStatus(
                                            isSelected ? null : label),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          controller.projectsModel.data?.isNotEmpty ?? false
                              ? SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.space15),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: Dimensions.space10),
                                        child: ProjectCard(
                                          index: index,
                                          projectModel:
                                              controller.projectsModel,
                                        ),
                                      ),
                                      childCount:
                                          controller.projectsModel.data!.length,
                                    ),
                                  ),
                                )
                              : controller.isAccessDenied
                                  ? const SliverFillRemaining(
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.lock_outline,
                                                  size: 48,
                                                  color: Colors.blueGrey),
                                              SizedBox(height: 12),
                                              Text(
                                                'You can only view projects assigned to you. Please contact your administrator to access project data through the app.',
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
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

// ── Private widgets ──────────────────────────────────────────────────────────

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
  });
  final bool isDark;
  final String title;
  final bool isSearch;
  final VoidCallback onSearchToggle;

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
              IconButton(
                onPressed: onSearchToggle,
                icon: Icon(isSearch ? Icons.close : Icons.search,
                    color: ColorResources.blueGreyColor),
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
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(16),
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
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    hintStyle: regularDefault.copyWith(
                        color: ColorResources.blueGreyColor),
                  ),
                  style: regularDefault.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
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

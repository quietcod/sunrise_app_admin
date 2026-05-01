import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/notification/controller/notification_controller.dart';
import 'package:flutex_admin/features/notification/repo/notification_repo.dart';
import 'package:flutex_admin/features/notification/widget/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.lazyPut(() => NotificationRepo(apiClient: Get.find()));
    Get.put(NotificationController(notificationRepo: Get.find()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark
                          ? const Color(0xFF23324A)
                          : const Color(0xFFD0E7FF))
                      .withValues(alpha: isDark ? 0.22 : 0.5),
                ),
              ),
            ),
            SafeArea(
              child: GetBuilder<NotificationController>(builder: (controller) {
                return Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              LocalStrings.notifications.tr,
                              style: boldLarge.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          if (controller.unreadCount > 0)
                            TextButton.icon(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.markAllAsRead,
                              icon:
                                  const Icon(Icons.done_all_rounded, size: 18),
                              label: Text(
                                LocalStrings.markAllRead.tr,
                                style: regularSmall.copyWith(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: ColorResources.secondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Tab bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFF343434)
                                      : const Color(0xFFFFFFFF))
                                  .withValues(alpha: .45),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark
                                        ? const Color(0xFF4A5C79)
                                        : const Color(0xFFFFFFFF))
                                    .withValues(alpha: .55),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: ColorResources.secondaryColor
                                    .withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelStyle:
                                  semiBoldDefault.copyWith(fontSize: 13),
                              unselectedLabelStyle:
                                  regularDefault.copyWith(fontSize: 13),
                              labelColor: ColorResources.secondaryColor,
                              unselectedLabelColor:
                                  ColorResources.contentTextColor,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(LocalStrings.allNotifications.tr),
                                      if (controller
                                          .notificationList.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        _badge(
                                          controller.notificationList.length,
                                          isDark,
                                          ColorResources.contentTextColor,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(LocalStrings.unread.tr),
                                      if (controller.unreadCount > 0) ...[
                                        const SizedBox(width: 6),
                                        _badge(
                                          controller.unreadCount,
                                          isDark,
                                          ColorResources.secondaryColor,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: controller.isLoading
                          ? const CustomLoader()
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildList(
                                  context,
                                  controller,
                                  controller.notificationList,
                                  isDark,
                                ),
                                _buildList(
                                  context,
                                  controller,
                                  controller.notificationList
                                      .where((n) => n.isUnread)
                                      .toList(),
                                  isDark,
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationController controller,
    List items,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: ColorResources.contentTextColor.withValues(alpha: .5),
            ),
            const SizedBox(height: 12),
            Text(
              LocalStrings.noNotifications.tr,
              style: regularDefault.copyWith(
                color: ColorResources.contentTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () => controller.initialData(shouldLoad: false),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: items.length,
        itemBuilder: (_, i) => NotificationCard(
          item: items[i],
          isDark: isDark,
          onMarkRead: items[i].isUnread
              ? () => controller.markAsRead(items[i].id ?? '')
              : null,
        ),
      ),
    );
  }

  Widget _badge(int count, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: semiBoldSmall.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.homeModel});
  final DashboardModel homeModel;

  /// Returns true when the admin has no role restriction (menuItems == null)
  /// OR when the specific permission flag is explicitly true.
  /// Mirrors the canView() logic used in dashboard_screen.dart.
  bool _canView(bool? permission) {
    final isAdminLike = homeModel.menuItems == null;
    return isAdminLike || permission == true;
  }

  bool get _showTasksMenu {
    if (_canView(homeModel.menuItems?.tasks)) return true;

    final totalTasks = int.tryParse(homeModel.overview?.totalTasks ?? '0') ?? 0;
    final notFinishedTasks =
        int.tryParse(homeModel.overview?.notFinishedTasksTotal ?? '0') ?? 0;

    // Fallback for staff accounts where menu_items.tasks is not sent,
    // but dashboard overview clearly includes task data.
    return totalTasks > 0 || notFinishedTasks > 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget navTile({
      required bool visible,
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? iconColor,
      Color? textColor,
    }) {
      if (!visible) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: _GlassMenuTile(
          icon: icon,
          label: label,
          isDark: isDark,
          iconColor: iconColor,
          textColor: textColor,
          onTap: onTap,
        ),
      );
    }

    return SafeArea(
      child: Drawer(
        width: MediaQuery.sizeOf(context).width * .72,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF343434).withValues(alpha: .92),
                          const Color(0xFF343434).withValues(alpha: .88),
                        ]
                      : [
                          const Color(0xFFF8FAFD).withValues(alpha: .9),
                          const Color(0xFFEFF3F8).withValues(alpha: .86),
                        ],
                ),
                border: Border.all(
                  color: (isDark
                          ? const Color(0xFF42506A)
                          : const Color(0xFFFFFFFF))
                      .withValues(alpha: .6),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFF343434)
                                : const Color(0xFFFFFFFF))
                            .withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isDark
                                  ? const Color(0xFF4A5C79)
                                  : const Color(0xFFFFFFFF))
                              .withValues(alpha: .58),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ColorResources.blueGreyColor,
                            radius: 34,
                            child: CircleImageWidget(
                              imagePath: homeModel.staff?.profileImage ?? '',
                              isAsset: false,
                              isProfile: true,
                              width: 64,
                              height: 64,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  homeModel.staff?.displayName ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: semiBoldLarge.copyWith(
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        (isDark
                                            ? Colors.white
                                            : ColorResources.primaryColor),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.toNamed(RouteHelper.profileScreen);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? const Color(0xFF223044)
                                              : const Color(0xFFE4F5FF))
                                          .withValues(alpha: .8),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      LocalStrings.viewProfile.tr,
                                      style: semiBoldDefault.copyWith(
                                        color: isDark
                                            ? const Color(0xFF99E2FF)
                                            : ColorResources.secondaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          navTile(
                            visible: true,
                            icon: Icons.assignment_outlined,
                            label: LocalStrings.workReports.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.workReportsScreen);
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.customers),
                            icon: Icons.group_outlined,
                            label: LocalStrings.customers.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.customerScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.projects) ||
                                (homeModel.staffPermissions?.canViewProjects ==
                                    true) ||
                                homeModel.menuItems !=
                                    null, // always show for staff
                            icon: Icons.task_outlined,
                            label: LocalStrings.projects.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.projectScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _showTasksMenu,
                            icon: Icons.task_alt_rounded,
                            label: LocalStrings.tasks.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.taskScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.invoices),
                            icon: Icons.assignment_outlined,
                            label: LocalStrings.invoices.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.invoiceScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.contracts),
                            icon: Icons.article_outlined,
                            label: LocalStrings.contracts.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.contractScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.tickets),
                            icon: Icons.confirmation_number_outlined,
                            label: LocalStrings.tickets.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.ticketScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.leads),
                            icon: Icons.markunread_mailbox_outlined,
                            label: LocalStrings.leads.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.leadScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.estimates),
                            icon: Icons.add_chart_outlined,
                            label: LocalStrings.estimates.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.estimateScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.proposals),
                            icon: Icons.document_scanner_outlined,
                            label: LocalStrings.proposals.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.proposalScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.payments),
                            icon: Icons.account_balance_wallet_outlined,
                            label: LocalStrings.payments.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.paymentScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: true,
                            icon: Icons.currency_rupee,
                            label: LocalStrings.expenses.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.expenseScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.items),
                            icon: Icons.add_box_outlined,
                            label: LocalStrings.items.tr,
                            onTap: () async {
                              Navigator.pop(context);
                              await Get.toNamed(RouteHelper.itemScreen);
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>()
                                    .initialData(shouldLoad: false);
                              }
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.creditNotes),
                            icon: Icons.credit_card_outlined,
                            label: LocalStrings.creditNotes.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.creditNotesScreen);
                            },
                          ),
                          navTile(
                            visible: _canView(homeModel.menuItems?.staff),
                            icon: Icons.people_outline,
                            label: LocalStrings.staff.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.staffScreen);
                            },
                          ),
                          navTile(
                            visible: true,
                            icon: Icons.checklist_outlined,
                            label: LocalStrings.todos.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.todoScreen);
                            },
                          ),
                          navTile(
                            visible: true,
                            icon: Icons.campaign_outlined,
                            label: LocalStrings.announcements.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.announcementScreen);
                            },
                          ),
                          navTile(
                            visible: true,
                            icon: Icons.notifications_outlined,
                            label: LocalStrings.notifications.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.notificationScreen);
                            },
                          ),
                          navTile(
                            visible: true,
                            icon: Icons.account_circle_outlined,
                            label: LocalStrings.settings.tr,
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(RouteHelper.settingsScreen);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
                    child: _GlassMenuTile(
                      icon: Icons.logout_rounded,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      label: LocalStrings.logout.tr,
                      isDark: isDark,
                      onTap: () {
                        const WarningAlertDialog().warningAlertDialog(
                          context,
                          () {
                            Get.back();
                            Get.find<DashboardController>().logout();
                          },
                          title: LocalStrings.logout.tr,
                          subTitle: LocalStrings.logoutSureWarningMSg.tr,
                        );
                      },
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

class _GlassMenuTile extends StatelessWidget {
  const _GlassMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ??
        (Theme.of(context).textTheme.bodyLarge?.color ??
            (isDark ? Colors.white : ColorResources.primaryColor));
    final effectiveIconColor = iconColor ?? effectiveTextColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: .34),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF4D5E79) : const Color(0xFFFFFFFF))
                      .withValues(alpha: .55),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF343434)
                          : const Color(0xFFF2F6FC))
                      .withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: mediumDefault.copyWith(color: effectiveTextColor),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: effectiveTextColor.withValues(alpha: .7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

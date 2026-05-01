import 'dart:ui';

import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/will_pop_widget.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/attendance_controller.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:flutex_admin/features/dashboard/widget/drawer.dart';
import 'package:flutex_admin/features/profile/controller/profile_controller.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutex_admin/features/work_report/view/work_report_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Get.lazyPut(() => DashboardRepo(apiClient: Get.find()));
    final controller = Get.put(DashboardController(dashboardRepo: Get.find()));
    controller.isLoading = true;

    // Register attendance controller so Check In/Out work from dashboard.
    // Use lazyPut so the controller is only instantiated (and its onInit
    // hits /attendance/today) when the staff branch of the UI actually
    // looks it up via GetBuilder. Admins never access it, so they never
    // hit the staff-only endpoint.
    if (!Get.isRegistered<AttendanceRepo>()) {
      Get.put(AttendanceRepo(apiClient: Get.find()));
    }
    if (!Get.isRegistered<AttendanceController>()) {
      Get.lazyPut(() => AttendanceController(attendanceRepo: Get.find()));
    }

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: GetBuilder<DashboardController>(builder: (controller) {
        final model = controller.homeModel;
        final menu = model.menuItems;
        final overview = model.overview;
        final data = model.data;

        final isAdminLike =
            menu == null || model.staffPermissions?.isAdmin == true;
        bool canView(bool? permission) => isAdminLike || permission == true;

        final totalTasks = _toInt(overview?.totalTasks);
        final openTasks = _toInt(overview?.notFinishedTasksTotal);
        final completedTasks = (totalTasks - openTasks).clamp(0, 999999);

        final showTasksTile = canView(menu?.tasks) ||
            (!isAdminLike &&
                menu.tasks == null &&
                (totalTasks > 0 || openTasks > 0));

        final tickets = data?.tickets ?? const <DataField>[];

        // The /dashboard endpoint groups `tickets` by STATUS (Open/Closed/...)
        // not by priority, so trying to extract Low/Medium/High counts from
        // it produces 0/0/0. The /tickets snapshot loaded into
        // controller.scopedTicket* is grouped by priority and works for both
        // admins and staff — use it as the single source of truth.
        // Fall back to the dashboard status-bucket totals only for the grand
        // total when the snapshot hasn't loaded yet.
        final ticketsTotal = controller.scopedTicketLoaded
            ? controller.scopedTicketTotal
            : _sumDataFieldTotals(tickets);
        final lowTotal = controller.scopedTicketLow;
        final mediumTotal = controller.scopedTicketMedium;
        final highTotal = controller.scopedTicketHigh;

        int toPercent(int value, int total) {
          if (total <= 0) return 0;
          return ((value * 100) / total).round().clamp(0, 100);
        }

        final lowPercent = toPercent(lowTotal, ticketsTotal);
        final mediumPercent = toPercent(mediumTotal, ticketsTotal);
        final highPercent = toPercent(highTotal, ticketsTotal);

        final reportsGenerated = _sumDataFieldTotals(data?.proposals);
        final reportsPending = _sumDataFieldTotals(data?.estimates);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final horizontalPadding = MediaQuery.sizeOf(context).width > 600
            ? Dimensions.space25
            : Dimensions.space15;
        final halfTileWidth = _tileWidth(context, horizontalPadding);
        final fullTileWidth = _tileWidthFull(context, horizontalPadding);

        final showTickets = canView(menu?.tickets);
        // For non-admin staff, Perfex sets menu_items.projects=0 even for
        // "view own" permission. Always show the tile and let the projects
        // screen handle access control gracefully.
        final showProjects = isAdminLike
            ? canView(menu?.projects)
            : (canView(menu.projects) ||
                (model.staffPermissions?.canViewProjects == true) ||
                true); // show for all staff; screen handles no-access
        final showUsers = canView(menu?.customers);
        final showRevenue = canView(menu?.invoices);
        final showLeads = canView(menu?.leads);
        final showReports =
            canView(menu?.proposals) || canView(menu?.estimates);
        final showFallback = !showTickets &&
            !showProjects &&
            !showUsers &&
            !showRevenue &&
            !showTasksTile &&
            !showReports;

        final visibleFlags = <bool>[
          showTickets,
          showProjects,
          showUsers,
          showRevenue,
          showTasksTile,
          showReports,
          showFallback,
        ];
        final visibleTileCount =
            visibleFlags.where((isVisible) => isVisible).length;
        final lastVisibleIndex =
            visibleFlags.lastIndexWhere((isVisible) => isVisible);

        double widthForIndex(int index) {
          if (visibleTileCount.isOdd && index == lastVisibleIndex) {
            return fullTileWidth;
          }
          return halfTileWidth;
        }

        final navItems = <_NavItem>[
          const _NavItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              route: null),
          if (showProjects)
            const _NavItem(
                label: 'Projects',
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                route: RouteHelper.projectScreen),
          if (showTickets)
            const _NavItem(
                label: 'Tickets',
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number,
                route: RouteHelper.ticketScreen),
          if (showLeads)
            const _NavItem(
                label: 'Leads',
                icon: Icons.trending_up_outlined,
                activeIcon: Icons.trending_up,
                route: RouteHelper.leadScreen),
          const _NavItem(
              label: 'Menu',
              icon: Icons.menu_rounded,
              activeIcon: Icons.menu_open_rounded,
              route: null),
        ];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          endDrawer: HomeDrawer(homeModel: model),
          endDrawerEnableOpenDragGesture: false,
          bottomNavigationBar: _GlassBottomNav(
            items: navItems,
            currentIndex: 0,
            isDark: isDark,
            onTap: (item) {
              if (item.route == null) {
                if (item.label == 'Menu') {
                  _scaffoldKey.currentState?.openEndDrawer();
                }
                return;
              }
              Get.toNamed(item.route!);
            },
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
                  top: -70,
                  left: -60,
                  child: _BlurOrb(
                    size: 180,
                    color: (isDark
                            ? const Color(0xFF343434)
                            : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.28 : 0.65),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: -50,
                  child: _BlurOrb(
                    size: 150,
                    color: (isDark
                            ? const Color(0xFF23324A)
                            : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.22 : 0.55),
                  ),
                ),
                SafeArea(
                  child: controller.isLoading
                      ? const CustomLoader()
                      : RefreshIndicator(
                          color: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).cardColor,
                          onRefresh: () async {
                            await controller.initialData(shouldLoad: false);
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                Dimensions.space8,
                                horizontalPadding,
                                Dimensions.space25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: Dimensions.space8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (!Get.isRegistered<ApiClient>()) {
                                          Get.put(ApiClient(
                                              sharedPreferences: Get.find()));
                                        }
                                        if (!Get.isRegistered<ProfileRepo>()) {
                                          Get.put(ProfileRepo(
                                              apiClient: Get.find()));
                                        }

                                        final profileController =
                                            Get.isRegistered<
                                                    ProfileController>()
                                                ? Get.find<ProfileController>()
                                                : Get.put(ProfileController(
                                                    profileRepo: Get.find()));

                                        if (profileController
                                                .profileModel.data ==
                                            null) {
                                          await profileController.loadData();
                                        }

                                        Get.toNamed(RouteHelper.profileScreen);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor:
                                            ColorResources.blueGreyColor,
                                        radius: 28,
                                        child: CircleImageWidget(
                                          imagePath:
                                              model.staff?.profileImage ?? '',
                                          isAsset: false,
                                          isProfile: true,
                                          width: 52,
                                          height: 52,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            model.staff?.displayName ?? '',
                                            style: semiBoldLarge.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            model.staff?.email ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .contentTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Notification bell with unread badge
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await Get.toNamed(
                                                RouteHelper.notificationScreen);
                                            if (Get.isRegistered<
                                                DashboardController>()) {
                                              Get.find<DashboardController>()
                                                  .initialData(
                                                      shouldLoad: false);
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.notifications_outlined),
                                        ),
                                        if (controller.unreadNotificationCount >
                                            0)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    width: 1.5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  controller.unreadNotificationCount >
                                                          99
                                                      ? '99+'
                                                      : '${controller.unreadNotificationCount}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => Get.toNamed(
                                          RouteHelper.settingsScreen),
                                      icon: const Icon(Icons.settings_outlined),
                                    )
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space15),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      LocalStrings.overview.tr,
                                      style: boldOverLarge.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontSize: 46,
                                        height: 1,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isAdminLike)
                                      GestureDetector(
                                        onTap: () => Get.toNamed(
                                            RouteHelper.adminAttendanceScreen),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.fact_check_outlined,
                                                  color: Colors.white,
                                                  size: 16),
                                              const SizedBox(width: 6),
                                              Text('View Attendance',
                                                  style:
                                                      semiBoldDefault.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      GetBuilder<AttendanceController>(
                                        builder: (ac) {
                                          final checkedIn =
                                              ac.todayAttendance?.isCheckedIn ==
                                                  true;
                                          final checkedOut = ac.todayAttendance
                                                  ?.isCheckedOut ==
                                              true;
                                          final allDone =
                                              checkedIn && checkedOut;
                                          final isLoading = ac.isCheckingIn ||
                                              ac.isCheckingOut;

                                          final Color btnColor = allDone
                                              ? Colors.grey
                                              : checkedIn
                                                  ? Colors.orange
                                                  : Colors.green;
                                          final IconData btnIcon = allDone
                                              ? Icons.check_circle_outline
                                              : checkedIn
                                                  ? Icons.logout
                                                  : Icons.login;
                                          final String btnLabel = allDone
                                              ? 'Done'
                                              : checkedIn
                                                  ? 'Check Out'
                                                  : 'Check In';
                                          final VoidCallback? btnAction =
                                              (allDone || isLoading)
                                                  ? null
                                                  : checkedIn
                                                      ? ac.performCheckOut
                                                      : ac.performCheckIn;

                                          return GestureDetector(
                                            onTap: btnAction,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: btnColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (isLoading)
                                                    const SizedBox(
                                                      width: 14,
                                                      height: 14,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white),
                                                    )
                                                  else
                                                    Icon(btnIcon,
                                                        color: Colors.white,
                                                        size: 16),
                                                  const SizedBox(width: 6),
                                                  Text(btnLabel,
                                                      style: semiBoldDefault
                                                          .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space12),
                                const WorkReportDashboardWidget(),
                                const SizedBox(height: Dimensions.space12),
                                Wrap(
                                  spacing: Dimensions.space12,
                                  runSpacing: Dimensions.space12,
                                  children: [
                                    if (showTickets)
                                      _TileCard(
                                        width: widthForIndex(0),
                                        title: LocalStrings.tickets.tr,
                                        icon:
                                            Icons.confirmation_number_outlined,
                                        minHeight: 208,
                                        isDark: isDark,
                                        onTap: () => Get.toNamed(
                                            RouteHelper.ticketScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$ticketsTotal',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 48, height: 1),
                                            ),
                                            const SizedBox(height: 8),
                                            _TicketStatusRow(
                                              label: 'Low',
                                              total: lowTotal,
                                              percent: lowPercent,
                                              color: const Color(0xFF16B5A7),
                                            ),
                                            _TicketStatusRow(
                                              label: 'Medium',
                                              total: mediumTotal,
                                              percent: mediumPercent,
                                              color: const Color(0xFFF39C12),
                                            ),
                                            _TicketStatusRow(
                                              label: 'High',
                                              total: highTotal,
                                              percent: highPercent,
                                              color: const Color(0xFFE74C3C),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (showProjects)
                                      _TileCard(
                                        width: widthForIndex(1),
                                        title: LocalStrings.projects.tr,
                                        icon: Icons.work_outline,
                                        minHeight: 158,
                                        isDark: isDark,
                                        onTap: () => Get.toNamed(
                                            RouteHelper.projectScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              overview?.projectsInProgressTotal ??
                                                  '0',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 48, height: 1),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(LocalStrings.active.tr,
                                                    style: regularDefault),
                                                const Spacer(),
                                                Text(
                                                    '${overview?.totalProjects ?? '0'} ${LocalStrings.total.tr}',
                                                    style: regularDefault.copyWith(
                                                        color: ColorResources
                                                            .contentTextColor)),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            _ProgressLine(
                                                percent: _toInt(overview
                                                    ?.inProgressProjectsPercent)),
                                          ],
                                        ),
                                      ),
                                    if (showUsers)
                                      _TileCard(
                                        width: widthForIndex(2),
                                        title: 'Customers',
                                        icon: Icons.groups_2_outlined,
                                        minHeight: 158,
                                        isDark: isDark,
                                        onTap: () => Get.toNamed(
                                            RouteHelper.customerScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data?.customers?.customersTotal ??
                                                  '0',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 48, height: 1),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '+12%',
                                              style: semiBoldDefault.copyWith(
                                                  color:
                                                      const Color(0xFF1D8E53)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (showRevenue)
                                      _TileCard(
                                        width: widthForIndex(3),
                                        title: 'Revenue',
                                        icon: Icons.insights_outlined,
                                        minHeight: 170,
                                        isDark: isDark,
                                        onTap: () => Get.toNamed(
                                            RouteHelper.invoiceScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '₹${overview?.invoicesAwaitingPaymentTotal ?? '0'}',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 42, height: 1),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Up ${overview?.invoicesAwaitingPaymentPercent ?? '0'}%',
                                              style: semiBoldDefault.copyWith(
                                                  color:
                                                      const Color(0xFF1D8E53)),
                                            ),
                                            const SizedBox(height: 10),
                                            _MiniBars(isDark: isDark),
                                          ],
                                        ),
                                      ),
                                    if (showTasksTile)
                                      _TileCard(
                                        width: widthForIndex(4),
                                        title: LocalStrings.tasks.tr,
                                        icon: Icons.task_alt_outlined,
                                        minHeight: 170,
                                        isDark: isDark,
                                        onTap: () =>
                                            Get.toNamed(RouteHelper.taskScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$openTasks',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 48, height: 1),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                                '${LocalStrings.open.tr} $openTasks',
                                                style: regularLarge),
                                            const SizedBox(height: 2),
                                            Text(
                                                '${LocalStrings.completed.tr} $completedTasks',
                                                style: regularLarge),
                                          ],
                                        ),
                                      ),
                                    if (showReports)
                                      _TileCard(
                                        width: widthForIndex(5),
                                        title: 'Reports',
                                        icon: Icons.description_outlined,
                                        minHeight: 150,
                                        isDark: isDark,
                                        onTap: () => Get.toNamed(
                                            RouteHelper.proposalScreen),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$reportsGenerated',
                                              style: boldOverLarge.copyWith(
                                                  fontSize: 48, height: 1),
                                            ),
                                            const SizedBox(height: 6),
                                            Text('Generated',
                                                style: regularLarge),
                                            const SizedBox(height: 2),
                                            Text(
                                                '$reportsPending ${LocalStrings.pending.tr}',
                                                style: regularLarge),
                                          ],
                                        ),
                                      ),
                                    if (showFallback)
                                      SizedBox(
                                        width: widthForIndex(6),
                                        child: _TileCard(
                                          width: widthForIndex(6),
                                          title: LocalStrings.overview.tr,
                                          icon: Icons.lock_outline,
                                          minHeight: 150,
                                          isDark: isDark,
                                          child: Text(
                                            'No modules available for this role',
                                            style: regularDefault.copyWith(
                                                color: ColorResources
                                                    .contentTextColor),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space12),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

double _tileWidth(BuildContext context, double horizontalPadding) {
  final width = MediaQuery.sizeOf(context).width;
  return (width - (horizontalPadding * 2) - Dimensions.space12) / 2;
}

double _tileWidthFull(BuildContext context, double horizontalPadding) {
  final width = MediaQuery.sizeOf(context).width;
  return width - (horizontalPadding * 2);
}

int _toInt(String? raw) => int.tryParse(raw ?? '0') ?? 0;

int _sumDataFieldTotals(List<DataField>? values) {
  if (values == null || values.isEmpty) return 0;
  return values.fold<int>(0, (sum, item) => sum + _toInt(item.total));
}

DataField? _findStatus(List<DataField> values, String key) {
  for (final item in values) {
    if ((item.status ?? '').toLowerCase().contains(key)) return item;
  }
  return null;
}

DataField _ticketPrioritySummary(
  List<DataField> values, {
  required Set<String> exact,
  required Set<String> contains,
}) {
  int total = 0;
  int percent = 0;

  for (final item in values) {
    final rawStatus = (item.status ?? '').trim().toLowerCase();
    if (rawStatus.isEmpty) continue;

    final matchesExact = exact.contains(rawStatus);
    final matchesContains = contains.any(rawStatus.contains);
    if (!matchesExact && !matchesContains) continue;

    total += _toInt(item.total);
    percent += _toInt(item.percent);
  }

  return DataField(total: '$total', percent: '$percent');
}

class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.width,
    required this.title,
    required this.icon,
    required this.child,
    this.minHeight = 150,
    required this.isDark,
    this.onTap,
  });

  final double width;
  final String title;
  final IconData icon;
  final Widget child;
  final double minHeight;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: BoxConstraints(minHeight: minHeight),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF343434)
                          : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.34),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark
                            ? const Color(0xFF414A5B)
                            : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.48 : 0.55),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      offset: Offset(0, 14),
                      blurRadius: 24,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: mediumExtraLarge.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withValues(alpha: isDark ? 0.92 : 0.72)),
                          ),
                        ),
                        Icon(icon,
                            size: 20,
                            color: (isDark
                                    ? Colors.white
                                    : ColorResources.contentTextColor)
                                .withValues(alpha: isDark ? 0.82 : 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketStatusRow extends StatelessWidget {
  const _TicketStatusRow({
    required this.label,
    required this.total,
    required this.percent,
    required this.color,
  });

  final String label;
  final int total;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('$label $total', style: regularDefault)),
              Text('$percent%',
                  style: regularDefault.copyWith(
                      color: ColorResources.contentTextColor)),
            ],
          ),
          const SizedBox(height: 3),
          _ProgressLine(percent: percent, color: color),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.percent, this.color});

  final int percent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = (percent.clamp(0, 100)) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        minHeight: 6,
        value: normalized.toDouble(),
        color: color ??
            (isDark ? const Color(0xFF7C92B3) : const Color(0xFF4A6072)),
        backgroundColor:
            isDark ? const Color(0xFF313746) : const Color(0xFFDCE1E8),
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bars = [12, 26, 38, 22, 10, 18, 30, 44, 24, 28, 34];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars
          .map(
            (height) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: height.toDouble(),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF9BAAC1)
                            : const Color(0xFFA8B4C7))
                        .withValues(alpha: isDark ? 0.55 : 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          )
          .toList(),
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
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String? route;
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.items,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final bool isDark;
  final void Function(_NavItem item) onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color:
                  (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.58 : 0.45),
              border: Border.all(
                color:
                    (isDark ? const Color(0xFF3F4756) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.62 : 0.65),
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == currentIndex;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onTap(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 21,
                            color: isActive
                                ? Theme.of(context).primaryColor
                                : (isDark
                                    ? const Color(0xFFBDC4D0)
                                    : ColorResources.contentTextColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: regularExtraSmall.copyWith(
                              color: isActive
                                  ? Theme.of(context).primaryColor
                                  : (isDark
                                      ? const Color(0xFFBDC4D0)
                                      : ColorResources.contentTextColor),
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

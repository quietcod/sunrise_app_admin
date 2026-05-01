import 'dart:ui';

import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:flutex_admin/features/dashboard/widget/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Routes where the global menu pull-tab should NOT be shown.
const Set<String> _hiddenRoutes = {
  RouteHelper.splashScreen,
  RouteHelper.onboardScreen,
  RouteHelper.loginScreen,
  RouteHelper.forgotPasswordScreen,
  RouteHelper.dashboardScreen,
};

/// Navigator observer that exposes the current route name as a [Listenable]
/// so the global overlay can rebuild whenever navigation occurs.
class GlobalMenuRouteObserver extends NavigatorObserver with ChangeNotifier {
  String? _currentRoute;
  String? get currentRoute => _currentRoute;

  void _update(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name != _currentRoute) {
      _currentRoute = name;
      notifyListeners();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _update(newRoute);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(previousRoute);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(previousRoute);
}

/// Single shared observer instance to wire into `GetMaterialApp.navigatorObservers`.
final GlobalMenuRouteObserver globalMenuRouteObserver =
    GlobalMenuRouteObserver();

/// Slides the dashboard drawer in from the right as a transparent overlay,
/// so users can navigate from any page in the app.
Future<void> showAppMenuOverlay(BuildContext context) async {
  if (!Get.isRegistered<DashboardController>()) {
    if (!Get.isRegistered<DashboardRepo>()) {
      Get.lazyPut(() => DashboardRepo(apiClient: Get.find()));
    }
    Get.put(DashboardController(dashboardRepo: Get.find()));
  }
  final controller = Get.find<DashboardController>();

  // The overlay is rendered inside MaterialApp.builder, whose BuildContext
  // sits ABOVE the Navigator. We must dispatch the dialog through a context
  // that lives below the Navigator, otherwise showGeneralDialog throws/no-ops.
  final dialogContext = Get.key.currentContext ?? context;

  await showGeneralDialog<void>(
    context: dialogContext,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, _, __) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: HomeDrawer(homeModel: controller.homeModel),
        ),
      );
    },
    transitionBuilder: (ctx, anim, __, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim);
      return SlideTransition(position: offset, child: child);
    },
  );
}

/// Wraps every page with a subtle, draggable "pull-tab" anchored to the right
/// edge of the screen that opens the global app menu. Hidden on auth and
/// dashboard routes (the dashboard already has the menu in the bottom nav).
class GlobalMenuOverlay extends StatefulWidget {
  const GlobalMenuOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalMenuOverlay> createState() => _GlobalMenuOverlayState();
}

class _GlobalMenuOverlayState extends State<GlobalMenuOverlay> {
  /// Vertical position of the tab as a fraction of available height (0..1).
  /// Persisted in-memory across rebuilds; defaults to slightly above center.
  static double _verticalFraction = 0.45;

  @override
  void initState() {
    super.initState();
    globalMenuRouteObserver.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    globalMenuRouteObserver.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final route = globalMenuRouteObserver.currentRoute ?? Get.currentRoute;
    final hidden = _hiddenRoutes.contains(route);
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        if (!hidden)
          _MenuPullTab(
            initialFraction: _verticalFraction,
            onMoved: (f) => _verticalFraction = f,
            onTap: () => showAppMenuOverlay(context),
          ),
      ],
    );
  }
}

class _MenuPullTab extends StatefulWidget {
  const _MenuPullTab({
    required this.initialFraction,
    required this.onMoved,
    required this.onTap,
  });

  final double initialFraction;
  final ValueChanged<double> onMoved;
  final VoidCallback onTap;

  @override
  State<_MenuPullTab> createState() => _MenuPullTabState();
}

class _MenuPullTabState extends State<_MenuPullTab> {
  late double _fraction = widget.initialFraction;

  static const double _tabWidth = 26;
  static const double _tabHeight = 56;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    // Constrain vertical area: keep tab away from top notch and bottom inset.
    final topInset = media.padding.top + 80; // below typical app bar
    final bottomInset = media.padding.bottom + 90; // above bottom nav / FAB
    final availableHeight = (media.size.height - topInset - bottomInset)
        .clamp(120.0, double.infinity);
    final top = topInset + (availableHeight * _fraction);

    final tabColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : scheme.primary.withValues(alpha: 0.85);
    final iconColor = isDark ? Colors.white : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.45);

    return Positioned(
      top: top,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            setState(() {
              final newTop = (top + details.delta.dy)
                  .clamp(topInset, topInset + availableHeight);
              _fraction =
                  ((newTop - topInset) / availableHeight).clamp(0.0, 1.0);
            });
            widget.onMoved(_fraction);
          },
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: _tabWidth,
                height: _tabHeight,
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  border: Border(
                    top: BorderSide(color: borderColor),
                    left: BorderSide(color: borderColor),
                    bottom: BorderSide(color: borderColor),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                      blurRadius: 10,
                      offset: const Offset(-2, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.menu_rounded, size: 18, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

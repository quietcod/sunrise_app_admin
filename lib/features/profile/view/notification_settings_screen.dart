import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const String _prefix = 'notif_pref_';

  static const List<_NotifCategory> _categories = [
    _NotifCategory('tasks', 'Tasks', Icons.task_alt_outlined,
        'Assigned tasks, updates, comments'),
    _NotifCategory('invoices', 'Invoices', Icons.receipt_long_outlined,
        'New and overdue invoices'),
    _NotifCategory('payments', 'Payments', Icons.payments_outlined,
        'Payment received notifications'),
    _NotifCategory('tickets', 'Tickets', Icons.confirmation_number_outlined,
        'New and updated support tickets'),
    _NotifCategory(
        'leads', 'Leads', Icons.people_alt_outlined, 'New lead assignments'),
    _NotifCategory('projects', 'Projects', Icons.folder_open_outlined,
        'Project updates and milestones'),
    _NotifCategory('estimates', 'Estimates', Icons.calculate_outlined,
        'Estimate status changes'),
    _NotifCategory('proposals', 'Proposals', Icons.description_outlined,
        'Proposal status changes'),
    _NotifCategory(
        'contracts', 'Contracts', Icons.handshake_outlined, 'Contract updates'),
    _NotifCategory('customers', 'Customers', Icons.business_outlined,
        'New customer registrations'),
  ];

  final Map<String, bool> _prefs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final cat in _categories) {
      map[cat.key] = sp.getBool('$_prefix${cat.key}') ?? true;
    }
    setState(() {
      _prefs.addAll(map);
      _isLoading = false;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('$_prefix$key', value);
    setState(() => _prefs[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

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
                color:
                    (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.25 : 0.62),
              ),
            ),
            Positioned(
              bottom: 200,
              right: -60,
              child: _BlurOrb(
                size: 160,
                color:
                    (isDark ? const Color(0xFF23324A) : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.2 : 0.5),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                      Dimensions.space15, Dimensions.space10),
                  child: _GlassHeader(isDark: isDark),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(Dimensions.space15),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(Dimensions.space12),
                              margin: const EdgeInsets.only(
                                  bottom: Dimensions.space15),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 18,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(width: Dimensions.space8),
                                  Expanded(
                                    child: Text(
                                      'Choose which push notifications you want to receive.',
                                      style: regularSmall.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? const Color(0xFF343434)
                                            : const Color(0xFFFFFFFF))
                                        .withValues(
                                            alpha: isDark ? 0.42 : 0.34),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (isDark
                                              ? const Color(0xFF414A5B)
                                              : const Color(0xFFFFFFFF))
                                          .withValues(
                                              alpha: isDark ? 0.46 : 0.55),
                                    ),
                                  ),
                                  child: Column(
                                    children: List.generate(_categories.length,
                                        (index) {
                                      final cat = _categories[index];
                                      final enabled = _prefs[cat.key] ?? true;
                                      final isLast =
                                          index == _categories.length - 1;

                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: (enabled
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : ColorResources
                                                            .blueGreyColor)
                                                    .withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                cat.icon,
                                                size: 18,
                                                color: enabled
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : ColorResources
                                                        .blueGreyColor,
                                              ),
                                            ),
                                            title: Text(
                                              cat.label,
                                              style: regularDefault.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: enabled
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                    : ColorResources
                                                        .blueGreyColor,
                                              ),
                                            ),
                                            subtitle: Text(
                                              cat.description,
                                              style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor,
                                                fontSize: 11,
                                              ),
                                            ),
                                            trailing: Switch.adaptive(
                                              value: enabled,
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              onChanged: (v) =>
                                                  _toggle(cat.key, v),
                                            ),
                                            onTap: () =>
                                                _toggle(cat.key, !enabled),
                                          ),
                                          if (!isLast)
                                            Divider(
                                              height: 1,
                                              indent: 66,
                                              color: isDark
                                                  ? Colors.white
                                                      .withValues(alpha: 0.06)
                                                  : Colors.black
                                                      .withValues(alpha: 0.05),
                                            ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.isDark});
  final bool isDark;

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
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  'Notification Settings',
                  style: boldExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
            ],
          ),
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
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _NotifCategory {
  const _NotifCategory(this.key, this.label, this.icon, this.description);
  final String key;
  final String label;
  final IconData icon;
  final String description;
}

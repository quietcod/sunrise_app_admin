import 'dart:ui';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingItem(
        icon: Icons.percent_rounded,
        label: LocalStrings.taxes.tr,
        route: RouteHelper.taxesScreen,
      ),
      _SettingItem(
        icon: Icons.payment_rounded,
        label: LocalStrings.paymentModes.tr,
        route: RouteHelper.paymentModesScreen,
      ),
      _SettingItem(
        icon: Icons.corporate_fare_rounded,
        label: LocalStrings.departments.tr,
        route: RouteHelper.departmentsScreen,
      ),
      _SettingItem(
        icon: Icons.group_rounded,
        label: LocalStrings.clientGroups.tr,
        route: RouteHelper.clientGroupsScreen,
      ),
      _SettingItem(
        icon: Icons.admin_panel_settings_rounded,
        label: LocalStrings.roles.tr,
        route: RouteHelper.rolesScreen,
      ),
      _SettingItem(
        icon: Icons.category_rounded,
        label: 'Expense Categories',
        route: RouteHelper.expenseCategoriesScreen,
      ),
      _SettingItem(
        icon: Icons.format_list_numbered_rounded,
        label: 'Invoice Number',
        route: RouteHelper.invoiceNumberSettingsScreen,
      ),
      _SettingItem(
        icon: Icons.description_outlined,
        label: 'Contract Types',
        route: RouteHelper.contractTypesScreen,
      ),
    ];

    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: _BlurOrb(
                  size: 200,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: isDark ? 0.18 : 0.25),
                ),
              ),
              Positioned(
                bottom: 160,
                right: -60,
                child: _BlurOrb(
                  size: 160,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: isDark ? 0.25 : 0.55),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _GlassHeader(
                      isDark: isDark,
                      title: LocalStrings.adminSettings.tr,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space15,
                          vertical: Dimensions.space10),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () => Get.toNamed(item.route),
                          borderRadius: BorderRadius.circular(18),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space15,
                                  vertical: Dimensions.space15,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withValues(alpha: isDark ? 0.42 : 0.34),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(
                                            alpha: isDark ? 0.46 : 0.55),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(item.icon,
                                        color: Theme.of(context).primaryColor,
                                        size: 24),
                                    const SizedBox(width: Dimensions.space15),
                                    Expanded(
                                      child: Text(item.label,
                                          style: regularDefault.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          )),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String route;
  const _SettingItem(
      {required this.icon, required this.label, required this.route});
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.isDark, required this.title});
  final bool isDark;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .cardColor
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: isDark ? 0.46 : 0.55)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  title,
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

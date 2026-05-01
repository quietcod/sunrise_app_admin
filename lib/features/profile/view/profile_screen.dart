import 'dart:ui';

import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/profile/controller/profile_controller.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _cacheBustedImage(String? rawUrl, int nonce) {
    final base = (rawUrl ?? '').trim();
    if (base.isEmpty) return '';
    final sep = base.contains('?') ? '&' : '?';
    return '$base${sep}v=$nonce';
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading || controller.profileModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final s = controller.profileModel.data!;
      final isAdmin = s.admin == '1';

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
                  color: (isDark
                          ? const Color(0xFF343434)
                          : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.25 : 0.62),
                ),
              ),
              Positioned(
                bottom: 200,
                right: -60,
                child: _BlurOrb(
                  size: 160,
                  color: (isDark
                          ? const Color(0xFF23324A)
                          : const Color(0xFFD0E7FF))
                      .withValues(alpha: isDark ? 0.2 : 0.5),
                ),
              ),
              Column(
                children: [
                  // Glass header
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _ProfileHeader(isDark: isDark, isAdmin: isAdmin),
                  ),
                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async => controller.loadData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.space15),
                        child: Column(
                          children: [
                            // Avatar + name hero
                            _GlassCard(
                              isDark: isDark,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showPhotoOptions(context, controller),
                                    child: Stack(
                                      children: [
                                        CircleImageWidget(
                                          isProfile: true,
                                          imagePath: _cacheBustedImage(
                                              s.profileImage,
                                              controller.profileImageNonce),
                                          height: 72,
                                          width: 72,
                                          isAsset: false,
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: isDark
                                                      ? const Color(0xFF000000)
                                                      : const Color(0xFFEFF3F8),
                                                  width: 2),
                                            ),
                                            child: const Icon(
                                                Icons.camera_alt_outlined,
                                                size: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.space15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.displayName,
                                          style: boldExtraLarge.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                        ),
                                        if ((s.role ?? '').isNotEmpty)
                                          Text(
                                            s.role!,
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.space12),
                            // Contact info
                            _GlassCard(
                              isDark: isDark,
                              child: Column(
                                children: [
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.email.tr,
                                    value: s.email ?? '-',
                                    icon: Icons.email_outlined,
                                  ),
                                  if ((s.phoneNumber ?? '').isNotEmpty) ...[
                                    _HDivider(isDark: isDark),
                                    _InfoRow(
                                      isDark: isDark,
                                      label: LocalStrings.phone.tr,
                                      value: s.phoneNumber!,
                                      icon: Icons.phone_outlined,
                                    ),
                                  ],
                                  if ((s.skype ?? '').isNotEmpty) ...[
                                    _HDivider(isDark: isDark),
                                    _InfoRow(
                                      isDark: isDark,
                                      label: 'Skype',
                                      value: s.skype!,
                                      icon: Icons.chat_bubble_outline_rounded,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Social links (shown only if any exist)
                            if ((s.facebook ?? '').isNotEmpty ||
                                (s.linkedin ?? '').isNotEmpty) ...[
                              const SizedBox(height: Dimensions.space12),
                              _GlassCard(
                                isDark: isDark,
                                child: Column(
                                  children: [
                                    if ((s.facebook ?? '').isNotEmpty)
                                      _InfoRow(
                                        isDark: isDark,
                                        label: 'Facebook',
                                        value: s.facebook!,
                                        icon: Icons.link_rounded,
                                      ),
                                    if ((s.facebook ?? '').isNotEmpty &&
                                        (s.linkedin ?? '').isNotEmpty)
                                      _HDivider(isDark: isDark),
                                    if ((s.linkedin ?? '').isNotEmpty)
                                      _InfoRow(
                                        isDark: isDark,
                                        label: 'LinkedIn',
                                        value: s.linkedin!,
                                        icon: Icons.link_rounded,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                            // Account info
                            const SizedBox(height: Dimensions.space12),
                            _GlassCard(
                              isDark: isDark,
                              child: Column(
                                children: [
                                  _InfoRow(
                                    isDark: isDark,
                                    label: LocalStrings.status.tr,
                                    value: s.active == '1'
                                        ? LocalStrings.active.tr
                                        : LocalStrings.notActive.tr,
                                    icon: Icons.toggle_on_outlined,
                                    valueColor: s.active == '1'
                                        ? ColorResources.greenColor
                                        : ColorResources.redColor,
                                  ),
                                  _HDivider(isDark: isDark),
                                  _InfoRow(
                                    isDark: isDark,
                                    label: 'Admin',
                                    value: isAdmin ? 'Yes' : 'No',
                                    icon: Icons.admin_panel_settings_outlined,
                                  ),
                                  if ((s.hourlyRate ?? '').isNotEmpty &&
                                      s.hourlyRate != '0.00') ...[
                                    _HDivider(isDark: isDark),
                                    _InfoRow(
                                      isDark: isDark,
                                      label: 'Hourly Rate',
                                      value: s.hourlyRate!,
                                      icon: Icons.access_time_outlined,
                                    ),
                                  ],
                                  if ((s.dateCreated ?? '').isNotEmpty) ...[
                                    _HDivider(isDark: isDark),
                                    _InfoRow(
                                      isDark: isDark,
                                      label: 'Member Since',
                                      value: s.dateCreated!,
                                      icon: Icons.calendar_today_outlined,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Action buttons
                            const SizedBox(height: Dimensions.space12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    isDark: isDark,
                                    label: LocalStrings.editProfile.tr,
                                    icon: Icons.edit_outlined,
                                    color: ColorResources.blueColor,
                                    onTap: () => Get.toNamed(
                                        RouteHelper.editProfileScreen),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space12),
                                Expanded(
                                  child: _ActionButton(
                                    isDark: isDark,
                                    label: LocalStrings.changePassword.tr,
                                    icon: Icons.lock_outline_rounded,
                                    color: ColorResources.colorOrange,
                                    onTap: () => Get.toNamed(
                                        RouteHelper.changePasswordScreen),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space10),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    isDark: isDark,
                                    label: 'My Timesheets',
                                    icon: Icons.timer_outlined,
                                    color: ColorResources.greenColor,
                                    onTap: () => Get.toNamed(
                                        RouteHelper.myTimesheetsScreen),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space12),
                                Expanded(
                                  child: _ActionButton(
                                    isDark: isDark,
                                    label: 'Notifications',
                                    icon: Icons.notifications_outlined,
                                    color: ColorResources.purpleColor,
                                    onTap: () => Get.toNamed(
                                        RouteHelper.notificationSettingsScreen),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space25),
                          ],
                        ),
                      ),
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

  void _showPhotoOptions(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(LocalStrings.chooseFromGallery.tr),
              onTap: () {
                Navigator.pop(context);
                controller.uploadProfilePicture(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(LocalStrings.takePhoto.tr),
              onTap: () {
                Navigator.pop(context);
                controller.uploadProfilePicture(fromCamera: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Colors.redAccent.withValues(alpha: 0.8)),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                controller.removeProfilePicture();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isDark,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final bool isDark;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: color.withValues(alpha: 0.35), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: semiBoldSmall.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isDark, required this.isAdmin});
  final bool isDark;
  final bool isAdmin;

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
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  LocalStrings.profile.tr,
                  style: boldExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              if (isAdmin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorResources.blueColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorResources.blueColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Admin',
                    style: regularSmall.copyWith(
                        color: ColorResources.blueColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF343434), const Color(0xFF343434)]
                  : [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                      const Color(0xFFEFF3F8).withValues(alpha: 0.65),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF2A3347) : const Color(0xFFD8E2F0))
                      .withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.blueGrey)
                    .withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space8),
        child: Divider(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.7),
          height: 1,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ColorResources.blueGreyColor),
        const SizedBox(width: Dimensions.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: regularSmall.copyWith(
                      color: ColorResources.blueGreyColor)),
              const SizedBox(height: 2),
              Text(value,
                  style: semiBoldDefault.copyWith(
                      color: valueColor ??
                          Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ],
    );
  }
}

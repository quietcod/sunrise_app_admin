import 'dart:ui';

import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

    return GetBuilder<ProfileController>(builder: (controller) {
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
                    child: _GlassHeader(isDark: isDark),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      child: Column(
                        children: [
                          _GlassCard(
                            isDark: isDark,
                            child: Column(
                              children: [
                                CustomTextField(
                                  labelText: LocalStrings.firstName.tr,
                                  hintText: LocalStrings.enterFirstName.tr,
                                  controller: controller.firstNameController,
                                  textInputType: TextInputType.name,
                                  onChanged: (_) {},
                                ),
                                const SizedBox(height: Dimensions.space15),
                                CustomTextField(
                                  labelText: LocalStrings.lastName.tr,
                                  hintText: LocalStrings.enterLastName.tr,
                                  controller: controller.lastNameController,
                                  textInputType: TextInputType.name,
                                  onChanged: (_) {},
                                ),
                                const SizedBox(height: Dimensions.space15),
                                CustomTextField(
                                  labelText: LocalStrings.phone.tr,
                                  hintText: 'Enter phone number',
                                  controller: controller.phoneController,
                                  textInputType: TextInputType.phone,
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.space12),
                          _GlassCard(
                            isDark: isDark,
                            child: Column(
                              children: [
                                CustomTextField(
                                  labelText: 'Skype',
                                  hintText: 'Enter Skype username',
                                  controller: controller.skypeController,
                                  textInputType: TextInputType.text,
                                  onChanged: (_) {},
                                ),
                                const SizedBox(height: Dimensions.space15),
                                CustomTextField(
                                  labelText: 'Facebook',
                                  hintText: 'Enter Facebook URL',
                                  controller: controller.facebookController,
                                  textInputType: TextInputType.url,
                                  onChanged: (_) {},
                                ),
                                const SizedBox(height: Dimensions.space15),
                                CustomTextField(
                                  labelText: 'LinkedIn',
                                  hintText: 'Enter LinkedIn URL',
                                  controller: controller.linkedinController,
                                  textInputType: TextInputType.url,
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.space25),
                          controller.isSubmitting
                              ? const RoundedLoadingBtn()
                              : RoundedButton(
                                  text: LocalStrings.updateProfile.tr,
                                  press: () => controller.updateProfile(),
                                  color: ColorResources.colorOrange,
                                ),
                          const SizedBox(height: Dimensions.space25),
                        ],
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
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  LocalStrings.editProfile.tr,
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
                color:
                    (isDark ? const Color(0xFF000000) : const Color(0xFFB8C6D8))
                        .withValues(alpha: 0.12),
                blurRadius: 18,
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

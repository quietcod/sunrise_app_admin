import 'dart:ui';

import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/announcement/controller/announcement_controller.dart';
import 'package:flutex_admin/features/announcement/model/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({super.key, required this.announcement});
  final Announcement announcement;

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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        LocalStrings.announcementDetails.tr,
                        style: boldLarge.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Get.find<AnnouncementController>()
                            .dismiss(announcement.id!);
                        Get.back();
                      },
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(LocalStrings.dismiss.tr),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Icon + title header card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Dimensions.space20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF59E0B)
                                      .withValues(alpha: .25),
                                  const Color(0xFFF59E0B)
                                      .withValues(alpha: .10),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: .4),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: .2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.campaign_outlined,
                                      color: Color(0xFFF59E0B), size: 30),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  announcement.name ??
                                      LocalStrings.announcements.tr,
                                  style: boldLarge.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (announcement.dateadded != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    announcement.dateadded!,
                                    style: regularSmall.copyWith(
                                        color: ColorResources.contentTextColor),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Message card
                      if (announcement.message != null &&
                          announcement.message!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF343434)
                                        : Colors.white)
                                    .withValues(alpha: .45),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (isDark
                                          ? const Color(0xFF4A5C79)
                                          : Colors.white)
                                      .withValues(alpha: .55),
                                ),
                              ),
                              child: Text(
                                announcement.message!,
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

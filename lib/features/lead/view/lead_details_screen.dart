import 'dart:ui';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/lead/widget/lead_activity.dart';
import 'package:flutex_admin/features/lead/widget/lead_attachment.dart';
import 'package:flutex_admin/features/lead/widget/lead_notes.dart';
import 'package:flutex_admin/features/lead/widget/lead_profile.dart';
import 'package:flutex_admin/features/lead/widget/lead_reminders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadDetailsScreen extends StatefulWidget {
  const LeadDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LeadRepo(apiClient: Get.find()));
    final controller = Get.put(LeadController(leadRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadLeadDetails(widget.id);
    });
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
              bottom: 160,
              right: -60,
              child: _BlurOrb(
                size: 160,
                color:
                    (isDark ? const Color(0xFF23324A) : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.2 : 0.5),
              ),
            ),
            GetBuilder<LeadController>(
              builder: (controller) {
                if (controller.isLoading ||
                    controller.leadDetailsModel.data == null) {
                  return const CustomLoader();
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                          Dimensions.space15, Dimensions.space10),
                      child: _GlassDetailHeader(
                        isDark: isDark,
                        title: LocalStrings.leadDetails.tr,
                        hasAttachments:
                            (controller.leadDetailsModel.data?.attachments ??
                                    [])
                                .isNotEmpty,
                        onDownloadAll: () =>
                            controller.downloadAllLeadAttachments(),
                        onEdit: () => Get.toNamed(RouteHelper.updateLeadScreen,
                            arguments: widget.id),
                        onConvert: () {
                          const WarningAlertDialog().warningAlertDialog(
                            context,
                            () {
                              Get.back();
                              Get.find<LeadController>()
                                  .convertToCustomer(widget.id);
                            },
                            title: LocalStrings.convertToCustomer.tr,
                            subTitle: LocalStrings.convertToCustomerMsg.tr,
                            image: MyImages.exclamationImage,
                          );
                        },
                        onDelete: () => const WarningAlertDialog()
                            .warningAlertDialog(context, () {
                          Get.back();
                          Get.find<LeadController>().deleteLead(widget.id);
                          Navigator.pop(context);
                        },
                                title: LocalStrings.deleteLead.tr,
                                subTitle: LocalStrings.deleteLeadWarningMSg.tr,
                                image: MyImages.exclamationImage),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).cardColor,
                        onRefresh: () async =>
                            controller.loadLeadDetails(widget.id),
                        child: ContainedTabBarView(
                          tabBarProperties: TabBarProperties(
                              indicatorSize: TabBarIndicatorSize.tab,
                              unselectedLabelColor:
                                  ColorResources.blueGreyColor,
                              labelColor:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              labelStyle: regularDefault,
                              indicatorColor: ColorResources.secondaryColor,
                              labelPadding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.space15)),
                          tabs: [
                            Text(LocalStrings.profile.tr),
                            Text(LocalStrings.attachments.tr),
                            const Text('Notes'),
                            const Text('Activity'),
                            const Text('Reminders'),
                          ],
                          views: [
                            LeadProfile(
                                leadModel: controller.leadDetailsModel.data!),
                            LeadAttachment(
                                leadModel: controller.leadDetailsModel.data!),
                            LeadNotes(leadId: widget.id),
                            LeadActivity(leadId: widget.id),
                            LeadReminders(leadId: widget.id),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

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

class _GlassDetailHeader extends StatelessWidget {
  const _GlassDetailHeader({
    required this.isDark,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    this.onConvert,
    this.hasAttachments = false,
    this.onDownloadAll,
  });
  final bool isDark;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onConvert;
  final bool hasAttachments;
  final VoidCallback? onDownloadAll;

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
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              if (hasAttachments && onDownloadAll != null)
                Tooltip(
                  message: 'Download all files',
                  child: IconButton(
                    onPressed: onDownloadAll,
                    icon: const Icon(Icons.download_for_offline_outlined,
                        size: 20),
                  ),
                ),
              if (onConvert != null)
                Tooltip(
                  message: LocalStrings.convertToCustomer.tr,
                  child: IconButton(
                    onPressed: onConvert,
                    icon: Icon(Icons.person_add_outlined,
                        size: 20, color: Colors.green.withValues(alpha: 0.85)),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

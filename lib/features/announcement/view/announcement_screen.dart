import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/announcement/controller/announcement_controller.dart';
import 'package:flutex_admin/features/announcement/repo/announcement_repo.dart';
import 'package:flutex_admin/features/announcement/view/announcement_details_screen.dart';
import 'package:flutex_admin/features/announcement/view/update_announcement_screen.dart';
import 'package:flutex_admin/features/announcement/widget/announcement_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => AnnouncementRepo(apiClient: Get.find()));
    Get.put(AnnouncementController(announcementRepo: Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.addAnnouncementScreen),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
        child: SafeArea(
          child: GetBuilder<AnnouncementController>(builder: (controller) {
            return Column(
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
                          LocalStrings.announcements.tr,
                          style: boldLarge.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: controller.isLoading
                      ? const CustomLoader()
                      : controller.announcementList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.campaign_outlined,
                                      size: 60,
                                      color: ColorResources.contentTextColor
                                          .withValues(alpha: .4)),
                                  const SizedBox(height: 12),
                                  Text(LocalStrings.noAnnouncements.tr,
                                      style: regularDefault.copyWith(
                                          color:
                                              ColorResources.contentTextColor)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context).cardColor,
                              onRefresh: () =>
                                  controller.initialData(shouldLoad: false),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                itemCount: controller.announcementList.length,
                                itemBuilder: (_, i) {
                                  final item = controller.announcementList[i];
                                  return AnnouncementCard(
                                    item: item,
                                    isDark: isDark,
                                    onTap: () => Get.to(() =>
                                        AnnouncementDetailsScreen(
                                            announcement: item)),
                                    onDismiss: () =>
                                        controller.dismiss(item.id!),
                                    onEdit: () => Get.to(() =>
                                        UpdateAnnouncementScreen(
                                            announcement: item)),
                                    onDelete: () => _confirmDelete(
                                        context, controller, item.id!),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AnnouncementController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAnnouncement(id);
            },
            child: Text('Delete',
                style: TextStyle(color: ColorResources.redColor)),
          ),
        ],
      ),
    );
  }
}

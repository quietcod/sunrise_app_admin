import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/staff/controller/staff_controller.dart';
import 'package:flutex_admin/features/staff/repo/staff_repo.dart';
import 'package:flutex_admin/features/staff/view/staff_details_screen.dart';
import 'package:flutex_admin/features/staff/widget/staff_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => StaffRepo(apiClient: Get.find()));
    Get.put(StaffController(staffRepo: Get.find()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        backgroundColor: ColorResources.secondaryColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add Staff',
            style: semiBoldDefault.copyWith(color: Colors.white)),
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
            SafeArea(
              child: GetBuilder<StaffController>(builder: (controller) {
                return Column(
                  children: [
                    // Glass Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: _GlassHeader(
                        isDark: isDark,
                        title: LocalStrings.staff.tr,
                        trailing: Text(
                          '${controller.filteredList.length} ${LocalStrings.staffMember.tr}',
                          style: regularSmall.copyWith(
                              color: ColorResources.contentTextColor),
                        ),
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFF343434)
                                      : Colors.white)
                                  .withValues(alpha: .45),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark
                                        ? const Color(0xFF4A5C79)
                                        : Colors.white)
                                    .withValues(alpha: .55),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: controller.search,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search ${LocalStrings.staff.tr}...',
                                hintStyle: regularDefault.copyWith(
                                    color: ColorResources.contentTextColor),
                                prefixIcon: Icon(Icons.search_rounded,
                                    color: ColorResources.contentTextColor,
                                    size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // List
                    Expanded(
                      child: controller.isLoading
                          ? const CustomLoader()
                          : controller.filteredList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline,
                                          size: 60,
                                          color: ColorResources.contentTextColor
                                              .withValues(alpha: .4)),
                                      const SizedBox(height: 12),
                                      Text(LocalStrings.noStaffFound.tr,
                                          style: regularDefault.copyWith(
                                              color: ColorResources
                                                  .contentTextColor)),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  color: Theme.of(context).primaryColor,
                                  backgroundColor: Theme.of(context).cardColor,
                                  onRefresh: () =>
                                      controller.initialData(shouldLoad: false),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    itemCount: controller.filteredList.length,
                                    itemBuilder: (_, i) {
                                      final member = controller.filteredList[i];
                                      return StaffCard(
                                        member: member,
                                        isDark: isDark,
                                        onTap: () => Get.to(() =>
                                            StaffDetailsScreen(member: member)),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final controller = Get.find<StaffController>();
    controller.clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => GetBuilder<StaffController>(builder: (c) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Add Staff', style: semiBoldLarge.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: c.firstNameController,
                  decoration: const InputDecoration(
                      labelText: 'First Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.lastNameController,
                  decoration: const InputDecoration(
                      labelText: 'Last Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.positionController,
                  decoration: const InputDecoration(
                      labelText: 'Position', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.departmentController,
                  decoration: const InputDecoration(
                      labelText: 'Department', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password *', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: c.isSubmitting
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor),
                          onPressed: () async {
                            final ok = await c.addStaff();
                            if (ok) Get.back();
                          },
                          child: Text(LocalStrings.submit.tr,
                              style: const TextStyle(color: Colors.white)),
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

class _GlassHeader extends StatelessWidget {
  const _GlassHeader(
      {required this.isDark, required this.title, this.trailing});
  final bool isDark;
  final String title;
  final Widget? trailing;

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
                        .withValues(alpha: isDark ? 0.46 : 0.55)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: boldLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 22),
                ),
              ),
              if (trailing != null) trailing!,
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

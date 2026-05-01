import 'dart:ui';

import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/staff/controller/staff_controller.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffDetailsScreen extends StatelessWidget {
  const StaffDetailsScreen({super.key, required this.member});
  final StaffMember member;

  Widget _row(BuildContext context, IconData icon, String label, String value,
      Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: regularSmall.copyWith(
                        color: ColorResources.contentTextColor, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: regularDefault.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                        LocalStrings.staffDetails.tr,
                        style: boldLarge.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditDialog(context),
                    ),
                    IconButton(
                      icon: Icon(
                        member.isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color: member.isActive ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        final controller = Get.find<StaffController>();
                        controller.changeStatus(member.id!, !member.isActive);
                      },
                      tooltip: member.isActive
                          ? LocalStrings.deactivate.tr
                          : LocalStrings.activate.tr,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        const WarningAlertDialog().warningAlertDialog(
                          context,
                          () async {
                            Get.back();
                            final controller = Get.find<StaffController>();
                            final ok = await controller.deleteStaff(member.id!);
                            if (ok) Get.back();
                          },
                          title: 'Delete Staff',
                          subTitle:
                              'Are you sure you want to delete this staff member?',
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Avatar + name hero card
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
                                  ColorResources.secondaryColor
                                      .withValues(alpha: .25),
                                  ColorResources.secondaryColor
                                      .withValues(alpha: .08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: ColorResources.secondaryColor
                                    .withValues(alpha: .35),
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: ColorResources.secondaryColor
                                      .withValues(alpha: .2),
                                  backgroundImage:
                                      member.profileImage != null &&
                                              member.profileImage!.isNotEmpty
                                          ? NetworkImage(member.profileImage!)
                                          : null,
                                  child: member.profileImage == null ||
                                          member.profileImage!.isEmpty
                                      ? Text(
                                          member.initials,
                                          style: boldLarge.copyWith(
                                              color:
                                                  ColorResources.secondaryColor,
                                              fontSize: 24),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  member.fullName,
                                  style: boldLarge.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 20,
                                  ),
                                ),
                                if (member.position != null &&
                                    member.position!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    member.position!,
                                    style: regularDefault.copyWith(
                                        color: ColorResources.contentTextColor),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: member.isActive
                                        ? ColorResources.colorGreen
                                            .withValues(alpha: .15)
                                        : ColorResources.colorGrey
                                            .withValues(alpha: .2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    member.isActive ? 'Active' : 'Inactive',
                                    style: semiBoldSmall.copyWith(
                                      color: member.isActive
                                          ? ColorResources.colorGreen
                                          : ColorResources.contentTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Details card
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (member.email != null)
                                  _row(context, Icons.email_outlined, 'Email',
                                      member.email!, const Color(0xFF4285F4)),
                                if (member.phonenumber != null &&
                                    member.phonenumber!.isNotEmpty)
                                  _row(
                                      context,
                                      Icons.phone_outlined,
                                      LocalStrings.phone.tr,
                                      member.phonenumber!,
                                      ColorResources.colorGreen),
                                if (member.department != null &&
                                    member.department!.isNotEmpty)
                                  _row(
                                      context,
                                      Icons.business_outlined,
                                      'Department',
                                      member.department!,
                                      ColorResources.secondaryColor),
                                if (member.lastLogin != null &&
                                    member.lastLogin!.isNotEmpty)
                                  _row(
                                      context,
                                      Icons.access_time_outlined,
                                      'Last Login',
                                      member.lastLogin!,
                                      const Color(0xFFF59E0B)),
                              ],
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

  void _showEditDialog(BuildContext context) {
    final controller = Get.find<StaffController>();
    controller.populateForm(member);
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
                Text('Edit Staff', style: semiBoldLarge.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: c.firstNameController,
                  decoration: const InputDecoration(
                      labelText: 'First Name', border: OutlineInputBorder()),
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
                      labelText: 'Email', border: OutlineInputBorder()),
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
                      labelText: 'New Password (optional)',
                      border: OutlineInputBorder()),
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
                            final ok = await c.updateStaff(member.id!);
                            if (ok) Get.back();
                          },
                          child: Text(LocalStrings.update.tr,
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

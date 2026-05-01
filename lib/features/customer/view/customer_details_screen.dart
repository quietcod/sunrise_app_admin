import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/extras/entity_extras_section.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutex_admin/features/customer/repo/customer_repo.dart';
import 'package:flutex_admin/features/customer/widget/customer_billing.dart';
import 'package:flutex_admin/features/customer/widget/customer_contacts.dart';
import 'package:flutex_admin/features/customer/widget/customer_profile.dart';
import 'package:flutex_admin/features/customer/widget/customer_attachments.dart';
import 'package:flutex_admin/features/customer/widget/customer_sub_resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CustomerRepo(apiClient: Get.find()));
    final controller = Get.put(CustomerController(customerRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadCustomerDetails(widget.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showMoreActions(BuildContext context, CustomerController controller) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Send Statement'),
              onTap: () {
                Navigator.pop(ctx);
                _showStatementDialog(context, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Assign to Group'),
              onTap: () {
                Navigator.pop(ctx);
                _showAssignGroupDialog(context, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Assign Admins'),
              onTap: () {
                Navigator.pop(ctx);
                _showAssignAdminsDialog(context, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatementDialog(
      BuildContext context, CustomerController controller) {
    DateTime from = DateTime.now().subtract(const Duration(days: 30));
    DateTime to = DateTime.now();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Send Customer Statement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('From'),
                subtitle: Text(
                    '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: from,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => from = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('To'),
                subtitle: Text(
                    '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: to,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => to = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final fromStr =
                    '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
                final toStr =
                    '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
                controller.sendStatement(widget.id, fromStr, toStr);
              },
              child: const Text('Send'),
            ),
          ],
        );
      }),
    );
  }

  void _showAssignGroupDialog(
      BuildContext context, CustomerController controller) async {
    await controller.loadCustomerGroups();
    final groups = controller.groupsModel.data ?? [];
    if (groups.isEmpty) {
      CustomSnackBar.error(errorList: ['No groups available']);
      return;
    }
    final selectedIds = <String>{};
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Assign to Group'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length,
              itemBuilder: (_, i) {
                final g = groups[i];
                final gId = g.id?.toString() ?? '';
                return CheckboxListTile(
                  title: Text(g.name ?? ''),
                  value: selectedIds.contains(gId),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v == true) {
                        selectedIds.add(gId);
                      } else {
                        selectedIds.remove(gId);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedIds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      controller.assignToGroup(widget.id, selectedIds.toList());
                    },
              child: const Text('Assign'),
            ),
          ],
        );
      }),
    );
  }

  void _showAssignAdminsDialog(
      BuildContext context, CustomerController controller) async {
    await controller.loadAllStaff();
    if (controller.allStaffList.isEmpty) {
      CustomSnackBar.error(errorList: ['No staff available']);
      return;
    }
    final assignedIds = controller.customerAdminsList
        .map((a) => a['staff_id']?.toString() ?? a['staffid']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Admins'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.allStaffList.length,
            itemBuilder: (_, i) {
              final staff = controller.allStaffList[i];
              final staffId =
                  staff['staffid']?.toString() ?? staff['id']?.toString() ?? '';
              final name =
                  '${staff['firstname'] ?? ''} ${staff['lastname'] ?? ''}'
                      .trim();
              final assigned = assignedIds.contains(staffId);
              return ListTile(
                title: Text(name.isNotEmpty ? name : 'Staff #$staffId'),
                trailing: assigned
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                enabled: !assigned,
                onTap: assigned
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        controller.assignCustomerAdmin(widget.id, staffId);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
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
            GetBuilder<CustomerController>(
              builder: (controller) {
                if (controller.isLoading ||
                    controller.customerDetailsModel.data == null) {
                  return const CustomLoader();
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                          Dimensions.space15, Dimensions.space10),
                      child: _GlassDetailHeader(
                        isDark: isDark,
                        title: LocalStrings.customerDetails.tr,
                        isActive:
                            controller.customerDetailsModel.data?.active == '1',
                        onEdit: () => Get.toNamed(
                            RouteHelper.updateCustomerScreen,
                            arguments: widget.id),
                        onToggleActive: () =>
                            Get.find<CustomerController>().toggleCustomerActive(
                          widget.id,
                          controller.customerDetailsModel.data?.active == '1',
                        ),
                        onDelete: () => const WarningAlertDialog()
                            .warningAlertDialog(context, () {
                          Get.back();
                          Get.find<CustomerController>()
                              .deleteCustomer(widget.id);
                          Navigator.pop(context);
                        },
                                title: LocalStrings.deleteCustomer.tr,
                                subTitle:
                                    LocalStrings.deleteCustomerWarningMSg.tr,
                                image: MyImages.exclamationImage),
                        onMore: () => _showMoreActions(context, controller),
                      ),
                    ),
                    Expanded(
                      child: DefaultTabController(
                        length: 13,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space15),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF1E2A3B)
                                        : Colors.white)
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (isDark
                                          ? const Color(0xFF2A3347)
                                          : const Color(0xFFD0DAE8))
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicatorSize: TabBarIndicatorSize.label,
                                unselectedLabelColor:
                                    ColorResources.blueGreyColor,
                                labelColor: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                labelStyle: regularDefault.copyWith(
                                    fontWeight: FontWeight.w600),
                                unselectedLabelStyle: regularDefault,
                                indicatorColor: ColorResources.secondaryColor,
                                indicatorWeight: 3,
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.space15),
                                dividerColor: Colors.transparent,
                                tabs: [
                                  Tab(text: LocalStrings.profile.tr),
                                  Tab(text: LocalStrings.billingAndShipping.tr),
                                  Tab(text: LocalStrings.contacts.tr),
                                  const Tab(text: 'Invoices'),
                                  const Tab(text: 'Tickets'),
                                  const Tab(text: 'Credit Notes'),
                                  const Tab(text: 'Subscriptions'),
                                  const Tab(text: 'Activities'),
                                  const Tab(text: 'Notes'),
                                  const Tab(text: 'Files'),
                                  const Tab(text: 'Admins'),
                                  const Tab(text: 'GDPR'),
                                  const Tab(text: 'More'),
                                ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.space5),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  CustomerProfile(
                                    customerModel:
                                        controller.customerDetailsModel.data!,
                                  ),
                                  CustomerBilling(
                                    customerModel:
                                        controller.customerDetailsModel.data!,
                                  ),
                                  CustomerContacts(
                                    id: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerInvoicesTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerTicketsTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerCreditNotesTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerSubscriptionsTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerActivitiesTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerNotesTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerAttachmentsTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerAdminsTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  CustomerGdprConsentsTab(
                                    clientId: controller
                                        .customerDetailsModel.data!.userId!,
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(
                                        Dimensions.space12),
                                    child: EntityExtrasSection(
                                      relType: 'customer',
                                      relId: controller
                                          .customerDetailsModel.data!.userId!,
                                      // activity & files already have dedicated tabs
                                      show: const {
                                        'reminders',
                                        'custom_fields'
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
  const _GlassDetailHeader(
      {required this.isDark,
      required this.title,
      required this.onEdit,
      required this.onDelete,
      this.onToggleActive,
      this.onMore,
      this.isActive});
  final bool isDark;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleActive;
  final VoidCallback? onMore;
  final bool? isActive;

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
              if (onToggleActive != null)
                Tooltip(
                  message: (isActive ?? true)
                      ? LocalStrings.deactivate.tr
                      : LocalStrings.activate.tr,
                  child: IconButton(
                    onPressed: onToggleActive,
                    icon: Icon(
                      (isActive ?? true)
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      size: 22,
                      color: (isActive ?? true)
                          ? Colors.green.withValues(alpha: 0.85)
                          : Colors.grey,
                    ),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent.withValues(alpha: 0.85)),
              ),
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

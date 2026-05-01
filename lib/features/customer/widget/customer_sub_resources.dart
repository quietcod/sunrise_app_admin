import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerInvoicesTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerInvoicesTab extends StatefulWidget {
  const CustomerInvoicesTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerInvoicesTab> createState() => _CustomerInvoicesTabState();
}

class _CustomerInvoicesTabState extends State<CustomerInvoicesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerInvoices(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerInvoicesLoading) return const CustomLoader();
      final items = controller.customerInvoicesList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async => controller.loadCustomerInvoices(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final inv = items[index];
            final id = inv['id']?.toString() ?? '';
            final number = inv['number']?.toString() ??
                inv['formatted_number']?.toString() ??
                '#$id';
            final total =
                inv['total']?.toString() ?? inv['subtotal']?.toString() ?? '';
            final status = inv['status']?.toString() ?? '';
            final dueDate =
                inv['duedate']?.toString() ?? inv['due_date']?.toString() ?? '';

            return _SubResourceCard(
              leading: const Icon(Icons.article_outlined,
                  color: Colors.blueAccent, size: 22),
              title: 'Invoice $number',
              subtitle: dueDate.isNotEmpty ? 'Due: $dueDate' : null,
              trailing: total.isNotEmpty ? '\$$total' : null,
              badge: status,
              badgeColor: ColorResources.invoiceStatusColor(status),
              onTap: id.isNotEmpty
                  ? () => Get.toNamed(RouteHelper.invoiceDetailsScreen,
                      arguments: id)
                  : null,
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerTicketsTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerTicketsTab extends StatefulWidget {
  const CustomerTicketsTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerTicketsTab> createState() => _CustomerTicketsTabState();
}

class _CustomerTicketsTabState extends State<CustomerTicketsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerTickets(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerTicketsLoading) return const CustomLoader();
      final items = controller.customerTicketsList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async => controller.loadCustomerTickets(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final t = items[index];
            final id = t['ticketid']?.toString() ?? t['id']?.toString() ?? '';
            final subject = t['subject']?.toString() ?? 'Ticket #$id';
            final status = t['status']?.toString() ?? '';
            final priority = t['priority']?.toString() ?? '';
            final lastReply =
                t['lastreply']?.toString() ?? t['last_reply']?.toString() ?? '';

            return _SubResourceCard(
              leading: const Icon(Icons.confirmation_number_outlined,
                  color: Colors.orangeAccent, size: 22),
              title: subject,
              subtitle: lastReply.isNotEmpty ? 'Last reply: $lastReply' : null,
              trailing: priority.isNotEmpty ? priority : null,
              badge: status,
              badgeColor: ColorResources.ticketStatusColor(status),
              onTap: id.isNotEmpty
                  ? () => Get.toNamed(RouteHelper.ticketDetailsScreen,
                      arguments: id)
                  : null,
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared private card
// ─────────────────────────────────────────────────────────────────────────────

class _SubResourceCard extends StatelessWidget {
  const _SubResourceCard({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingWidget,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget? trailingWidget;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space12),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
              .withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
                .withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: Dimensions.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: regularDefault.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: regularSmall.copyWith(
                            color: ColorResources.blueGreyColor, fontSize: 11)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badge != null && badge!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? Colors.blueGrey)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (badgeColor ?? Colors.blueGrey)
                              .withValues(alpha: 0.5)),
                    ),
                    child: Text(badge!,
                        style: TextStyle(
                            fontSize: 10,
                            color: badgeColor ?? Colors.blueGrey,
                            fontWeight: FontWeight.w600)),
                  ),
                if (trailing != null) ...[
                  const SizedBox(height: 4),
                  Text(trailing!,
                      style: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor, fontSize: 12)),
                ],
                if (trailingWidget != null) ...[
                  const SizedBox(height: 4),
                  trailingWidget!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerNotesTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerNotesTab extends StatefulWidget {
  const CustomerNotesTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerNotesTab> createState() => _CustomerNotesTabState();
}

class _CustomerNotesTabState extends State<CustomerNotesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerNotes(widget.clientId);
    });
  }

  void _showAddNoteDialog(CustomerController controller) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter note…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = noteController.text.trim();
              if (text.isEmpty) {
                CustomSnackBar.error(errorList: ['Note cannot be empty']);
                return;
              }
              Navigator.pop(ctx);
              controller.addCustomerNote(widget.clientId, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'customer_note_fab',
          onPressed: () => _showAddNoteDialog(controller),
          child: const Icon(Icons.add),
        ),
        body: controller.isCustomerNotesLoading
            ? const CustomLoader()
            : controller.customerNotesList.isEmpty
                ? const Center(child: NoDataWidget())
                : RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    onRefresh: () async =>
                        controller.loadCustomerNotes(widget.clientId),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space15,
                          vertical: Dimensions.space10),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.customerNotesList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, index) {
                        final note = controller.customerNotesList[index];
                        final noteId = note['id']?.toString() ?? '';
                        final description =
                            note['description']?.toString() ?? '';
                        final dateAdded = note['dateadded']?.toString() ?? '';

                        return _SubResourceCard(
                          leading: const Icon(Icons.sticky_note_2_outlined,
                              color: Colors.amber, size: 22),
                          title: description,
                          subtitle:
                              dateAdded.isNotEmpty ? 'Added: $dateAdded' : null,
                          onTap: noteId.isNotEmpty
                              ? () => showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Note'),
                                      content: const Text(
                                          'Are you sure you want to delete this note?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            controller.deleteCustomerNote(
                                                widget.clientId, noteId);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  )
                              : null,
                        );
                      },
                    ),
                  ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerCreditNotesTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerCreditNotesTab extends StatefulWidget {
  const CustomerCreditNotesTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerCreditNotesTab> createState() => _CustomerCreditNotesTabState();
}

class _CustomerCreditNotesTabState extends State<CustomerCreditNotesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerCreditNotes(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerCreditNotesLoading) return const CustomLoader();
      final items = controller.customerCreditNotesList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async =>
            controller.loadCustomerCreditNotes(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final cn = items[index];
            final id = cn['id']?.toString() ?? '';
            final number = cn['credit_note_number']?.toString() ??
                cn['number']?.toString() ??
                '#$id';
            final total = cn['total']?.toString() ?? '';
            final status = cn['status']?.toString() ?? '';
            final date = cn['date']?.toString() ?? '';

            return _SubResourceCard(
              leading: const Icon(Icons.receipt_long_outlined,
                  color: Colors.teal, size: 22),
              title: 'Credit Note $number',
              subtitle: date.isNotEmpty ? 'Date: $date' : null,
              trailing: total.isNotEmpty ? '\$$total' : null,
              badge: status,
              badgeColor: ColorResources.invoiceStatusColor(status),
              onTap: id.isNotEmpty
                  ? () => Get.toNamed(RouteHelper.creditNoteDetailsScreen,
                      arguments: id)
                  : null,
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerActivitiesTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerActivitiesTab extends StatefulWidget {
  const CustomerActivitiesTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerActivitiesTab> createState() => _CustomerActivitiesTabState();
}

class _CustomerActivitiesTabState extends State<CustomerActivitiesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerActivities(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerActivitiesLoading) return const CustomLoader();
      final items = controller.customerActivitiesList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async =>
            controller.loadCustomerActivities(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final act = items[index];
            final description = act['description']?.toString() ??
                act['activity']?.toString() ??
                'Activity';
            final date =
                act['date']?.toString() ?? act['dateadded']?.toString() ?? '';

            return _SubResourceCard(
              leading: const Icon(Icons.history,
                  color: Colors.purpleAccent, size: 22),
              title: description,
              subtitle: date.isNotEmpty ? date : null,
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerSubscriptionsTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerSubscriptionsTab extends StatefulWidget {
  const CustomerSubscriptionsTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerSubscriptionsTab> createState() =>
      _CustomerSubscriptionsTabState();
}

class _CustomerSubscriptionsTabState extends State<CustomerSubscriptionsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerSubscriptions(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerSubscriptionsLoading) {
        return const CustomLoader();
      }
      final items = controller.customerSubscriptionsList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async =>
            controller.loadCustomerSubscriptions(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final sub = items[index];
            final id = sub['id']?.toString() ?? '';
            final name = sub['name']?.toString() ?? 'Subscription #$id';
            final status = sub['status']?.toString() ?? '';
            final amount = sub['amount']?.toString() ?? '';
            final nextBilling = sub['next_billing_cycle']?.toString() ??
                sub['date_subscribed']?.toString() ??
                '';

            String statusLabel;
            Color statusColor;
            switch (status) {
              case '1':
                statusLabel = 'Active';
                statusColor = Colors.green;
                break;
              case '2':
                statusLabel = 'Cancelled';
                statusColor = Colors.red;
                break;
              default:
                statusLabel = 'Inactive';
                statusColor = Colors.grey;
            }

            return _SubResourceCard(
              leading: const Icon(Icons.autorenew_rounded,
                  color: Colors.deepPurple, size: 22),
              title: name,
              subtitle:
                  nextBilling.isNotEmpty ? 'Next billing: $nextBilling' : null,
              trailing: amount.isNotEmpty ? '\$$amount' : null,
              badge: statusLabel,
              badgeColor: statusColor,
              onTap: null,
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerAdminsTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerAdminsTab extends StatefulWidget {
  const CustomerAdminsTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerAdminsTab> createState() => _CustomerAdminsTabState();
}

class _CustomerAdminsTabState extends State<CustomerAdminsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerAdmins(widget.clientId);
    });
  }

  void _showAddAdminDialog(CustomerController controller) {
    final assignedIds = controller.customerAdminsList
        .map((a) => a['staff_id']?.toString() ?? a['staffid']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Admin'),
        content: controller.allStaffList.isEmpty
            ? const Text('No staff available.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.allStaffList.length,
                  itemBuilder: (ctx, i) {
                    final staff = controller.allStaffList[i];
                    final staffId = staff['staffid']?.toString() ??
                        staff['id']?.toString() ??
                        '';
                    final name =
                        '${staff['firstname'] ?? ''} ${staff['lastname'] ?? ''}'
                            .trim();
                    final alreadyAssigned = assignedIds.contains(staffId);
                    return ListTile(
                      title: Text(name.isNotEmpty ? name : 'Staff #$staffId'),
                      trailing: alreadyAssigned
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      enabled: !alreadyAssigned,
                      onTap: alreadyAssigned
                          ? null
                          : () {
                              Navigator.pop(context);
                              controller.assignCustomerAdmin(
                                  widget.clientId, staffId);
                            },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerAdminsLoading) return const CustomLoader();
      final items = controller.customerAdminsList;

      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () async {
            await controller.loadAllStaff();
            if (context.mounted) _showAddAdminDialog(controller);
          },
          child: const Icon(Icons.add),
        ),
        body: items.isEmpty
            ? const Center(child: NoDataWidget())
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async =>
                    controller.loadCustomerAdmins(widget.clientId),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space15,
                      vertical: Dimensions.space10),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Dimensions.space10),
                  itemBuilder: (context, index) {
                    final admin = items[index];
                    final name = admin['full_name']?.toString() ??
                        '${admin['firstname'] ?? ''} ${admin['lastname'] ?? ''}'
                            .trim();
                    final email = admin['email']?.toString() ?? '';
                    final staffId = admin['staff_id']?.toString() ??
                        admin['staffid']?.toString() ??
                        '';

                    return _SubResourceCard(
                      leading: const Icon(Icons.admin_panel_settings,
                          color: Colors.indigo, size: 22),
                      title: name.isNotEmpty ? name : 'Staff #$staffId',
                      subtitle: email.isNotEmpty ? email : null,
                      trailingWidget: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        tooltip: 'Remove admin',
                        onPressed: () => controller.removeCustomerAdmin(
                            widget.clientId, staffId),
                      ),
                    );
                  },
                ),
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomerGdprConsentsTab
// ─────────────────────────────────────────────────────────────────────────────

class CustomerGdprConsentsTab extends StatefulWidget {
  const CustomerGdprConsentsTab({super.key, required this.clientId});
  final String clientId;

  @override
  State<CustomerGdprConsentsTab> createState() =>
      _CustomerGdprConsentsTabState();
}

class _CustomerGdprConsentsTabState extends State<CustomerGdprConsentsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadCustomerGdprConsents(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      if (controller.isCustomerGdprConsentsLoading) {
        return const CustomLoader();
      }
      final items = controller.customerGdprConsentsList;
      if (items.isEmpty) return const Center(child: NoDataWidget());

      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async =>
            controller.loadCustomerGdprConsents(widget.clientId),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: Dimensions.space10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) {
            final consent = items[index];
            final purpose = consent['purpose_name']?.toString() ??
                consent['purpose']?.toString() ??
                'Consent #${consent['id']}';
            final action = consent['action']?.toString() ??
                consent['status']?.toString() ??
                '';
            final date = consent['created']?.toString() ??
                consent['dateadded']?.toString() ??
                consent['date']?.toString() ??
                '';
            final contactEmail = consent['contact_email']?.toString() ?? '';

            final isOptIn = action == 'opted_in' ||
                action == 'optin' ||
                action == '1' ||
                action == 'yes';
            final statusLabel = isOptIn ? 'Opted In' : 'Opted Out';
            final statusColor = isOptIn ? Colors.green : Colors.red;

            return _SubResourceCard(
              leading: Icon(
                isOptIn
                    ? Icons.verified_user_rounded
                    : Icons.no_accounts_rounded,
                color: statusColor,
                size: 22,
              ),
              title: purpose,
              subtitle: contactEmail.isNotEmpty
                  ? contactEmail
                  : date.isNotEmpty
                      ? date
                      : null,
              badge: statusLabel,
              badgeColor: statusColor,
            );
          },
        ),
      );
    });
  }
}

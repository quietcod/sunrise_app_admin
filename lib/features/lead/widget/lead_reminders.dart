import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadReminders extends StatefulWidget {
  const LeadReminders({super.key, required this.leadId});
  final String leadId;

  @override
  State<LeadReminders> createState() => _LeadRemindersState();
}

class _LeadRemindersState extends State<LeadReminders> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<LeadController>();
      c.loadLeadReminders(widget.leadId);
      c.loadAllStaff();
    });
  }

  void _showAddReminderDialog(
      BuildContext context, LeadController controller) async {
    DateTime? reminderDate;
    final descCtrl = TextEditingController();
    String? selectedStaffId;

    final staffList = await controller.loadAllStaff();
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) {
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm),
                  title: Text(reminderDate == null
                      ? 'Select date & time'
                      : '${reminderDate!.year}-${reminderDate!.month.toString().padLeft(2, '0')}-${reminderDate!.day.toString().padLeft(2, '0')} '
                          '${reminderDate!.hour.toString().padLeft(2, '0')}:${reminderDate!.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    final d = await showDatePicker(
                        context: ctx,
                        initialDate:
                            DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)));
                    if (d == null) return;
                    if (!ctx.mounted) return;
                    final t = await showTimePicker(
                        context: ctx, initialTime: TimeOfDay.now());
                    if (t == null) return;
                    setDlgState(() {
                      reminderDate =
                          DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    });
                  },
                ),
                const SizedBox(height: Dimensions.space10),
                if (staffList.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Notify staff',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    // ignore: deprecated_member_use
                    value: selectedStaffId,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('— Self —')),
                      ...staffList.map((s) => DropdownMenuItem(
                            value: s.id?.toString() ?? '',
                            child: Text(
                                '${s.firstname ?? ''} ${s.lastname ?? ''}'
                                    .trim()),
                          )),
                    ],
                    onChanged: (v) => setDlgState(() => selectedStaffId = v),
                  ),
                const SizedBox(height: Dimensions.space10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (reminderDate == null) return;
                Navigator.pop(ctx);
                controller.addLeadReminder(
                  widget.leadId,
                  reminderDate!.toIso8601String(),
                  descCtrl.text.trim(),
                  selectedStaffId ?? '',
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(builder: (controller) {
      if (controller.isRemindersLoading) return const CustomLoader();
      final items = controller.leadRemindersList;

      return Stack(
        children: [
          items.isEmpty
              ? RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async =>
                      controller.loadLeadReminders(widget.leadId),
                  child: ListView(
                    children: const [
                      SizedBox(height: 60),
                      Center(child: NoDataWidget()),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async =>
                      controller.loadLeadReminders(widget.leadId),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(Dimensions.space15,
                        Dimensions.space10, Dimensions.space15, 72),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space8),
                    itemBuilder: (context, index) {
                      final reminder = items[index];
                      final remId = reminder['id']?.toString() ?? '';
                      final date = reminder['date']?.toString() ?? '';
                      final desc = reminder['description']?.toString() ?? '';
                      final firstName = reminder['firstname']?.toString() ?? '';
                      final lastName = reminder['lastname']?.toString() ?? '';
                      final staffName = '$firstName $lastName'.trim().isNotEmpty
                          ? '$firstName $lastName'.trim()
                          : 'Staff';
                      final isNotified =
                          reminder['isnotified']?.toString() == '1';

                      return Container(
                        padding: const EdgeInsets.all(Dimensions.space12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isNotified
                                  ? Icons.notifications_off_outlined
                                  : Icons.notifications_active_outlined,
                              color: isNotified
                                  ? ColorResources.blueGreyColor
                                  : Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(date,
                                      style: regularDefault.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text('Notify: $staffName',
                                      style: regularSmall.copyWith(
                                          color: ColorResources.blueGreyColor,
                                          fontSize: 11)),
                                  if (desc.isNotEmpty)
                                    Text(desc,
                                        style: regularSmall.copyWith(
                                            color: ColorResources.blueGreyColor,
                                            fontSize: 11)),
                                ],
                              ),
                            ),
                            if (remId.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 18,
                                    color: Colors.redAccent
                                        .withValues(alpha: 0.8)),
                                onPressed: () => controller.deleteLeadReminder(
                                    widget.leadId, remId),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          Positioned(
            bottom: Dimensions.space15,
            right: Dimensions.space15,
            child: FloatingActionButton.extended(
              heroTag: 'lead_reminder_fab',
              onPressed: () => _showAddReminderDialog(context, controller),
              icon: const Icon(Icons.add_alarm_outlined),
              label: const Text('Add Reminder'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    });
  }
}

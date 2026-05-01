import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/controllers/generic_extras_controller.dart';
import 'package:flutex_admin/common/repo/generic_extras_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Drop-in section widget that renders four expandable panels (Reminders /
/// Activity Log / Custom Fields / Files) for any entity in the system.
///
/// Usage:
///   EntityExtrasSection(relType: 'invoice', relId: '42')
///
/// Supported [relType] values: invoice, estimate, proposal, contract,
/// credit_note, expense, project, task, lead, customer, ticket, subscription.
class EntityExtrasSection extends StatefulWidget {
  const EntityExtrasSection({
    super.key,
    required this.relType,
    required this.relId,
    this.show = const {'reminders', 'activity', 'custom_fields', 'files'},
  });

  final String relType;
  final String relId;
  final Set<String> show;

  @override
  State<EntityExtrasSection> createState() => _EntityExtrasSectionState();
}

class _EntityExtrasSectionState extends State<EntityExtrasSection> {
  late final String _tag;
  late final GenericExtrasController _c;

  @override
  void initState() {
    super.initState();
    _tag = GenericExtrasController.tagFor(widget.relType, widget.relId);
    if (!Get.isRegistered<GenericExtrasController>(tag: _tag)) {
      final api = Get.find<ApiClient>();
      Get.put<GenericExtrasController>(
        GenericExtrasController(
          repo: GenericExtrasRepo(apiClient: api),
          apiClient: api,
          relType: widget.relType,
          relId: widget.relId,
        ),
        tag: _tag,
      );
    }
    _c = Get.find<GenericExtrasController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.show.contains('reminders'))
          _ExtrasPanel(
            icon: Icons.alarm_outlined,
            title: 'Reminders',
            onExpand: _c.loadReminders,
            child: _RemindersSection(c: _c),
          ),
        if (widget.show.contains('activity'))
          _ExtrasPanel(
            icon: Icons.history_outlined,
            title: 'Activity Log',
            onExpand: _c.loadActivity,
            child: _ActivitySection(c: _c),
          ),
        if (widget.show.contains('custom_fields'))
          _ExtrasPanel(
            icon: Icons.dashboard_customize_outlined,
            title: 'Custom Fields',
            onExpand: _c.loadCustomFields,
            child: _CustomFieldsSection(c: _c),
          ),
        if (widget.show.contains('files'))
          _ExtrasPanel(
            icon: Icons.attach_file_outlined,
            title: 'Files',
            onExpand: _c.loadAttachments,
            child: _AttachmentsSection(c: _c),
          ),
      ],
    );
  }
}

// ── Panel scaffold (collapsible card) ──────────────────────────────────────
class _ExtrasPanel extends StatefulWidget {
  const _ExtrasPanel({
    required this.icon,
    required this.title,
    required this.child,
    required this.onExpand,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Future<void> Function() onExpand;

  @override
  State<_ExtrasPanel> createState() => _ExtrasPanelState();
}

class _ExtrasPanelState extends State<_ExtrasPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
            .withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              setState(() => _expanded = !_expanded);
              if (_expanded) await widget.onExpand();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space15, vertical: Dimensions.space12),
              child: Row(
                children: [
                  Icon(widget.icon,
                      color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: Dimensions.space10),
                  Expanded(
                    child: Text(widget.title,
                        style: semiBoldDefault.copyWith(fontSize: 14)),
                  ),
                  Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ColorResources.blueGreyColor),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(Dimensions.space15, 0,
                  Dimensions.space15, Dimensions.space15),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

// ── Reminders ──────────────────────────────────────────────────────────────
class _RemindersSection extends StatelessWidget {
  const _RemindersSection({required this.c});
  final GenericExtrasController c;

  void _showAdd(BuildContext context) async {
    DateTime? when;
    final descCtrl = TextEditingController();
    String? notify;
    final staff = await c.loadStaff();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm),
                  title: Text(when == null
                      ? 'Select date & time'
                      : when.toString().substring(0, 16)),
                  onTap: () async {
                    final d = await showDatePicker(
                        context: ctx,
                        initialDate:
                            DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 730)));
                    if (d == null || !ctx.mounted) return;
                    final t = await showTimePicker(
                        context: ctx, initialTime: TimeOfDay.now());
                    if (t == null) return;
                    setS(() => when =
                        DateTime(d.year, d.month, d.day, t.hour, t.minute));
                  },
                ),
                const SizedBox(height: 8),
                if (staff.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Notify staff',
                        border: OutlineInputBorder(),
                        isDense: true),
                    initialValue: notify,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('— Self —')),
                      ...staff.map((s) => DropdownMenuItem(
                            value: s.id?.toString() ?? '',
                            child: Text(
                                '${s.firstname ?? ''} ${s.lastname ?? ''}'
                                    .trim()),
                          )),
                    ],
                    onChanged: (v) => setS(() => notify = v),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                      isDense: true),
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
                if (when == null) return;
                Navigator.pop(ctx);
                c.addReminder(
                  date: when!.toIso8601String(),
                  description: descCtrl.text.trim(),
                  notifyStaff: notify,
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
    return GetBuilder<GenericExtrasController>(
      tag: '${c.relType}:${c.relId}',
      builder: (_) {
        if (c.isRemindersLoading) {
          return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (c.reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No reminders',
                    textAlign: TextAlign.center,
                    style: regularDefault.copyWith(
                        color: ColorResources.blueGreyColor)),
              )
            else
              ...c.reminders.map((r) {
                final isNotified = r['isnotified']?.toString() == '1';
                final staff =
                    '${r['firstname'] ?? ''} ${r['lastname'] ?? ''}'.trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                          isNotified
                              ? Icons.notifications_off_outlined
                              : Icons.notifications_active_outlined,
                          size: 20,
                          color: isNotified
                              ? ColorResources.blueGreyColor
                              : Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['date']?.toString() ?? '',
                                style: regularDefault.copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 12)),
                            if (staff.isNotEmpty)
                              Text('Notify: $staff',
                                  style: regularSmall.copyWith(
                                      color: ColorResources.blueGreyColor,
                                      fontSize: 11)),
                            if ((r['description']?.toString() ?? '').isNotEmpty)
                              Text(r['description'].toString(),
                                  style: regularSmall.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        onPressed: () => c.deleteReminder(r['id'].toString()),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showAdd(context),
                icon: const Icon(Icons.add_alarm_outlined, size: 18),
                label: const Text('Add Reminder'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Activity ───────────────────────────────────────────────────────────────
class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.c});
  final GenericExtrasController c;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GenericExtrasController>(
      tag: '${c.relType}:${c.relId}',
      builder: (_) {
        if (c.isActivityLoading) {
          return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()));
        }
        if (c.activity.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No activity',
                textAlign: TextAlign.center,
                style: regularDefault.copyWith(
                    color: ColorResources.blueGreyColor)),
          );
        }
        return Column(
          children: c.activity.map((a) {
            final desc = a['description']?.toString() ?? '';
            final date = a['date']?.toString() ?? '';
            final staff = a['staff_name']?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc,
                            style: regularDefault.copyWith(fontSize: 12)),
                        Text(
                          [date, staff].where((s) => s.isNotEmpty).join(' • '),
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Custom fields ──────────────────────────────────────────────────────────
class _CustomFieldsSection extends StatefulWidget {
  const _CustomFieldsSection({required this.c});
  final GenericExtrasController c;

  @override
  State<_CustomFieldsSection> createState() => _CustomFieldsSectionState();
}

class _CustomFieldsSectionState extends State<_CustomFieldsSection> {
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, String> _values = {};

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String id, String initial) {
    return _ctrls.putIfAbsent(id, () => TextEditingController(text: initial));
  }

  Widget _fieldFor(Map<String, dynamic> f) {
    final id = f['id'].toString();
    final type = (f['type'] ?? 'input').toString();
    final name = (f['name'] ?? '').toString();
    final value = (f['value'] ?? '').toString();
    final options = (f['options'] ?? '').toString();
    final opts = options.isEmpty
        ? <String>[]
        : options.split(',').map((s) => s.trim()).toList();

    Widget input;
    switch (type) {
      case 'textarea':
        input = TextField(
          controller: _ctrl(id, value),
          maxLines: 3,
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
          onChanged: (v) => _values[id] = v,
        );
        break;
      case 'select':
        _values[id] = value;
        input = DropdownButtonFormField<String>(
          initialValue: opts.contains(value) ? value : null,
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem(value: '', child: Text('—')),
            ...opts.map((o) => DropdownMenuItem(value: o, child: Text(o))),
          ],
          onChanged: (v) => setState(() => _values[id] = v ?? ''),
        );
        break;
      case 'checkbox':
        final selected = value.split(',').map((s) => s.trim()).toSet();
        _values[id] = selected.join(',');
        input = Wrap(
          spacing: 6,
          children: opts
              .map((o) => FilterChip(
                    label: Text(o),
                    selected: selected.contains(o),
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          selected.add(o);
                        } else {
                          selected.remove(o);
                        }
                        _values[id] = selected.join(',');
                      });
                    },
                  ))
              .toList(),
        );
        break;
      case 'date':
      case 'date_picker':
        final ctrl = _ctrl(id, value);
        input = TextField(
          controller: ctrl,
          readOnly: true,
          decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today, size: 16)),
          onTap: () async {
            final d = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime(2100));
            if (d != null) {
              final s = d.toIso8601String().substring(0, 10);
              ctrl.text = s;
              _values[id] = s;
            }
          },
        );
        break;
      case 'number':
        input = TextField(
          controller: _ctrl(id, value),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
          onChanged: (v) => _values[id] = v,
        );
        break;
      default:
        input = TextField(
          controller: _ctrl(id, value),
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
          onChanged: (v) => _values[id] = v,
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: regularDefault.copyWith(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          input,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return GetBuilder<GenericExtrasController>(
      tag: '${c.relType}:${c.relId}',
      builder: (_) {
        if (c.isCustomFieldsLoading) {
          return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()));
        }
        if (c.customFields.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No custom fields configured',
                textAlign: TextAlign.center,
                style: regularDefault.copyWith(
                    color: ColorResources.blueGreyColor)),
          );
        }
        // ensure initial values are seeded
        for (final f in c.customFields) {
          final id = f['id'].toString();
          _values.putIfAbsent(id, () => (f['value'] ?? '').toString());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...c.customFields.map(_fieldFor),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: c.isSubmitting
                    ? null
                    : () =>
                        c.saveCustomFields(Map<String, String>.from(_values)),
                icon: c.isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Attachments / Files ────────────────────────────────────────────────────
class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({required this.c});
  final GenericExtrasController c;

  IconData _iconFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(ext)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart_outlined;
    if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(ext)) {
      return Icons.image_outlined;
    }
    if (['zip', 'rar', '7z'].contains(ext)) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackBar.error(errorList: ['Could not open file']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GenericExtrasController>(
      tag: '${c.relType}:${c.relId}',
      builder: (_) {
        if (c.isAttachmentsLoading) {
          return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (c.attachments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No files',
                    textAlign: TextAlign.center,
                    style: regularDefault.copyWith(
                        color: ColorResources.blueGreyColor)),
              )
            else
              ...c.attachments.map((a) {
                final name = a['file_name']?.toString() ?? '';
                final url = a['file_url']?.toString() ?? '';
                final date = a['dateadded']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(_iconFor(name),
                          color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _open(url),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: regularDefault.copyWith(
                                      fontSize: 12,
                                      decoration: TextDecoration.underline)),
                              if (date.isNotEmpty)
                                Text(date,
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor,
                                        fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        onPressed: () => c.deleteAttachment(a['id'].toString()),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: c.isSubmitting ? null : c.pickAndUploadAttachment,
                icon: c.isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file_outlined, size: 18),
                label: const Text('Upload File'),
              ),
            ),
          ],
        );
      },
    );
  }
}

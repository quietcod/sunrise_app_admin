import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/features/ticket/repo/ticket_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketSpamFiltersScreen extends StatefulWidget {
  const TicketSpamFiltersScreen({super.key});

  @override
  State<TicketSpamFiltersScreen> createState() =>
      _TicketSpamFiltersScreenState();
}

class _TicketSpamFiltersScreenState extends State<TicketSpamFiltersScreen> {
  static const _types = <String, String>{
    'sender': 'Sender Email',
    'subject': 'Subject Contains',
    'phrase': 'Body Phrase',
  };

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TicketRepo(apiClient: Get.find()));
    final controller = Get.put(TicketController(ticketRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSpamFiltersAdmin();
    });
  }

  void _showDialog({Map<String, dynamic>? existing}) {
    String type = existing?['type']?.toString() ?? 'sender';
    final valueCtrl =
        TextEditingController(text: existing?['value']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title:
              Text(existing == null ? 'Add Spam Filter' : 'Edit Spam Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Filter Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _types.entries
                    .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setLocal(() => type = v ?? 'sender'),
              ),
              const SizedBox(height: Dimensions.space12),
              TextField(
                controller: valueCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: type == 'sender'
                      ? 'Email address'
                      : type == 'subject'
                          ? 'Subject keyword'
                          : 'Body phrase',
                  hintText: type == 'sender'
                      ? 'spammer@example.com'
                      : type == 'subject'
                          ? 'lottery'
                          : 'click here to win',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final value = valueCtrl.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(ctx);
                final c = Get.find<TicketController>();
                if (existing == null) {
                  c.addSpamFilter(type, value);
                } else {
                  c.editSpamFilter(
                      existing['id']?.toString() ?? '', type, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Spam Filter'),
        content: Text('Delete "${item['value']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<TicketController>()
                  .deleteSpamFilter(item['id']?.toString() ?? '');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'sender':
        return Icons.alternate_email_rounded;
      case 'subject':
        return Icons.subject_rounded;
      case 'phrase':
        return Icons.short_text_rounded;
      default:
        return Icons.block_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'sender':
        return Colors.redAccent;
      case 'subject':
        return Colors.deepOrangeAccent;
      case 'phrase':
        return Colors.purpleAccent;
      default:
        return ColorResources.blueGreyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spam Filters'),
        backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A2332),
        elevation: 0,
      ),
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: GetBuilder<TicketController>(builder: (controller) {
        if (controller.isSpamFiltersAdminLoading) return const CustomLoader();
        final items = controller.spamFiltersAdminList;
        if (items.isEmpty) {
          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async => controller.loadSpamFiltersAdmin(),
            child: ListView(children: const [
              SizedBox(height: 60),
              Center(child: NoDataWidget()),
              SizedBox(height: 12),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Spam filters block incoming ticket emails by sender, subject keyword or body phrase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ]),
          );
        }
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadSpamFiltersAdmin(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space8),
            itemBuilder: (context, index) {
              final item = items[index];
              final type = item['type']?.toString() ?? '';
              final value = item['value']?.toString() ?? '';
              final accent = _colorFor(type);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2332).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A3347).withValues(alpha: 0.5)
                        : const Color(0xFFD0DAE8).withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconFor(type), size: 16, color: accent),
                    ),
                    const SizedBox(width: Dimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value, style: regularDefault),
                          const SizedBox(height: 2),
                          Text(
                            _types[type] ?? type,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: ColorResources.blueGreyColor,
                      onPressed: () => _showDialog(existing: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.redAccent,
                      onPressed: () => _confirmDelete(item),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

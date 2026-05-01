import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadSourcesScreen extends StatefulWidget {
  const LeadSourcesScreen({super.key});

  @override
  State<LeadSourcesScreen> createState() => _LeadSourcesScreenState();
}

class _LeadSourcesScreenState extends State<LeadSourcesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LeadRepo(apiClient: Get.find()));
    final controller = Get.put(LeadController(leadRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadLeadSourcesAdmin();
    });
  }

  void _showDialog({Map<String, dynamic>? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?['lead_source']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Source' : 'Edit Source'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Source name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final c = Get.find<LeadController>();
              if (existing == null) {
                c.addLeadSource(name);
              } else {
                c.editLeadSource(existing['id']?.toString() ?? '', name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> source) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Source'),
        content:
            Text('Delete "${source['lead_source']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<LeadController>()
                  .deleteLeadSourceAdmin(source['id']?.toString() ?? '');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Sources'),
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
      body: GetBuilder<LeadController>(builder: (controller) {
        if (controller.isSourcesAdminLoading) return const CustomLoader();

        final items = controller.leadSourcesAdminList;
        if (items.isEmpty) {
          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async => controller.loadLeadSourcesAdmin(),
            child: ListView(
              children: const [
                SizedBox(height: 60),
                Center(child: NoDataWidget()),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadLeadSourcesAdmin(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space8),
            itemBuilder: (context, index) {
              final source = items[index];
              final name = source['lead_source']?.toString() ?? '';
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
                        color: ColorResources.secondaryColor
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.source_outlined,
                          size: 16, color: ColorResources.secondaryColor),
                    ),
                    const SizedBox(width: Dimensions.space12),
                    Expanded(child: Text(name, style: regularDefault)),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: ColorResources.blueGreyColor,
                      onPressed: () => _showDialog(existing: source),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.redAccent,
                      onPressed: () => _confirmDelete(source),
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

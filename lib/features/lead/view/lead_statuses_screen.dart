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

class LeadStatusesScreen extends StatefulWidget {
  const LeadStatusesScreen({super.key});

  @override
  State<LeadStatusesScreen> createState() => _LeadStatusesScreenState();
}

class _LeadStatusesScreenState extends State<LeadStatusesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LeadRepo(apiClient: Get.find()));
    final controller = Get.put(LeadController(leadRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadLeadStatusesAdmin();
    });
  }

  static const List<Color> _presetColors = [
    Color(0xFF3498db),
    Color(0xFF2ecc71),
    Color(0xFFe74c3c),
    Color(0xFFf39c12),
    Color(0xFF9b59b6),
    Color(0xFF1abc9c),
    Color(0xFFe67e22),
    Color(0xFF34495e),
    Color(0xFFe91e63),
    Color(0xFF607d8b),
    Color(0xFF795548),
    Color(0xFF009688),
  ];

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF3498db);
    final cleaned = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return const Color(0xFF3498db);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showDialog({Map<String, dynamic>? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?['name']?.toString() ?? '');
    Color selectedColor = _parseColor(existing?['color']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Status' : 'Edit Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Status name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: Dimensions.space15),
                Text('Color', style: regularDefault),
                const SizedBox(height: Dimensions.space8),
                Wrap(
                  spacing: Dimensions.space8,
                  runSpacing: Dimensions.space8,
                  children: _presetColors.map((c) {
                    final isSelected = selectedColor.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () => setDlgState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: c.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
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
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                final c = Get.find<LeadController>();
                final colorHex = _colorToHex(selectedColor);
                if (existing == null) {
                  c.addLeadStatus(name, colorHex);
                } else {
                  c.editLeadStatus(
                      existing['id']?.toString() ?? '', name, colorHex);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  void _confirmDelete(Map<String, dynamic> status) {
    final isDefault = status['isdefault']?.toString() == '1';
    if (isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the default status.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Status'),
        content: Text('Delete "${status['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<LeadController>()
                  .deleteLeadStatusAdmin(status['id']?.toString() ?? '');
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
        title: const Text('Lead Statuses'),
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
        if (controller.isStatusesAdminLoading) return const CustomLoader();

        final items = controller.leadStatusesAdminList;
        if (items.isEmpty) {
          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async => controller.loadLeadStatusesAdmin(),
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
          onRefresh: () async => controller.loadLeadStatusesAdmin(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space8),
            itemBuilder: (context, index) {
              final status = items[index];
              final name = status['name']?.toString() ?? '';
              final color = _parseColor(status['color']?.toString());
              final isDefault = status['isdefault']?.toString() == '1';

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
                      width: 20,
                      height: 20,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: Dimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: regularDefault),
                          if (isDefault)
                            Text('Default',
                                style: regularSmall.copyWith(
                                    color: ColorResources.blueGreyColor,
                                    fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: ColorResources.blueGreyColor,
                      onPressed: () => _showDialog(existing: status),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: isDefault
                          ? ColorResources.blueGreyColor.withValues(alpha: 0.3)
                          : Colors.redAccent,
                      onPressed:
                          isDefault ? null : () => _confirmDelete(status),
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

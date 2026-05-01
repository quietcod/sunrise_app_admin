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

class TicketServicesScreen extends StatefulWidget {
  const TicketServicesScreen({super.key});

  @override
  State<TicketServicesScreen> createState() => _TicketServicesScreenState();
}

class _TicketServicesScreenState extends State<TicketServicesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TicketRepo(apiClient: Get.find()));
    final controller = Get.put(TicketController(ticketRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadServicesAdmin();
    });
  }

  void _showDialog({Map<String, dynamic>? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?['name']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Service' : 'Edit Service'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Service name',
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
              final c = Get.find<TicketController>();
              if (existing == null) {
                c.addService(name);
              } else {
                c.editService(existing['serviceid']?.toString() ?? '', name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Delete "${item['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<TicketController>()
                  .deleteService(item['serviceid']?.toString() ?? '');
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
        title: const Text('Ticket Services'),
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
        if (controller.isServicesAdminLoading) return const CustomLoader();
        final items = controller.servicesAdminList;
        if (items.isEmpty) {
          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async => controller.loadServicesAdmin(),
            child: ListView(children: const [
              SizedBox(height: 60),
              Center(child: NoDataWidget()),
            ]),
          );
        }
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadServicesAdmin(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.space8),
            itemBuilder: (context, index) {
              final item = items[index];
              final name = item['name']?.toString() ?? '';
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
                        color:
                            ColorResources.purpleColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.support_agent_outlined,
                          size: 16, color: ColorResources.purpleColor),
                    ),
                    const SizedBox(width: Dimensions.space12),
                    Expanded(child: Text(name, style: regularDefault)),
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

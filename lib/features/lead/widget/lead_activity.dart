import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadActivity extends StatefulWidget {
  const LeadActivity({super.key, required this.leadId});
  final String leadId;

  @override
  State<LeadActivity> createState() => _LeadActivityState();
}

class _LeadActivityState extends State<LeadActivity> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LeadController>().loadLeadActivity(widget.leadId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadController>(builder: (controller) {
      if (controller.isActivityLoading) return const CustomLoader();

      final items = controller.leadActivityList;
      if (items.isEmpty) {
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadLeadActivity(widget.leadId),
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
        onRefresh: () async => controller.loadLeadActivity(widget.leadId),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Dimensions.space15,
              Dimensions.space10, Dimensions.space15, Dimensions.space25),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space8),
          itemBuilder: (context, index) {
            final item = items[index];
            final description = item['description']?.toString() ?? '';
            final date = item['date_created']?.toString() ??
                item['date']?.toString() ??
                '';
            final firstName = item['firstname']?.toString() ?? '';
            final lastName = item['lastname']?.toString() ?? '';
            final staffName = '$firstName $lastName'.trim().isEmpty
                ? 'System'
                : '$firstName $lastName'.trim();

            return _ActivityCard(
              description: description,
              staffName: staffName,
              date: date,
            );
          },
        ),
      );
    });
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.description,
    required this.staffName,
    required this.date,
  });

  final String description;
  final String staffName;
  final String date;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorResources.secondaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timeline,
                size: 14, color: ColorResources.secondaryColor),
          ),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(description, style: regularDefault),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 12, color: ColorResources.blueGreyColor),
                    const SizedBox(width: 4),
                    Text(staffName,
                        style: regularSmall.copyWith(
                            color: ColorResources.blueGreyColor)),
                    if (date.isNotEmpty) ...[
                      const SizedBox(width: Dimensions.space8),
                      Icon(Icons.access_time,
                          size: 12, color: ColorResources.blueGreyColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          date,
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kanban board for estimates grouped by status.
class EstimateKanban extends StatelessWidget {
  const EstimateKanban({super.key, required this.estimates});
  final List<Estimate> estimates;

  Map<String, List<Estimate>> _groupByStatus() {
    final map = <String, List<Estimate>>{};
    for (final e in estimates) {
      final status = (e.statusName ?? 'Unknown').trim();
      map.putIfAbsent(status, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByStatus();
    final columns = grouped.keys.toList();

    if (columns.isEmpty) {
      return const Center(child: Text('No estimates'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Dimensions.space12),
      itemCount: columns.length,
      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.space12),
      itemBuilder: (context, i) {
        final status = columns[i];
        final items = grouped[status]!;
        return _KanbanColumn(status: status, estimates: items);
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.status, required this.estimates});
  final String status;
  final List<Estimate> estimates;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2530) : const Color(0xFFDCE3EE),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.space10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(status,
                      style: semiBoldDefault, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${estimates.length}',
                      style: regularSmall.copyWith(
                          color: Theme.of(context).primaryColor)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF12181E) : const Color(0xFFF2F5FA),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(Dimensions.space10)),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(Dimensions.space8),
                itemCount: estimates.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Dimensions.space8),
                itemBuilder: (ctx, idx) =>
                    _KanbanCard(estimate: estimates[idx]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.estimate});
  final Estimate estimate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor =
        ColorResources.estimateStatusColor(estimate.status ?? '');
    final number = estimate.formattedNumber ??
        '${estimate.prefix ?? ''}${estimate.number ?? ''}';
    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.estimateDetailsScreen,
          arguments: estimate.id!),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2430) : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.space8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(number,
                      style: semiBoldDefault, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    Converter.estimateStatusString(estimate.status ?? ''),
                    style:
                        regularSmall.copyWith(color: statusColor, fontSize: 10),
                  ),
                ),
              ],
            ),
            if ((estimate.clientName ?? '').isNotEmpty) ...[
              const SizedBox(height: Dimensions.space4),
              Row(
                children: [
                  Icon(Icons.business_outlined,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: Dimensions.space4),
                  Expanded(
                    child: Text(
                      estimate.clientName!,
                      style: regularSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Dimensions.space4),
            Row(
              children: [
                Icon(Icons.attach_money,
                    size: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(width: Dimensions.space4),
                Text(
                  '${estimate.currencySymbol ?? ''}${estimate.total ?? ''}',
                  style: regularSmall,
                ),
              ],
            ),
            if ((estimate.expiryDate ?? '').isNotEmpty) ...[
              const SizedBox(height: Dimensions.space4),
              Row(
                children: [
                  Icon(Icons.event_outlined,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: Dimensions.space4),
                  Text(estimate.expiryDate!, style: regularSmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

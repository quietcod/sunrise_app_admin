import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalKanban extends StatelessWidget {
  const ProposalKanban({super.key, required this.proposals});
  final List<Proposal> proposals;

  static const Map<String, String> _statusNames = {
    '1': 'Open',
    '2': 'Declined',
    '3': 'Accepted',
    '4': 'Sent',
    '5': 'Revised',
    '6': 'Draft',
  };

  static const Map<String, Color> _statusColors = {
    '1': Color(0xFF2196F3),
    '2': Color(0xFFF44336),
    '3': Color(0xFF4CAF50),
    '4': Color(0xFFFF9800),
    '5': Color(0xFF9C27B0),
    '6': Color(0xFF9E9E9E),
  };

  static const List<String> _columnOrder = ['1', '4', '3', '2', '5', '6'];

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Proposal>> grouped = {};
    for (final p in proposals) {
      final key = p.status ?? '1';
      grouped.putIfAbsent(key, () => []).add(p);
    }

    final columns = _columnOrder.where((k) => grouped.containsKey(k)).toList()
      ..addAll(grouped.keys.where((k) => !_columnOrder.contains(k)));

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space5),
      itemCount: columns.length,
      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.space10),
      itemBuilder: (context, i) {
        final key = columns[i];
        final items = grouped[key] ?? [];
        return _KanbanColumn(
          statusKey: key,
          statusName: _statusNames[key] ?? key,
          color: _statusColors[key] ?? ColorResources.blueGreyColor,
          proposals: items,
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.statusKey,
    required this.statusName,
    required this.color,
    required this.proposals,
  });
  final String statusKey;
  final String statusName;
  final Color color;
  final List<Proposal> proposals;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusName,
                  style: semiBoldDefault.copyWith(color: color, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${proposals.length}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              ],
            ),
          ),
          // Cards list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(Dimensions.space8),
              itemCount: proposals.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Dimensions.space8),
              itemBuilder: (context, i) =>
                  _KanbanCard(proposal: proposals[i], accentColor: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.proposal, required this.accentColor});
  final Proposal proposal;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = proposal.symbol ?? '';
    final total = proposal.total ?? '0';
    final openTill = proposal.openTill ?? '';
    final to = proposal.proposalTo ?? '';

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.proposalDetailsScreen,
          arguments: proposal.id),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242438) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proposal.subject ?? '',
              style: semiBoldSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (to.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 12, color: ColorResources.blueGreyColor),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      to,
                      style: const TextStyle(
                          fontSize: 11, color: ColorResources.blueGreyColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$symbol$total',
                  style: semiBoldSmall.copyWith(color: accentColor),
                ),
                if (openTill.isNotEmpty)
                  Text(
                    openTill,
                    style: const TextStyle(
                        fontSize: 10, color: ColorResources.blueGreyColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

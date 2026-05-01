import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kanban board for leads with optional drag-and-drop status update.
///
/// When [statusColumns] is provided, columns are built from that list (so
/// empty statuses still appear) and dragging a card to a different column
/// triggers [onStatusChange] with the dropped lead and the target status id.
class LeadKanban extends StatefulWidget {
  const LeadKanban({
    super.key,
    required this.leads,
    this.statusColumns,
    this.onStatusChange,
  });

  final List<Lead> leads;

  /// Each entry must contain at minimum: `id`, `name`, optional `color`.
  final List<Map<String, dynamic>>? statusColumns;

  /// Async callback that returns true on success.
  final Future<bool> Function(Lead lead, String newStatusId)? onStatusChange;

  @override
  State<LeadKanban> createState() => _LeadKanbanState();
}

class _LeadKanbanState extends State<LeadKanban> {
  String? _hoverStatusId;

  List<_ColumnData> _buildColumns() {
    if (widget.statusColumns != null && widget.statusColumns!.isNotEmpty) {
      final cols = <_ColumnData>[];
      for (final s in widget.statusColumns!) {
        final id = s['id']?.toString() ?? '';
        final name = s['name']?.toString() ?? id;
        final color = s['color']?.toString();
        final items = widget.leads.where((l) => l.status == id).toList();
        cols.add(_ColumnData(id: id, name: name, color: color, leads: items));
      }
      return cols;
    }
    final map = <String, List<Lead>>{};
    for (final lead in widget.leads) {
      final name = (lead.statusName ?? 'Unknown').trim();
      map.putIfAbsent(name, () => []).add(lead);
    }
    return map.entries
        .map((e) => _ColumnData(
            id: e.value.first.status ?? '',
            name: e.key,
            color: e.value.first.color,
            leads: e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final columns = _buildColumns();
    if (columns.isEmpty) {
      return const Center(child: Text('No leads'));
    }
    final dragEnabled = widget.onStatusChange != null;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Dimensions.space12),
      itemCount: columns.length,
      separatorBuilder: (_, __) => const SizedBox(width: Dimensions.space12),
      itemBuilder: (context, i) {
        final col = columns[i];
        return _KanbanColumn(
          column: col,
          dragEnabled: dragEnabled,
          isHover: _hoverStatusId == col.id,
          onWillAccept: (Lead? lead) {
            if (lead == null) return false;
            return lead.status != col.id;
          },
          onHoverChange: (hover) {
            setState(() => _hoverStatusId = hover ? col.id : null);
          },
          onAccept: (Lead lead) async {
            setState(() => _hoverStatusId = null);
            await widget.onStatusChange?.call(lead, col.id);
          },
        );
      },
    );
  }
}

class _ColumnData {
  _ColumnData(
      {required this.id,
      required this.name,
      required this.color,
      required this.leads});
  final String id;
  final String name;
  final String? color;
  final List<Lead> leads;
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.column,
    required this.dragEnabled,
    required this.isHover,
    required this.onWillAccept,
    required this.onAccept,
    required this.onHoverChange,
  });
  final _ColumnData column;
  final bool dragEnabled;
  final bool isHover;
  final bool Function(Lead? lead) onWillAccept;
  final Future<void> Function(Lead lead) onAccept;
  final void Function(bool hover) onHoverChange;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF607D8B);
    var s = hex.replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    final v = int.tryParse(s, radix: 16);
    return v == null ? const Color(0xFF607D8B) : Color(v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = _parseColor(column.color);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space12, vertical: Dimensions.space8),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.18),
              border: Border(left: BorderSide(color: headerColor, width: 4)),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.space10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(column.name,
                      style: semiBoldDefault, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space4),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${column.leads.length}',
                      style: regularSmall.copyWith(color: headerColor)),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Lead>(
              onWillAcceptWithDetails: (d) {
                final accept = onWillAccept(d.data);
                if (accept) onHoverChange(true);
                return accept;
              },
              onLeave: (_) => onHoverChange(false),
              onAcceptWithDetails: (d) => onAccept(d.data),
              builder: (ctx, candidate, rejected) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isHover
                        ? headerColor.withValues(alpha: 0.12)
                        : (isDark
                            ? const Color(0xFF12181E)
                            : const Color(0xFFF2F5FA)),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(Dimensions.space10)),
                    border: isHover
                        ? Border.all(color: headerColor, width: 1.5)
                        : null,
                  ),
                  child: column.leads.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.space12),
                            child: Text(
                              dragEnabled ? 'Drop here' : 'No leads',
                              style: regularSmall.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(Dimensions.space8),
                          itemCount: column.leads.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Dimensions.space8),
                          itemBuilder: (ctx, idx) {
                            final lead = column.leads[idx];
                            final card = _KanbanCard(lead: lead);
                            if (!dragEnabled) return card;
                            return LongPressDraggable<Lead>(
                              data: lead,
                              delay: const Duration(milliseconds: 250),
                              feedback: Material(
                                color: Colors.transparent,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: SizedBox(
                                      width: 200,
                                      child: _KanbanCard(lead: lead)),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: card,
                              ),
                              child: card,
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id!),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2430) : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.space8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lead.name ?? '',
              style: semiBoldDefault,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if ((lead.company ?? '').isNotEmpty) ...[
              const SizedBox(height: Dimensions.space4),
              Row(
                children: [
                  Icon(Icons.business_outlined,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: Dimensions.space4),
                  Expanded(
                    child: Text(
                      lead.company!,
                      style: regularSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if ((lead.email ?? '').isNotEmpty) ...[
              const SizedBox(height: Dimensions.space4),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: Dimensions.space4),
                  Expanded(
                    child: Text(
                      lead.email!,
                      style: regularSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.isDark,
  });

  final Invoice invoice;
  final bool isDark;

  Color _blend(Color foreground, Color background, double opacity) {
    return Color.alphaBlend(foreground.withValues(alpha: opacity), background);
  }

  _Palette _palette(Color statusColor) {
    final darkBase = const Color(0xFF343434);
    final lightBase = Colors.white;

    if (isDark) {
      return _Palette(
        start: _blend(statusColor, darkBase, 0.20),
        end: _blend(statusColor, darkBase, 0.30),
        border: _blend(statusColor, darkBase, 0.48),
        shadow: statusColor.withValues(alpha: 0.18),
        iconBg: _blend(statusColor, darkBase, 0.32),
        iconFg: Colors.white,
        title: Colors.white,
        body: Colors.white.withValues(alpha: 0.88),
        chipBg: _blend(statusColor, darkBase, 0.35),
        chipText: Colors.white,
      );
    }

    return _Palette(
      start: _blend(statusColor, lightBase, 0.09),
      end: _blend(statusColor, lightBase, 0.18),
      border: _blend(statusColor, lightBase, 0.30),
      shadow: statusColor.withValues(alpha: 0.13),
      iconBg: _blend(statusColor, lightBase, 0.20),
      iconFg: _blend(statusColor, Colors.black, 0.35),
      title: _blend(statusColor, Colors.black, 0.60),
      body: _blend(statusColor, Colors.black, 0.46),
      chipBg: _blend(statusColor, lightBase, 0.22),
      chipText: _blend(statusColor, Colors.black, 0.44),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = ColorResources.invoiceStatusColor(invoice.status ?? '');
    final p = _palette(statusColor);
    final invoiceNumber = '${invoice.prefix ?? ''}${invoice.number ?? ''}';
    final statusLabel = Converter.invoiceStatusString(invoice.status ?? '');
    final clientName = invoice.clientName ?? '';
    final total = '${invoice.currencySymbol ?? ''}${invoice.total ?? ''}';
    final date = invoice.date ?? '';
    final dueDate = invoice.duedate ?? '';

    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.invoiceDetailsScreen, arguments: invoice.id!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.start, p.end],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
              boxShadow: [
                BoxShadow(
                  color: p.shadow,
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: invoice number + amount
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: p.iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: p.iconFg,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoiceNumber,
                              style: semiBoldLarge.copyWith(color: p.title),
                            ),
                            if (clientName.isNotEmpty)
                              Text(
                                clientName,
                                style: regularSmall.copyWith(color: p.body),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            total,
                            style: semiBoldLarge.copyWith(color: p.title),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.chipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: regularSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space10),
                  // Bottom row: invoice date + due date
                  Row(
                    children: [
                      _MetaItem(
                        icon: Icons.calendar_today_outlined,
                        label: date,
                        color: p.body,
                      ),
                      if (dueDate.isNotEmpty) ...[
                        const SizedBox(width: Dimensions.space15),
                        _MetaItem(
                          icon: Icons.event_busy_outlined,
                          label: 'Due: $dueDate',
                          color: p.body,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Palette {
  final Color start;
  final Color end;
  final Color border;
  final Color shadow;
  final Color iconBg;
  final Color iconFg;
  final Color title;
  final Color body;
  final Color chipBg;
  final Color chipText;

  const _Palette({
    required this.start,
    required this.end,
    required this.border,
    required this.shadow,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.body,
    required this.chipBg,
    required this.chipText,
  });
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: regularSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

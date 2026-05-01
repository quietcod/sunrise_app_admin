import 'dart:ui';

import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/features/ticket/helper/assigned_staff_name_helper.dart';
import 'package:flutex_admin/features/ticket/model/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.index,
    required this.ticketModel,
  });

  final int index;
  final TicketsModel ticketModel;

  Color _blend(Color foreground, Color background, double opacity) {
    return Color.alphaBlend(
      foreground.withValues(alpha: opacity),
      background,
    );
  }

  _TicketTilePalette _tilePaletteForStatus(Color statusColor, bool isDark) {
    final darkBase = const Color(0xFF343434);
    final lightBase = Colors.white;

    if (isDark) {
      return _TicketTilePalette(
        start: _blend(statusColor, darkBase, 0.22),
        end: _blend(statusColor, darkBase, 0.31),
        border: _blend(statusColor, darkBase, 0.50),
        shadow: statusColor.withValues(alpha: 0.21),
        iconBg: _blend(statusColor, darkBase, 0.33),
        iconFg: Colors.white,
        title: Colors.white,
        body: Colors.white.withValues(alpha: 0.9),
        chipBg: _blend(statusColor, darkBase, 0.38),
        chipText: Colors.white,
      );
    }

    return _TicketTilePalette(
      start: _blend(statusColor, lightBase, 0.10),
      end: _blend(statusColor, lightBase, 0.19),
      border: _blend(statusColor, lightBase, 0.33),
      shadow: statusColor.withValues(alpha: 0.14),
      iconBg: _blend(statusColor, lightBase, 0.21),
      iconFg: _blend(statusColor, Colors.black, 0.36),
      title: _blend(statusColor, Colors.black, 0.62),
      body: _blend(statusColor, Colors.black, 0.48),
      chipBg: _blend(statusColor, lightBase, 0.24),
      chipText: _blend(statusColor, Colors.black, 0.46),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicketController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticket = ticketModel.data![index];
    final statusColor = ColorResources.ticketStatusColor(ticket.status ?? '');
    final tilePalette = _tilePaletteForStatus(statusColor, isDark);
    final ticketId = ticket.id ?? '';
    final canShowAssignControl =
        controller.canAssignTicketToStaff && ticketId.isNotEmpty;
    final hasStaffOptions = controller.assignableStaff.isNotEmpty;
    final isStaffLoading = controller.isAssignableStaffLoading;
    final isAssigning = controller.isTicketAssigning(ticketId);

    final selectedAssignee = controller.selectedAssigneeForTicket(ticket);
    final hasSelectedInOptions = controller.assignableStaff
        .any((staff) => staff.staffId == selectedAssignee);
    final dropdownValue = hasSelectedInOptions ? selectedAssignee : null;

    final selectedStaffName = selectedAssignee == null
        ? ''
        : controller.assignableStaff
        .where((staff) => staff.staffId == selectedAssignee)
        .map((staff) => staff.fullName)
        .cast<String?>()
        .firstWhere((name) => (name ?? '').isNotEmpty, orElse: () => '')!;
    final helperAssignedName = buildAssignedStaffName(ticket.toJson());
    final assignedStaffName = helperAssignedName != 'Unassigned'
        ? helperAssignedName
        : (selectedStaffName.isNotEmpty ? selectedStaffName : 'Unassigned');

    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.ticketDetailsScreen, arguments: ticket.id!);
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
                colors: [tilePalette.start, tilePalette.end],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: tilePalette.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: tilePalette.shadow,
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 4, color: statusColor),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tilePalette.iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.confirmation_number_outlined,
                            color: tilePalette.iconFg,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ticket.subject ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: semiBoldLarge.copyWith(
                              color: tilePalette.title,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: tilePalette.chipBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ticket.statusName?.tr ?? '',
                            style: semiBoldOverSmall.copyWith(
                              color: tilePalette.chipText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Converter.parseHtmlString(ticket.message ?? ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: regularSmall.copyWith(
                        color: tilePalette.body,
                      ),
                    ),
                    const CustomDivider(space: Dimensions.space10),
                    _MetaRow(
                      icon: Icons.account_box_rounded,
                      label: 'Company',
                      value: ticket.company ?? '-',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _MetaRow(
                      icon: Icons.flag_outlined,
                      label: 'Priority',
                      value: ticket.priorityName?.tr ?? '-',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _MetaRow(
                      icon: Icons.calendar_month,
                      label: 'Date',
                      value: DateConverter.formatValidityDate(
                          ticket.dateCreated ?? ''),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 7),
                    _MetaRow(
                      icon: Icons.person_outline,
                      label: 'Assigned To',
                      value: assignedStaffName,
                      isDark: isDark,
                    ),
                    if (canShowAssignControl) ...[
                      const SizedBox(height: 9),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isDark
                                      ? const Color(0xFF241B1B)
                                      : const Color(0xFFF5F7FB))
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (isDark
                                        ? const Color(0xFF594040)
                                        : const Color(0xFFD9E0EC))
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: dropdownValue,
                                    onTap: () {
                                      if (!hasStaffOptions && !isStaffLoading) {
                                        controller.loadAssignableStaff(
                                            force: true);
                                      }
                                    },
                                    hint: Text(
                                      assignedStaffName.isNotEmpty
                                          ? assignedStaffName
                                          : hasStaffOptions
                                          ? 'Assign to staff'
                                          : (isStaffLoading
                                          ? 'Loading staff...'
                                          : 'Staff list unavailable'),
                                      style: regularSmall.copyWith(
                                        color: isDark
                                            ? const Color(0xFFBAC2CF)
                                            : ColorResources.blueGreyColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isDark
                                          ? const Color(0xFFE1E6EF)
                                          : ColorResources.primaryColor,
                                    ),
                                    items: controller.assignableStaff
                                        .map(
                                          (staff) => DropdownMenuItem<int>(
                                        value: staff.staffId,
                                        child: Text(
                                          staff.fullName,
                                          overflow: TextOverflow.ellipsis,
                                          style: regularDefault.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: hasStaffOptions
                                        ? (value) {
                                      controller
                                          .setSelectedAssigneeForTicket(
                                          ticketId, value);
                                    }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 38,
                              child: ElevatedButton(
                                onPressed: (!hasStaffOptions || isAssigning)
                                    ? null
                                    : () {
                                  controller.assignTicketToStaff(
                                    ticketId: ticketId,
                                    staffId: controller
                                        .selectedAssigneeForTicket(
                                        ticket),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF17233A)
                                      : const Color(0xFF243757),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: (isDark
                                      ? const Color(0xFF17233A)
                                      : const Color(0xFF243757))
                                      .withValues(alpha: 0.45),
                                  disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isAssigning
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  'Assign',
                                  style: regularSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseColor =
    isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF2A3442);
    final valueColor = isDark ? Colors.white : const Color(0xFF1E2936);

    return Row(
      children: [
        Icon(icon, size: 16, color: baseColor),
        const SizedBox(width: 7),
        Text(
          '$label:',
          style: regularOverSmall.copyWith(color: baseColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: regularDefault.copyWith(
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketTilePalette {
  const _TicketTilePalette({
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
}

import 'package:flutter/material.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:get/get.dart';

class StatusChangeSelector extends StatelessWidget {
  final String ticketId;
  final String currentStatus;

  const StatusChangeSelector({
    Key? key,
    required this.ticketId,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'id': '1', 'name': 'Open', 'color': Colors.blue},
      {'id': '2', 'name': 'In Progress', 'color': Colors.orange},
      {'id': '3', 'name': 'Answered', 'color': Colors.green},
      {'id': '4', 'name': 'On Hold', 'color': Colors.yellow},
      {'id': '5', 'name': 'Closed', 'color': Colors.grey},
    ];

    final isValidStatus = statuses.any((s) => s['id'] == currentStatus);
    final displayStatus =
        isValidStatus ? currentStatus : statuses.first['id'].toString();

    return GetBuilder<TicketController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.space12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(Dimensions.space8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: Dimensions.space12),
              Text('Status:',
                  style: regularDefault.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: Dimensions.space12),
              Expanded(
                child: DropdownButton<String>(
                  value: displayStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status['id'].toString(),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: status['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(status['name'].toString()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: controller.isStatusChanging
                      ? null
                      : (newStatus) {
                          if (newStatus != null && newStatus != currentStatus) {
                            controller.changeStatus(ticketId, newStatus);
                          }
                        },
                ),
              ),
              if (controller.isStatusChanging)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }
}

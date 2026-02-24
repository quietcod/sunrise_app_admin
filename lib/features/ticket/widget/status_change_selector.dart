import 'package:flutter/material.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:get/get.dart';

class StatusChangeSelector extends StatelessWidget {
  final String ticketId;
  final String currentStatus;

  const StatusChangeSelector({
    super.key,
    required this.ticketId,
    required this.currentStatus,
  });

  void _showCloseOptions(
      BuildContext context, TicketController controller, String ticketId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline, size: 40, color: Colors.amber),
            const SizedBox(height: 12),
            Text('Close Ticket', style: mediumLarge),
            const SizedBox(height: 8),
            Text(
              'How would you like to close this ticket?',
              style: regularDefault.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Request OTP option
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.sms_outlined),
                label: const Text('Request OTP from Customer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.teal),
                  foregroundColor: Colors.teal,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  controller.requestCloseOtp(ticketId);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Close without OTP option
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Close Without OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  controller.closeTicketWithoutOtp(ticketId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
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
                  onChanged: (controller.isStatusChanging ||
                          controller.isOtpRequesting ||
                          controller.isClosingWithoutOtp)
                      ? null
                      : (newStatus) {
                          if (newStatus != null && newStatus != currentStatus) {
                            if (newStatus == '5') {
                              if (controller.canCloseWithoutOtp) {
                                // Permitted staff: ask how to close
                                _showCloseOptions(
                                    context, controller, ticketId);
                              } else {
                                // Regular staff: OTP required
                                controller.requestCloseOtp(ticketId);
                              }
                            } else {
                              controller.changeStatus(ticketId, newStatus);
                            }
                          }
                        },
                ),
              ),
              if (controller.isStatusChanging ||
                  controller.isOtpRequesting ||
                  controller.isClosingWithoutOtp)
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

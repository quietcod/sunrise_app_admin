import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:get/get.dart';

/// Full-screen OTP verification widget that replaces the ticket details body.
/// Matches the CRM web interface "Security Verification Required" screen.
class OtpVerificationScreen extends StatefulWidget {
  final String ticketId;
  final String? ticketSubject;
  final String? clientName;
  final String? clientMobile;

  const OtpVerificationScreen({
    super.key,
    required this.ticketId,
    this.ticketSubject,
    this.clientName,
    this.clientMobile,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketController>(
      builder: (controller) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Lock icon
                Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.amber[700],
                ),
                const SizedBox(height: Dimensions.space15),
                // Title
                Text(
                  'Security Verification Required',
                  style: mediumOverLarge.copyWith(
                    color: Colors.teal[600],
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.space15),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space15),
                  child: Text(
                    'This ticket is pending closure. Please enter the OTP sent to the customer to verify and close the ticket.',
                    style: regularDefault.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                // Ticket info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.space15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(Dimensions.space10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.ticketSubject ?? 'Ticket #${widget.ticketId}',
                        style: mediumLarge.copyWith(fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.clientName != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Client: ${widget.clientName}',
                          style:
                              regularDefault.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                      if (widget.clientMobile != null &&
                          widget.clientMobile!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mobile: ${widget.clientMobile}',
                          style:
                              regularDefault.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // OTP Label
                Text(
                  'One Time Password (OTP)',
                  style: mediumDefault.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimensions.space10),
                // OTP Input
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: mediumOverLarge.copyWith(
                      letterSpacing: 12,
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      hintText: '123456',
                      hintStyle: mediumOverLarge.copyWith(
                        color: Colors.grey[350],
                        letterSpacing: 12,
                        fontSize: 24,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.space8),
                        borderSide: BorderSide(color: Colors.teal[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.space8),
                        borderSide:
                            BorderSide(color: Colors.teal[500]!, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space15,
                        vertical: 16,
                      ),
                      counterText: '',
                    ),
                  ),
                ),
                // Error message
                if (controller.otpErrorMessage != null) ...[
                  const SizedBox(height: Dimensions.space10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 18),
                        const SizedBox(width: 6),
                        Text(
                          controller.otpErrorMessage!,
                          style:
                              regularDefault.copyWith(color: Colors.red[700]),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Verify & Close button
                SizedBox(
                  width: 260,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isOtpVerifying
                        ? null
                        : () {
                            controller.verifyCloseOtp(
                              widget.ticketId,
                              _otpController.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.space8),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isOtpVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verify & Close Ticket',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: Dimensions.space15),
                // Resend & Cancel buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Resend OTP button
                    ElevatedButton(
                      onPressed: controller.isOtpRequesting
                          ? null
                          : () {
                              controller.resendCloseOtp(widget.ticketId);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.space8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: controller.isOtpRequesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Resend OTP'),
                    ),
                    const SizedBox(width: Dimensions.space12),
                    // Cancel button
                    OutlinedButton(
                      onPressed: () {
                        controller.cancelOtpVerification();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.space8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel Verification'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:get/get.dart';

const Color _kOrange = Color(0xffFF9F43);
const Color _kOrangeDark = Color(0xffFF6B00);

/// Full-screen OTP verification widget that replaces the ticket details body.
/// Glassmorphism design — dark: black + orange, light: white + orange.
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

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<TicketController>(
      builder: (controller) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space20,
              vertical: Dimensions.space15,
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Animated lock icon ──────────────────────────────────────
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _kOrange.withValues(alpha: 0.30),
                          _kOrange.withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(
                        color: _kOrange.withValues(alpha: 0.50),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 40,
                      color: _kOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ───────────────────────────────────────────────────
                Text(
                  'Security Verification',
                  style: TextStyle(
                    fontFamily: 'Montserrat-Arabic',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Required',
                  style: const TextStyle(
                    fontFamily: 'Montserrat-Arabic',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kOrange,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── Description ─────────────────────────────────────────────
                Text(
                  'This ticket is pending closure. Please enter the OTP sent to the customer to verify and close the ticket.',
                  style: TextStyle(
                    fontFamily: 'Montserrat-Arabic',
                    fontSize: 13,
                    height: 1.55,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── Ticket info glass card ───────────────────────────────────
                _GlassCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      Text(
                        widget.ticketSubject ?? 'Ticket #${widget.ticketId}',
                        style: TextStyle(
                          fontFamily: 'Montserrat-Arabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.clientName != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Client: ${widget.clientName}',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Arabic',
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                      if (widget.clientMobile != null &&
                          widget.clientMobile!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mobile: ${widget.clientMobile}',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Arabic',
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── OTP label ───────────────────────────────────────────────
                Text(
                  'One Time Password (OTP)',
                  style: TextStyle(
                    fontFamily: 'Montserrat-Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                // ── PIN boxes (6 individual digit cells) ────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible TextField that captures keyboard input
                    Opacity(
                      opacity: 0.0,
                      child: TextField(
                        controller: _otpController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(counterText: ''),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    // Visual digit boxes — IgnorePointer so taps reach the
                    // transparent TextField below
                    IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (i) {
                          final otp = _otpController.text;
                          final filled = i < otp.length;
                          final active = i == otp.length && _focusNode.hasFocus;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 44,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? Colors.white
                                      .withValues(alpha: filled ? 0.13 : 0.06)
                                  : Colors.white
                                      .withValues(alpha: filled ? 0.90 : 0.55),
                              border: Border.all(
                                color: active
                                    ? _kOrange
                                    : filled
                                        ? _kOrange.withValues(alpha: 0.65)
                                        : isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.18)
                                            : Colors.black
                                                .withValues(alpha: 0.14),
                                width: active ? 2.0 : 1.5,
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: _kOrange.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: filled
                                  ? Text(
                                      otp[i],
                                      style: TextStyle(
                                        fontFamily: 'Montserrat-Arabic',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A),
                                      ),
                                    )
                                  : active
                                      ? Container(
                                          width: 2,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _kOrange,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        )
                                      : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),

                // ── Error message ───────────────────────────────────────────
                if (controller.otpErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  _GlassCard(
                    isDark: isDark,
                    overlayColor: Colors.red.withValues(alpha: 0.10),
                    borderColor: Colors.redAccent.withValues(alpha: 0.35),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            controller.otpErrorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat-Arabic',
                              fontSize: 13,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ── Verify & Close button (gradient pill) ───────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: controller.isOtpVerifying
                          ? null
                          : const LinearGradient(
                              colors: [_kOrange, _kOrangeDark],
                            ),
                      color: controller.isOtpVerifying
                          ? (isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.08))
                          : null,
                      boxShadow: controller.isOtpVerifying
                          ? null
                          : [
                              BoxShadow(
                                color: _kOrange.withValues(alpha: 0.40),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.isOtpVerifying
                          ? null
                          : () => controller.verifyCloseOtp(
                                widget.ticketId,
                                _otpController.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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
                                fontFamily: 'Montserrat-Arabic',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Resend + Cancel row ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isOtpRequesting
                              ? null
                              : () =>
                                  controller.resendCloseOtp(widget.ticketId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : _kOrange.withValues(alpha: 0.10),
                            foregroundColor: _kOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: _kOrange.withValues(alpha: 0.65),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: controller.isOtpRequesting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            _kOrange),
                                  ),
                                )
                              : const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat-Arabic',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => controller.cancelOtpVerification(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white60 : Colors.black54,
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black26,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Montserrat-Arabic',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Send OTP to Different Number ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showSendToDifferentNumberSheet(
                        context, controller, isDark),
                    icon: const Icon(Icons.phone_forwarded_rounded,
                        color: _kOrange, size: 18),
                    label: const Text(
                      'Send OTP to Different Number',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Arabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kOrange,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kOrange,
                      side: BorderSide(
                        color: _kOrange.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendToDifferentNumberSheet(
      BuildContext context, TicketController controller, bool isDark) {
    final phoneCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.80)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(
                      color: _kOrange.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
                child: StatefulBuilder(
                  builder: (ctx, setSheet) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.phone_forwarded_rounded,
                                color: _kOrange, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Send OTP to Different Number',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Arabic',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the phone number where the OTP should be sent.',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Arabic',
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Phone input
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'Montserrat-Arabic',
                            fontSize: 15,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText: '+91 9876543210',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat-Arabic',
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            prefixIcon: const Icon(Icons.phone_outlined,
                                color: _kOrange, size: 20),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: _kOrange, width: 1.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Send button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: GetBuilder<TicketController>(
                            builder: (ctrl) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: ctrl.isSendingOtpToNumber
                                      ? null
                                      : const LinearGradient(
                                          colors: [_kOrange, _kOrangeDark]),
                                  color: ctrl.isSendingOtpToNumber
                                      ? (isDark
                                          ? Colors.white12
                                          : Colors.black
                                              .withValues(alpha: 0.08))
                                      : null,
                                  boxShadow: ctrl.isSendingOtpToNumber
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: _kOrange.withValues(
                                                alpha: 0.38),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: ctrl.isSendingOtpToNumber
                                      ? null
                                      : () async {
                                          final phone = phoneCtrl.text.trim();
                                          if (phone.isEmpty) return;
                                          final ok = await ctrl
                                              .sendOtpToDifferentNumber(
                                            widget.ticketId,
                                            phone,
                                          );
                                          if (ok && context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                  icon: ctrl.isSendingOtpToNumber
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                  label: const Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-Arabic',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Glassmorphism card ────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final Color? overlayColor;
  final Color? borderColor;

  const _GlassCard({
    required this.isDark,
    required this.child,
    this.overlayColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: overlayColor ??
                (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.65)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.13)
                      : Colors.white.withValues(alpha: 0.80)),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/attendance/controller/attendance_controller.dart';
import 'package:flutex_admin/features/attendance/repo/attendance_repo.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(sharedPreferences: Get.find()));
    }
    if (!Get.isRegistered<AttendanceRepo>()) {
      Get.put(AttendanceRepo(apiClient: Get.find()));
    }
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController(attendanceRepo: Get.find()));
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(builder: (c) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final primary = Theme.of(context).primaryColor;

      // Determine state
      final checkedIn = c.todayAttendance?.isCheckedIn == true;
      final checkedOut = c.todayAttendance?.isCheckedOut == true;
      final allDone = checkedIn && checkedOut;
      final isLoading = c.isCheckingIn || c.isCheckingOut;

      // Button appearance
      Color btnColor;
      String btnLabel;
      IconData btnIcon;
      VoidCallback? btnAction;

      if (allDone) {
        btnColor = Colors.grey;
        btnLabel = 'Done for Today';
        btnIcon = Icons.check_circle_outline;
        btnAction = null;
      } else if (checkedIn) {
        btnColor = Colors.orange;
        btnLabel = 'Check Out';
        btnIcon = Icons.logout;
        btnAction = c.performCheckOut;
      } else {
        btnColor = Colors.green;
        btnLabel = 'Check In';
        btnIcon = Icons.login;
        btnAction = c.performCheckIn;
      }

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0A) : const Color(0xFFEFF3F8),
        appBar: AppBar(
          title: Text('Attendance', style: semiBoldLarge),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: c.isLoadingAttendance
            ? const CustomLoader()
            : RefreshIndicator(
                onRefresh: c.getTodayAttendance,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: Dimensions.space20),

                        // ── Status card ──────────────────────────────────
                        _StatusCard(controller: c, isDark: isDark),
                        const SizedBox(height: Dimensions.space30),

                        // ── Big toggle button ────────────────────────────
                        GestureDetector(
                          onTap: isLoading ? null : btnAction,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLoading ? Colors.grey[400] : btnColor,
                              boxShadow: [
                                BoxShadow(
                                  color: (isLoading ? Colors.grey : btnColor)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                else
                                  Icon(btnIcon, color: Colors.white, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  isLoading ? '…' : btnLabel,
                                  style: semiBoldDefault.copyWith(
                                      color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space30),

                        // ── Location card ────────────────────────────────
                        _LocationCard(controller: c, isDark: isDark),
                        const SizedBox(height: Dimensions.space20),

                        // ── Location update form ─────────────────────────
                        _LocationUpdateForm(
                          controller: c,
                          noteController: _noteController,
                          primary: primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final AttendanceController controller;
  final bool isDark;
  const _StatusCard({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final a = controller.todayAttendance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space20, vertical: Dimensions.space15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: a == null
          ? Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: Dimensions.space10),
                child: Text('No record yet today',
                    style: regularDefault.copyWith(color: Colors.grey)),
              ),
            )
          : Row(
              children: [
                _TimeChip(
                  label: 'In',
                  time: controller.formatTime(a.checkInTime),
                  color: Colors.green,
                ),
                const Spacer(),
                _TimeChip(
                  label: 'Out',
                  time: a.checkOutTime != null
                      ? controller.formatTime(a.checkOutTime)
                      : '--:--:--',
                  color: a.checkOutTime != null ? Colors.orange : Colors.grey,
                ),
                const Spacer(),
                _TimeChip(
                  label: 'Duration',
                  time: a.formattedDuration,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  const _TimeChip(
      {required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: regularSmall.copyWith(color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(time, style: semiBoldDefault.copyWith(color: color, fontSize: 17)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final AttendanceController controller;
  final bool isDark;
  const _LocationCard({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.red, size: 18),
          ),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location',
                    style: regularSmall.copyWith(color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(
                  controller.currentAddress,
                  style: regularDefault,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION UPDATE FORM
// ─────────────────────────────────────────────────────────────────────────────

class _LocationUpdateForm extends StatelessWidget {
  final AttendanceController controller;
  final TextEditingController noteController;
  final Color primary;
  const _LocationUpdateForm(
      {required this.controller,
      required this.noteController,
      required this.primary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Location Update',
              style: semiBoldDefault.copyWith(color: primary)),
          const SizedBox(height: Dimensions.space12),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'What are you working on?',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.all(Dimensions.space12),
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: controller.isSubmittingLocation
                  ? null
                  : () {
                      controller.submitLocationUpdate(noteController.text);
                      noteController.clear();
                    },
              icon: controller.isSubmittingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Icon(Icons.send, size: 16),
              label:
                  Text(controller.isSubmittingLocation ? '…' : 'Send Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

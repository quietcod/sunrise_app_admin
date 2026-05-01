import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/work_report/model/work_report_model.dart';
import 'package:flutex_admin/features/work_report/repo/work_report_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkReportController extends GetxController {
  WorkReportController({required this.workReportRepo});
  WorkReportRepo workReportRepo;

  // ── List / loading state ───────────────────────────────────────────────
  bool isLoading = true;
  bool isSubmitLoading = false;
  bool isDetailLoading = false;
  bool isReplyLoading = false;
  bool isLatestLoading = false;

  WorkReportsModel reportsModel = WorkReportsModel();
  WorkReportMeta? meta;

  /// Admin overview: latest report per staff.
  List<WorkReport> latestPerStaff = [];

  /// Currently opened detail (for detail screen).
  WorkReport? activeReport;

  // ── Submit form (location / project / details) ────────────────────────
  final locationController = TextEditingController();
  final projectController = TextEditingController();
  final detailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // ── Reply form ─────────────────────────────────────────────────────────
  final replyController = TextEditingController();

  // ── Admin filter state ─────────────────────────────────────────────────
  List<StaffMember> staffList = [];
  String? filterStaffId;
  String? filterDate;

  bool get isAdmin => meta?.isAdmin ?? false;
  String? get currentStaffId => meta?.staffId;
  String? get currentStaffName => meta?.staffName;

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialData() async {
    isLoading = true;
    update();
    await _loadReports();
    if (isAdmin) {
      await _loadStaffList();
    }
    isLoading = false;
    update();
  }

  Future<void> loadDashboardData() async {
    // First load: pull reports to learn role (meta.is_admin), then load
    // either latest-per-staff (admin) — staff doesn't need a list here.
    await _loadReports();
    if (isAdmin) {
      await loadLatestPerStaff();
    }
    update();
  }

  Future<void> _loadReports() async {
    final res = await workReportRepo.getReports(
      staffId: filterStaffId,
      date: filterDate,
    );
    if (res.status) {
      reportsModel = WorkReportsModel.fromJson(jsonDecode(res.responseJson));
      meta = reportsModel.meta;
    } else {
      reportsModel = WorkReportsModel();
    }
  }

  Future<void> _loadStaffList() async {
    if (staffList.isNotEmpty) return;
    final res = await workReportRepo.getStaffList();
    if (res.status) {
      final model = StaffListModel.fromJson(jsonDecode(res.responseJson));
      staffList = model.data ?? [];
    }
  }

  Future<void> loadLatestPerStaff() async {
    isLatestLoading = true;
    update();
    final res = await workReportRepo.getLatestPerStaff();
    if (res.status) {
      final m = WorkReportsModel.fromJson(jsonDecode(res.responseJson));
      latestPerStaff = m.data ?? [];
      meta = m.meta ?? meta;
    } else {
      latestPerStaff = [];
    }
    isLatestLoading = false;
    update();
  }

  // ── Filters (admin only) ───────────────────────────────────────────────

  void setFilterStaff(String? staffId) {
    filterStaffId = staffId;
    update();
    reloadFiltered();
  }

  void setFilterDate(String? date) {
    filterDate = date;
    update();
    reloadFiltered();
  }

  void clearFilters() {
    filterStaffId = null;
    filterDate = null;
    update();
    reloadFiltered();
  }

  Future<void> reloadFiltered() async {
    isLoading = true;
    update();
    await _loadReports();
    isLoading = false;
    update();
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> submitReport() async {
    final location = locationController.text.trim();
    final project = projectController.text.trim();
    final details = detailsController.text.trim();
    if (location.isEmpty || project.isEmpty || details.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await workReportRepo.submitReport({
      'location': location,
      'project': project,
      'details': details,
      'report_date':
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      update();
      CustomSnackBar.success(
          successList: [LocalStrings.submittedSuccessfully.tr]);
      // Refresh own reports + admin latest-per-staff overview if applicable.
      await _loadReports();
      if (isAdmin) {
        await loadLatestPerStaff();
      }
      update();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteReport(String id) async {
    final res = await workReportRepo.deleteReport(id);
    if (res.status) {
      // Optimistically drop the row from any local caches so the dashboard
      // widget and list stay in sync even before the network refresh lands.
      reportsModel.data?.removeWhere((r) => r.id == id);
      latestPerStaff.removeWhere((r) => r.id == id);
      update();
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await initialData();
      if (isAdmin) {
        await loadLatestPerStaff();
      }
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  void changeDate(DateTime d) {
    selectedDate = d;
    update();
  }

  void clearForm() {
    locationController.clear();
    projectController.clear();
    detailsController.clear();
    selectedDate = DateTime.now();
  }

  // ── Detail / Replies ───────────────────────────────────────────────────

  Future<void> loadReportDetail(String id) async {
    isDetailLoading = true;
    activeReport = null;
    update();
    final res = await workReportRepo.getReportById(id);
    if (res.status) {
      final detail = WorkReportDetailResponse.fromJson(
        jsonDecode(res.responseJson),
      );
      activeReport = detail.data;
      meta = detail.meta ?? meta;
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
    isDetailLoading = false;
    update();
  }

  Future<void> postReply() async {
    final id = activeReport?.id;
    final text = replyController.text.trim();
    if (id == null || text.isEmpty) return;

    isReplyLoading = true;
    update();
    final res = await workReportRepo.postReply(id, text);
    isReplyLoading = false;
    if (res.status) {
      replyController.clear();
      await loadReportDetail(id);
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
    update();
  }

  @override
  void onClose() {
    locationController.dispose();
    projectController.dispose();
    detailsController.dispose();
    replyController.dispose();
    super.onClose();
  }
}

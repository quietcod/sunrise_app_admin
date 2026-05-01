import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/repo/generic_extras_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:get/get.dart';

/// One controller per (relType, relId) entity, registered with a tag.
/// Use [GenericExtrasController.tagFor] to obtain the GetX tag.
class GenericExtrasController extends GetxController {
  final GenericExtrasRepo repo;
  final ApiClient apiClient;
  final String relType;
  final String relId;

  GenericExtrasController({
    required this.repo,
    required this.apiClient,
    required this.relType,
    required this.relId,
  });

  static String tagFor(String relType, String relId) => '$relType:$relId';

  // ── State ──────────────────────────────────────────────────────────────
  bool isRemindersLoading = false;
  bool isActivityLoading = false;
  bool isCustomFieldsLoading = false;
  bool isAttachmentsLoading = false;
  bool isSubmitting = false;

  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> activity = [];
  List<Map<String, dynamic>> customFields = [];
  List<Map<String, dynamic>> attachments = [];

  List<StaffMember> staffList = [];

  Future<List<StaffMember>> loadStaff() async {
    if (staffList.isNotEmpty) return staffList;
    final r = await apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.staffUrl}',
      Method.getMethod,
      null,
      passHeader: true,
    );
    if (r.status) {
      try {
        final m = StaffListModel.fromJson(jsonDecode(r.responseJson));
        staffList = m.data ?? [];
      } catch (_) {}
    }
    return staffList;
  }

  // ── Reminders ──────────────────────────────────────────────────────────
  Future<void> loadReminders() async {
    isRemindersLoading = true;
    update();
    final r = await repo.getReminders(relType, relId);
    isRemindersLoading = false;
    if (r.status) {
      try {
        final raw = jsonDecode(r.responseJson)['data'];
        reminders = (raw is List) ? List<Map<String, dynamic>>.from(raw) : [];
      } catch (_) {
        reminders = [];
      }
    }
    update();
  }

  Future<void> addReminder({
    required String date,
    String description = '',
    String? notifyStaff,
  }) async {
    isSubmitting = true;
    update();
    final r = await repo.addReminder(
      relType: relType,
      relId: relId,
      date: date,
      description: description,
      notifyStaff: notifyStaff,
    );
    isSubmitting = false;
    if (r.status) {
      CustomSnackBar.success(successList: ['Reminder added']);
      await loadReminders();
    } else {
      CustomSnackBar.error(
          errorList: [r.message.isEmpty ? 'Failed' : r.message]);
      update();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final r = await repo.deleteReminder(reminderId);
    if (r.status) {
      CustomSnackBar.success(successList: ['Reminder deleted']);
      await loadReminders();
    } else {
      CustomSnackBar.error(
          errorList: [r.message.isEmpty ? 'Failed' : r.message]);
    }
  }

  // ── Activity ───────────────────────────────────────────────────────────
  Future<void> loadActivity() async {
    isActivityLoading = true;
    update();
    final r = await repo.getActivity(relType, relId);
    isActivityLoading = false;
    if (r.status) {
      try {
        final raw = jsonDecode(r.responseJson)['data'];
        activity = (raw is List) ? List<Map<String, dynamic>>.from(raw) : [];
      } catch (_) {
        activity = [];
      }
    }
    update();
  }

  // ── Custom fields ──────────────────────────────────────────────────────
  Future<void> loadCustomFields() async {
    isCustomFieldsLoading = true;
    update();
    final r = await repo.getCustomFields(relType, relId);
    isCustomFieldsLoading = false;
    if (r.status) {
      try {
        final raw = jsonDecode(r.responseJson)['data'];
        customFields =
            (raw is List) ? List<Map<String, dynamic>>.from(raw) : [];
      } catch (_) {
        customFields = [];
      }
    }
    update();
  }

  Future<void> saveCustomFields(Map<String, String> values) async {
    isSubmitting = true;
    update();
    final r = await repo.saveCustomFields(
      relType: relType,
      relId: relId,
      values: values,
    );
    isSubmitting = false;
    if (r.status) {
      CustomSnackBar.success(successList: ['Custom fields saved']);
      await loadCustomFields();
    } else {
      CustomSnackBar.error(
          errorList: [r.message.isEmpty ? 'Failed' : r.message]);
      update();
    }
  }

  // ── Attachments ────────────────────────────────────────────────────────
  Future<void> loadAttachments() async {
    isAttachmentsLoading = true;
    update();
    final r = await repo.getAttachments(relType, relId);
    isAttachmentsLoading = false;
    if (r.status) {
      try {
        final raw = jsonDecode(r.responseJson)['data'];
        attachments = (raw is List) ? List<Map<String, dynamic>>.from(raw) : [];
      } catch (_) {
        attachments = [];
      }
    }
    update();
  }

  Future<void> pickAndUploadAttachment() async {
    final res = await FilePicker.pickFiles(withData: false);
    if (res == null || res.files.single.path == null) return;
    isSubmitting = true;
    update();
    final r = await repo.uploadAttachment(
      relType: relType,
      relId: relId,
      filePath: res.files.single.path!,
    );
    isSubmitting = false;
    if (r.status) {
      CustomSnackBar.success(successList: ['File uploaded']);
      await loadAttachments();
    } else {
      CustomSnackBar.error(
          errorList: [r.message.isEmpty ? 'Upload failed' : r.message]);
      update();
    }
  }

  Future<void> deleteAttachment(String id) async {
    final r = await repo.deleteAttachment(id);
    if (r.status) {
      CustomSnackBar.success(successList: ['File deleted']);
      await loadAttachments();
    } else {
      CustomSnackBar.error(
          errorList: [r.message.isEmpty ? 'Failed' : r.message]);
    }
  }
}

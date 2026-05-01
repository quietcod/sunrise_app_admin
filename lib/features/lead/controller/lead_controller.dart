import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/file_download_dialog/download_dialog.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/lead/model/lead_create_model.dart';
import 'package:flutex_admin/features/lead/model/lead_details_model.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/lead/model/sources_model.dart';
import 'package:flutex_admin/features/lead/model/statuses_model.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadController extends GetxController {
  LeadRepo leadRepo;
  LeadController({required this.leadRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  LeadsModel leadsModel = LeadsModel();
  LeadDetailsModel leadDetailsModel = LeadDetailsModel();

  StatusesModel statusesModel = StatusesModel();
  SourcesModel sourcesModel = SourcesModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadLeads();
    isLoading = false;
    update();
  }

  Future<void> loadLeads() async {
    ResponseModel responseModel = await leadRepo.getAllLeads();
    if (responseModel.status) {
      leadsModel = LeadsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      leadsModel = LeadsModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadLeadDetails(leadId) async {
    ResponseModel responseModel = await leadRepo.getLeadDetails(leadId);
    if (responseModel.status) {
      leadDetailsModel =
          LeadDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  bool downloadLoading = false;
  Future<void> downloadAttachment(
      String attachmentType, String attachmentKey) async {
    downloadLoading = true;
    update();

    ResponseModel responseModel =
        await leadRepo.attachmentDownload(attachmentKey);
    if (responseModel.status) {
      showDialog(
        context: Get.context!,
        builder: (context) => DownloadingDialog(
            isImage: true,
            isPdf: false,
            url: attachmentType,
            fileName: attachmentKey),
      );
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    downloadLoading = false;
    update();
  }

  Future<StatusesModel> loadLeadStatuses() async {
    ResponseModel responseModel = await leadRepo.getLeadStatuses();
    return statusesModel =
        StatusesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<SourcesModel> loadLeadSources() async {
    ResponseModel responseModel = await leadRepo.getLeadSources();
    return sourcesModel =
        SourcesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<void> loadLeadUpdateData(leadId) async {
    ResponseModel responseModel = await leadRepo.getLeadDetails(leadId);
    if (responseModel.status) {
      leadDetailsModel =
          LeadDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      sourceController.text = leadDetailsModel.data?.source ?? '';
      statusController.text = leadDetailsModel.data?.status ?? '';
      nameController.text = leadDetailsModel.data?.name ?? '';
      assignedController.text = leadDetailsModel.data?.assigned ?? '';
      valueController.text = leadDetailsModel.data?.leadValue ?? '';
      titleController.text = leadDetailsModel.data?.title ?? '';
      emailController.text = leadDetailsModel.data?.email ?? '';
      websiteController.text = leadDetailsModel.data?.website ?? '';
      phoneNumberController.text = leadDetailsModel.data?.phoneNumber ?? '';
      companyController.text = leadDetailsModel.data?.company ?? '';
      addressController.text = leadDetailsModel.data?.address ?? '';
      cityController.text = leadDetailsModel.data?.city ?? '';
      stateController.text = leadDetailsModel.data?.state ?? '';
      countryController.text = leadDetailsModel.data?.country ?? '';
      defaultLanguageController.text =
          leadDetailsModel.data?.defaultLanguage ?? '';
      descriptionController.text = leadDetailsModel.data?.description ?? '';
      //customContactDateController.text = leadDetailsModel.data?.lastContact ?? '';
      //contactedTodayController.text = leadDetailsModel.data?.lastContact ?? '';
      isPublicController.text = leadDetailsModel.data?.isPublic ?? '';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  TextEditingController sourceController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController assignedController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController defaultLanguageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController isPublicController = TextEditingController();

  FocusNode sourceFocusNode = FocusNode();
  FocusNode statusFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode assignedFocusNode = FocusNode();
  FocusNode tagsFocusNode = FocusNode();
  FocusNode valueFocusNode = FocusNode();
  FocusNode titleFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode websiteFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode companyFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode defaultLanguageFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode isPublicFocusNode = FocusNode();

  Future<void> submitLead({String? leadId, bool isUpdate = false}) async {
    String source = sourceController.text.toString();
    String status = statusController.text.toString();
    String name = nameController.text.toString();
    String assigned = assignedController.text.toString();
    String tags = tagsController.text.toString();
    String value = valueController.text.toString();
    String title = titleController.text.toString();
    String email = emailController.text.toString();
    String website = websiteController.text.toString();
    String phoneNumber = phoneNumberController.text.toString();
    String company = companyController.text.toString();
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String state = stateController.text.toString();
    String country = countryController.text.toString();
    String defaultLanguage = defaultLanguageController.text.toString();
    String description = descriptionController.text.toString();
    String isPublic = isPublicController.text.toString();

    if (source.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.pleaseSelectSource.tr]);
      return;
    }
    if (status.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterStatus.tr]);
      return;
    }
    if (name.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterName.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    LeadCreateModel leadModel = LeadCreateModel(
      source: source,
      status: status,
      name: name,
      assigned: assigned,
      tags: tags,
      value: value,
      title: title,
      email: email,
      website: website,
      phoneNumber: phoneNumber,
      company: company,
      address: address,
      city: city,
      state: state,
      country: country,
      defaultLanguage: defaultLanguage,
      description: description,
      isPublic: isPublic,
    );

    ResponseModel responseModel = await leadRepo.createLead(leadModel,
        leadId: leadId, isUpdate: isUpdate);
    if (responseModel.status) {
      clearData();
      Get.back();
      if (isUpdate) await loadLeadDetails(leadId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Lead
  Future<void> deleteLead(leadId) async {
    ResponseModel responseModel = await leadRepo.deleteLead(leadId);

    isSubmitLoading = true;
    update();

    if (responseModel.status) {
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [(responseModel.message.tr)]);
    }

    isSubmitLoading = false;
    update();
  }

  Future<void> markAsLost(String leadId, bool lost) async {
    isSubmitLoading = true;
    update();
    final response = await leadRepo.markAsLost(leadId, lost);
    isSubmitLoading = false;
    if (response.status) {
      await loadLeadDetails(leadId);
      CustomSnackBar.success(successList: [
        lost ? 'Lead marked as lost' : 'Lead unmarked as lost'
      ]);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> markAsJunk(String leadId, bool junk) async {
    isSubmitLoading = true;
    update();
    final response = await leadRepo.markAsJunk(leadId, junk);
    isSubmitLoading = false;
    if (response.status) {
      await loadLeadDetails(leadId);
      CustomSnackBar.success(successList: [
        junk ? 'Lead marked as junk' : 'Lead unmarked as junk'
      ]);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> convertToCustomer(String leadId) async {
    isSubmitLoading = true;
    update();

    final response = await leadRepo.convertLeadToCustomer(leadId);
    if (response.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.convertedSuccessfully.tr]);
      Get.back();
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Search Leads
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchLead() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await leadRepo.searchLead(keysearch);
    if (responseModel.status) {
      leadsModel = LeadsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  bool isSearch = false;
  void changeSearchIcon() {
    isSearch = !isSearch;
    update();

    if (!isSearch) {
      searchController.clear();
      initialData();
    }
  }

  void clearData() {
    isLoading = false;
    isSubmitLoading = false;
    sourceController.text = '';
    statusController.text = '';
    nameController.text = '';
    assignedController.text = '';
    tagsController.text = '';
    valueController.text = '';
    titleController.text = '';
    emailController.text = '';
    websiteController.text = '';
    phoneNumberController.text = '';
    companyController.text = '';
    addressController.text = '';
    cityController.text = '';
    stateController.text = '';
    countryController.text = '';
    defaultLanguageController.text = '';
    descriptionController.text = '';
    isPublicController.text = '';
  }

  // ── Lead notes ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> leadNotes = [];
  bool isNotesLoading = false;

  Future<void> loadLeadNotes(String leadId) async {
    isNotesLoading = true;
    update();
    final response = await leadRepo.getLeadNotes(leadId);
    isNotesLoading = false;
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        leadNotes = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } catch (_) {
        leadNotes = [];
      }
    } else {
      leadNotes = [];
    }
    update();
  }

  Future<void> addLeadNote(String leadId, String note) async {
    if (note.trim().isEmpty) return;
    final response = await leadRepo.addLeadNote(leadId, note.trim());
    if (response.status) {
      await loadLeadNotes(leadId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> updateLeadNote(String leadId, String noteId, String note) async {
    if (note.trim().isEmpty) return;
    final response = await leadRepo.updateLeadNote(noteId, note.trim());
    if (response.status) {
      await loadLeadNotes(leadId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> deleteLeadNote(String leadId, String noteId) async {
    final response = await leadRepo.deleteLeadNote(noteId);
    if (response.status) {
      await loadLeadNotes(leadId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Lead activity log ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> leadActivityList = [];
  bool isActivityLoading = false;

  Future<void> loadLeadActivity(String leadId) async {
    isActivityLoading = true;
    update();
    final response = await leadRepo.getLeadActivity(leadId);
    isActivityLoading = false;
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        leadActivityList = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } catch (_) {
        leadActivityList = [];
      }
    } else {
      leadActivityList = [];
    }
    update();
  }

  // ── Lead reminders ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> leadRemindersList = [];
  bool isRemindersLoading = false;
  List<StaffMember> allStaffList = [];

  Future<void> loadLeadReminders(String leadId) async {
    isRemindersLoading = true;
    update();
    final response = await leadRepo.getLeadReminders(leadId);
    isRemindersLoading = false;
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        leadRemindersList = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } catch (_) {
        leadRemindersList = [];
      }
    } else {
      leadRemindersList = [];
    }
    update();
  }

  Future<List<StaffMember>> loadAllStaff() async {
    if (allStaffList.isNotEmpty) return allStaffList;
    final response = await leadRepo.apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.staffUrl}',
      Method.getMethod,
      null,
      passHeader: true,
    );
    if (response.status) {
      final model = StaffListModel.fromJson(jsonDecode(response.responseJson));
      allStaffList = model.data ?? [];
    }
    return allStaffList;
  }

  Future<void> addLeadReminder(String leadId, String date, String description,
      String notifyStaff) async {
    final response =
        await leadRepo.addLeadReminder(leadId, date, description, notifyStaff);
    if (response.status) {
      await loadLeadReminders(leadId);
      CustomSnackBar.success(successList: ['Reminder added']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to add reminder'
      ]);
    }
  }

  Future<void> deleteLeadReminder(String leadId, String reminderId) async {
    final response = await leadRepo.deleteLeadReminder(reminderId);
    if (response.status) {
      await loadLeadReminders(leadId);
      CustomSnackBar.success(successList: ['Reminder deleted']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ??
            'Failed to delete reminder'
      ]);
    }
  }

  // ── Lead sources admin CRUD ───────────────────────────────────────────────
  List<Map<String, dynamic>> leadSourcesAdminList = [];
  bool isSourcesAdminLoading = false;
  bool isSourcesSubmitting = false;

  Future<void> loadLeadSourcesAdmin() async {
    isSourcesAdminLoading = true;
    update();
    final response = await leadRepo.getLeadSourcesAdmin();
    isSourcesAdminLoading = false;
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        leadSourcesAdminList = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } catch (_) {
        leadSourcesAdminList = [];
      }
    } else {
      leadSourcesAdminList = [];
    }
    update();
  }

  Future<void> addLeadSource(String name) async {
    if (name.trim().isEmpty) return;
    isSourcesSubmitting = true;
    update();
    final response = await leadRepo.addLeadSource(name.trim());
    isSourcesSubmitting = false;
    if (response.status) {
      await loadLeadSourcesAdmin();
      CustomSnackBar.success(successList: ['Source added']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> editLeadSource(String id, String name) async {
    if (name.trim().isEmpty) return;
    isSourcesSubmitting = true;
    update();
    final response = await leadRepo.updateLeadSource(id, name.trim());
    isSourcesSubmitting = false;
    if (response.status) {
      await loadLeadSourcesAdmin();
      CustomSnackBar.success(successList: ['Source updated']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> deleteLeadSourceAdmin(String id) async {
    final response = await leadRepo.deleteLeadSource(id);
    if (response.status) {
      await loadLeadSourcesAdmin();
      CustomSnackBar.success(successList: ['Source deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Lead statuses admin CRUD ──────────────────────────────────────────────
  List<Map<String, dynamic>> leadStatusesAdminList = [];
  bool isStatusesAdminLoading = false;
  bool isStatusesSubmitting = false;

  Future<void> loadLeadStatusesAdmin() async {
    isStatusesAdminLoading = true;
    update();
    final response = await leadRepo.getLeadStatusesAdmin();
    isStatusesAdminLoading = false;
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        leadStatusesAdminList = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } catch (_) {
        leadStatusesAdminList = [];
      }
    } else {
      leadStatusesAdminList = [];
    }
    update();
  }

  Future<void> addLeadStatus(String name, String color) async {
    if (name.trim().isEmpty) return;
    isStatusesSubmitting = true;
    update();
    final response = await leadRepo.addLeadStatus(name.trim(), color);
    isStatusesSubmitting = false;
    if (response.status) {
      await loadLeadStatusesAdmin();
      CustomSnackBar.success(successList: ['Status added']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> editLeadStatus(String id, String name, String color) async {
    if (name.trim().isEmpty) return;
    isStatusesSubmitting = true;
    update();
    final response = await leadRepo.updateLeadStatus(id, name.trim(), color);
    isStatusesSubmitting = false;
    if (response.status) {
      await loadLeadStatusesAdmin();
      CustomSnackBar.success(successList: ['Status updated']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> deleteLeadStatusAdmin(String id) async {
    final response = await leadRepo.deleteLeadStatus(id);
    if (response.status) {
      await loadLeadStatusesAdmin();
      CustomSnackBar.success(successList: ['Status deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Inline status update (kanban drag & drop) ─────────────────────────────
  Future<bool> updateLeadStatusInline(String leadId, String statusId) async {
    final response = await leadRepo.updateLeadStatusOnly(leadId, statusId);
    if (response.status) {
      // Optimistically update local list so kanban re-renders.
      final list = leadsModel.data ?? [];
      String? newName;
      String? newColor;
      for (final s in leadStatusesAdminList) {
        if (s['id']?.toString() == statusId) {
          newName = s['name']?.toString();
          newColor = s['color']?.toString();
          break;
        }
      }
      for (var i = 0; i < list.length; i++) {
        if (list[i].id == leadId) {
          final json = list[i].toJson();
          json['status'] = statusId;
          if (newName != null) json['status_name'] = newName;
          if (newColor != null) json['color'] = newColor;
          json['last_status_change'] = DateTime.now().toIso8601String();
          list[i] = Lead.fromJson(json);
          break;
        }
      }
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message]);
      return false;
    }
  }

  // ── Bulk actions ──────────────────────────────────────────────────────────
  bool isSelectionMode = false;
  Set<String> selectedLeadIds = <String>{};

  void enterSelectionMode(String leadId) {
    isSelectionMode = true;
    selectedLeadIds = {leadId};
    update();
  }

  void toggleLeadSelection(String leadId) {
    if (selectedLeadIds.contains(leadId)) {
      selectedLeadIds.remove(leadId);
    } else {
      selectedLeadIds.add(leadId);
    }
    if (selectedLeadIds.isEmpty) isSelectionMode = false;
    update();
  }

  void clearSelection() {
    isSelectionMode = false;
    selectedLeadIds.clear();
    update();
  }

  Future<void> bulkDeleteLeads() async {
    if (selectedLeadIds.isEmpty) return;
    final ids = selectedLeadIds.toList();
    int success = 0;
    int failed = 0;
    isSubmitLoading = true;
    update();
    for (final id in ids) {
      final r = await leadRepo.deleteLead(id);
      if (r.status) {
        success++;
      } else {
        failed++;
      }
    }
    isSubmitLoading = false;
    clearSelection();
    await initialData(shouldLoad: false);
    CustomSnackBar.success(
        successList: ['Deleted $success of ${ids.length} leads']);
    if (failed > 0) {
      CustomSnackBar.error(errorList: ['$failed delete(s) failed']);
    }
  }

  Future<void> bulkUpdateStatus(String statusId) async {
    if (selectedLeadIds.isEmpty || statusId.isEmpty) return;
    final ids = selectedLeadIds.toList();
    int success = 0;
    int failed = 0;
    isSubmitLoading = true;
    update();
    for (final id in ids) {
      final r = await leadRepo.updateLeadStatusOnly(id, statusId);
      if (r.status) {
        success++;
      } else {
        failed++;
      }
    }
    isSubmitLoading = false;
    clearSelection();
    await initialData(shouldLoad: false);
    CustomSnackBar.success(
        successList: ['Updated $success of ${ids.length} leads']);
    if (failed > 0) {
      CustomSnackBar.error(errorList: ['$failed update(s) failed']);
    }
  }

  // ── Download all attachments for a lead ───────────────────────────────────
  Future<void> downloadAllLeadAttachments() async {
    final list = leadDetailsModel.data?.attachments ?? [];
    if (list.isEmpty) {
      CustomSnackBar.error(errorList: ['No attachments to download']);
      return;
    }
    int success = 0;
    int failed = 0;
    for (final a in list) {
      final key = a.attachmentKey ?? '';
      if (key.isEmpty) {
        failed++;
        continue;
      }
      final r = await leadRepo.attachmentDownload(key);
      if (r.status) {
        success++;
      } else {
        failed++;
      }
    }
    CustomSnackBar.success(
        successList: ['Queued $success of ${list.length} downloads']);
    if (failed > 0) {
      CustomSnackBar.error(errorList: ['$failed download(s) failed']);
    }
  }

  // ── Import leads from CSV ─────────────────────────────────────────────────
  bool isImporting = false;
  int importTotal = 0;
  int importDone = 0;
  int importFailed = 0;

  /// Parse a single CSV line, supporting double-quoted fields with embedded
  /// commas and escaped quotes ("").
  List<String> _parseCsvLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (inQuotes) {
        if (c == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(c);
        }
      } else {
        if (c == ',') {
          out.add(buf.toString());
          buf.clear();
        } else if (c == '"') {
          inQuotes = true;
        } else {
          buf.write(c);
        }
      }
    }
    out.add(buf.toString());
    return out;
  }

  /// Returns parsed rows (header + body) from raw CSV text.
  List<List<String>> parseCsv(String csvText) {
    final lines = csvText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    return lines.map(_parseCsvLine).toList();
  }

  Future<void> importLeadsFromCsv({
    required List<List<String>> rows,
    required Map<String, int> columnMap,
    required String defaultStatusId,
    required String defaultSourceId,
  }) async {
    if (rows.length < 2) {
      CustomSnackBar.error(errorList: ['CSV has no data rows']);
      return;
    }
    isImporting = true;
    importTotal = rows.length - 1;
    importDone = 0;
    importFailed = 0;
    update();

    String getCol(List<String> row, String key) {
      final idx = columnMap[key];
      if (idx == null || idx < 0 || idx >= row.length) return '';
      return row[idx].trim();
    }

    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      final name = getCol(row, 'name');
      if (name.isEmpty) {
        importFailed++;
        importDone++;
        update();
        continue;
      }
      final lead = LeadCreateModel(
        source: getCol(row, 'source').isEmpty
            ? defaultSourceId
            : getCol(row, 'source'),
        status: getCol(row, 'status').isEmpty
            ? defaultStatusId
            : getCol(row, 'status'),
        name: name,
        assigned: getCol(row, 'assigned'),
        tags: getCol(row, 'tags'),
        value: getCol(row, 'lead_value'),
        title: getCol(row, 'title'),
        email: getCol(row, 'email'),
        website: getCol(row, 'website'),
        phoneNumber: getCol(row, 'phonenumber'),
        company: getCol(row, 'company'),
        address: getCol(row, 'address'),
        city: getCol(row, 'city'),
        state: getCol(row, 'state'),
        country: getCol(row, 'country'),
        defaultLanguage: getCol(row, 'default_language'),
        description: getCol(row, 'description'),
        isPublic: '0',
      );
      final response = await leadRepo.createLead(lead);
      if (response.status) {
        importDone++;
      } else {
        importFailed++;
        importDone++;
      }
      update();
    }

    isImporting = false;
    update();
    await initialData(shouldLoad: false);
    final successCount = importTotal - importFailed;
    CustomSnackBar.success(
        successList: ['Imported $successCount of $importTotal leads']);
    if (importFailed > 0) {
      CustomSnackBar.error(errorList: ['$importFailed row(s) failed']);
    }
  }
}

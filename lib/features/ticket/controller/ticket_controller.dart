import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutex_admin/features/ticket/model/departments_model.dart';
import 'package:flutex_admin/features/ticket/model/priorities_model.dart';
import 'package:flutex_admin/features/ticket/model/services_model.dart';
import 'package:flutex_admin/features/ticket/model/ticket_create_model.dart';
import 'package:flutex_admin/features/ticket/model/staff_member.dart';
import 'package:flutex_admin/features/ticket/model/ticket_details_model.dart';
import 'package:flutex_admin/features/ticket/model/ticket_model.dart';
import 'package:flutex_admin/features/ticket/repo/ticket_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketController extends GetxController {
  TicketRepo ticketRepo;
  TicketController({required this.ticketRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  TicketsModel ticketsModel = TicketsModel();
  TicketDetailsModel ticketDetailsModel = TicketDetailsModel();

  CustomersModel customersModel = CustomersModel();
  String selectedCustomer = '';
  ContactsModel contactsModel = ContactsModel();
  DepartmentModel departmentModel = DepartmentModel();
  PriorityModel priorityModel = PriorityModel();
  ServiceModel serviceModel = ServiceModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    if (canAssignTicketToStaff && assignableStaff.isEmpty) {
      unawaited(loadAssignableStaff());
    }
    await loadTickets();
    isLoading = false;
    update();
  }

  Future<void> loadTickets() async {
    ResponseModel responseModel = await ticketRepo.getAllTickets();
    if (responseModel.status) {
      ticketsModel =
          TicketsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadTicketDetails(ticketId) async {
    ResponseModel responseModel = await ticketRepo.getTicketDetails(ticketId);
    if (responseModel.status) {
      ticketDetailsModel =
          TicketDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<CustomersModel> loadCustomers() async {
    ResponseModel responseModel = await ticketRepo.getAllCustomers();
    return customersModel =
        CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<ContactsModel> loadCustomerContacts(userId) async {
    ResponseModel responseModel = await ticketRepo.getCustomerContacts(userId);
    return contactsModel =
        ContactsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<DepartmentModel> loadDepartments() async {
    ResponseModel responseModel = await ticketRepo.getTicketDepartments();
    return departmentModel =
        DepartmentModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<PriorityModel> loadPriorities() async {
    ResponseModel responseModel = await ticketRepo.getTicketPriorities();
    return priorityModel =
        PriorityModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<ServiceModel> loadServices() async {
    ResponseModel responseModel = await ticketRepo.getTicketServices();
    return serviceModel =
        ServiceModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  TextEditingController subjectController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode subjectFocusNode = FocusNode();
  FocusNode departmentFocusNode = FocusNode();
  FocusNode priorityFocusNode = FocusNode();
  FocusNode serviceFocusNode = FocusNode();
  FocusNode userFocusNode = FocusNode();
  FocusNode contactFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  Future<void> submitTicket(BuildContext context,
      {String? ticketId, bool isUpdate = false}) async {
    String subject = subjectController.text.toString();
    String department = departmentController.text.toString();
    String priority = priorityController.text.toString();
    String service = serviceController.text.toString();
    String user = userController.text.toString();
    String contact = contactController.text.toString();
    String description = descriptionController.text.toString();

    if (subject.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterSubject.tr]);
      return;
    }
    if (user.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.pleaseSelectClient.tr]);
      return;
    }
    if (contact.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.pleaseSelectContact.tr]);
      return;
    }
    if (description.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterDescription.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    TicketCreateModel ticketModel = TicketCreateModel(
      subject: subject,
      department: department,
      userId: user,
      contactId: contact,
      priority: priority,
      service: service,
      description: description,
    );

    ResponseModel responseModel = await ticketRepo.createTicket(ticketModel,
        ticketId: ticketId, isUpdate: isUpdate);
    if (responseModel.status) {
      Get.back();
      if (isUpdate) await loadTicketDetails(ticketId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  Future<void> loadTicketUpdateData(ticketId) async {
    ResponseModel responseModel = await ticketRepo.getTicketDetails(ticketId);
    if (responseModel.status) {
      ticketDetailsModel =
          TicketDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      subjectController.text = ticketDetailsModel.data?.subject ?? '';
      departmentController.text = ticketDetailsModel.data?.departmentId ?? '';
      priorityController.text = ticketDetailsModel.data?.priorityId ?? '';
      serviceController.text = ticketDetailsModel.data?.serviceId ?? '';
      userController.text = ticketDetailsModel.data?.userId ?? '';
      selectedCustomer = ticketDetailsModel.data?.userId ?? '';
      contactController.text = ticketDetailsModel.data?.contactId ?? '';
      descriptionController.text = ticketDetailsModel.data?.message ?? '';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  // Delete Ticket
  Future<void> deleteTicket(ticketId) async {
    ResponseModel responseModel = await ticketRepo.deleteTicket(ticketId);
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

  // Search Tickets
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchTicket() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await ticketRepo.searchTicket(keysearch);
    if (responseModel.status) {
      ticketsModel =
          TicketsModel.fromJson(jsonDecode(responseModel.responseJson));
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
    selectedCustomer = '';
    subjectController.text = '';
    departmentController.text = '';
    priorityController.text = '';
    serviceController.text = '';
    userController.text = '';
    contactController.text = '';
    descriptionController.text = '';
  }

  List<StaffMember> assignableStaff = <StaffMember>[];
  bool isAssignableStaffLoading = false;
  final Map<String, int?> selectedAssigneeByTicket = <String, int?>{};
  final Set<String> assigningTicketIds = <String>{};

  bool get canAssignTicketToStaff {
    final staffId = ticketRepo.apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.userIdKey) ??
        '';
    final isAdminLike = staffId.trim() == '-1';
    if (isAdminLike) {
      return true;
    }

    if (!Get.isRegistered<DashboardController>()) {
      return false;
    }

    final dashboard = Get.find<DashboardController>().homeModel;
    return dashboard.staffPermissions?.ticketsEdit == true;
  }

  bool isTicketAssigning(String? ticketId) {
    if (ticketId == null || ticketId.isEmpty) return false;
    return assigningTicketIds.contains(ticketId);
  }

  int? selectedAssigneeForTicket(Ticket ticket) {
    if (selectedAssigneeByTicket.containsKey(ticket.id)) {
      return selectedAssigneeByTicket[ticket.id];
    }
    return int.tryParse((ticket.assigned ?? '').trim());
  }

  void setSelectedAssigneeForTicket(String ticketId, int? staffId) {
    if (ticketId.isEmpty) return;
    selectedAssigneeByTicket[ticketId] = staffId;
    update();
  }

  Future<void> loadAssignableStaff({bool force = false}) async {
    if (!canAssignTicketToStaff) return;
    if (!force && assignableStaff.isNotEmpty) return;

    isAssignableStaffLoading = true;
    update();

    final responseModel = await ticketRepo.getAssignableStaff();
    if (responseModel.status) {
      final parsed = _parseAssignableStaff(responseModel.responseJson);
      if (parsed.isNotEmpty) {
        assignableStaff = parsed;
      } else {
        CustomSnackBar.error(errorList: [
          'Staff list is unavailable. Check the staff-members API response.'
        ]);
      }
    } else {
      final message = responseModel.message.trim().isEmpty
          ? 'Unable to load staff members'
          : responseModel.message;
      CustomSnackBar.error(errorList: [message]);
    }

    isAssignableStaffLoading = false;
    update();
  }

  Future<void> assignTicketToStaff({
    required String ticketId,
    required int? staffId,
  }) async {
    if (!canAssignTicketToStaff) {
      CustomSnackBar.error(
          errorList: ['You do not have permission to assign tickets']);
      return;
    }

    if (ticketId.trim().isEmpty) {
      CustomSnackBar.error(errorList: ['Invalid ticket id']);
      return;
    }

    if (staffId == null) {
      CustomSnackBar.error(errorList: ['Please select a staff member']);
      return;
    }

    assigningTicketIds.add(ticketId);
    update();

    final responseModel =
        await ticketRepo.assignTicketToStaff(ticketId, staffId);

    assigningTicketIds.remove(ticketId);

    if (responseModel.status) {
      selectedAssigneeByTicket[ticketId] = staffId;
      await loadTickets();
      final message = responseModel.message.trim().isEmpty ||
              responseModel.message.trim().toLowerCase() == 'ok'
          ? 'Ticket assigned successfully'
          : responseModel.message.tr;
      CustomSnackBar.success(successList: [message]);
    } else {
      final message = responseModel.message.trim().isEmpty
          ? 'Unable to assign ticket'
          : responseModel.message.tr;
      CustomSnackBar.error(errorList: [message]);
    }

    update();
  }

  List<StaffMember> _parseAssignableStaff(String responseJson) {
    try {
      final decoded = jsonDecode(responseJson);
      final rawItems = _extractStaffEntries(decoded);

      return rawItems
          .map(StaffMember.fromJson)
          .where((staff) => staff.staffId > 0)
          .toList();
    } catch (_) {
      return <StaffMember>[];
    }
  }

  List<Map<String, dynamic>> _extractStaffEntries(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (decoded is! Map) {
      return <Map<String, dynamic>>[];
    }

    final root = Map<String, dynamic>.from(decoded);
    final candidates = <dynamic>[
      root['data'],
      root['staff'],
      root['staffs'],
      root['members'],
      root['items'],
      root['results'],
      root,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  // Status Change Logic
  bool isStatusChanging = false;

  Future<void> changeStatus(String ticketId, String newStatus) async {
    isStatusChanging = true;
    update();

    ResponseModel responseModel =
        await ticketRepo.changeTicketStatus(ticketId, newStatus);

    if (responseModel.status) {
      await loadTicketDetails(ticketId);
    }

    isStatusChanging = false;
    update();
  }

  // Reply Logic
  bool isReplySubmitting = false;

  Future<bool> addReply(String ticketId, String message) async {
    if (message.trim().isEmpty) {
      return false;
    }

    isReplySubmitting = true;
    update();

    ResponseModel responseModel =
        await ticketRepo.addTicketReply(ticketId, message);

    isReplySubmitting = false;

    if (responseModel.status) {
      await loadTicketDetails(ticketId);
      update();
      return true;
    } else {
      update();
      return false;
    }
  }

  // OTP Close Ticket Logic
  bool isOtpRequesting = false;
  bool isOtpVerifying = false;
  bool isOtpScreenShowing = false;
  String? otpErrorMessage;

  // Send OTP to different number
  bool isSendingOtpToNumber = false;

  Future<bool> sendOtpToDifferentNumber(String ticketId, String phone) async {
    isSendingOtpToNumber = true;
    update();

    ResponseModel responseModel =
        await ticketRepo.sendOtpToDifferentNumber(ticketId, phone);

    isSendingOtpToNumber = false;

    if (responseModel.status) {
      final msg = responseModel.message.trim();
      CustomSnackBar.success(successList: [
        (msg.isNotEmpty && msg != 'null') ? msg : 'OTP sent to $phone'
      ]);
      update();
      return true;
    } else {
      final msg = responseModel.message.trim();
      CustomSnackBar.error(errorList: [
        (msg.isNotEmpty && msg != 'null')
            ? msg.tr
            : 'Failed to send OTP. Please check the number and try again.'
      ]);
      update();
      return false;
    }
  }

  // Close Without OTP Logic
  bool isClosingWithoutOtp = false;

  /// True if the currently logged-in staff member has permission to close
  /// tickets without requiring an OTP from the customer.
  bool get canCloseWithoutOtp =>
      ticketRepo.apiClient.sharedPreferences
          .getBool(SharedPreferenceHelper.canCloseWithoutOtpKey) ??
      false;

  Future<void> closeTicketWithoutOtp(String ticketId) async {
    isClosingWithoutOtp = true;
    update();

    ResponseModel responseModel =
        await ticketRepo.closeTicketWithoutOtp(ticketId);

    isClosingWithoutOtp = false;

    if (responseModel.status) {
      await loadTicketDetails(ticketId);
      CustomSnackBar.success(
          successList: ['Ticket closed successfully (no OTP required).']);
      update();
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
      update();
    }
  }

  Future<bool> requestCloseOtp(String ticketId) async {
    isOtpRequesting = true;
    otpErrorMessage = null;
    update();

    ResponseModel responseModel = await ticketRepo.requestCloseOtp(ticketId);

    isOtpRequesting = false;

    if (responseModel.status) {
      // Backend auto-closes the ticket when the customer has no phone number
      // and returns auto_closed: true — skip the OTP screen in that case.
      bool autoClosed = false;
      try {
        final decoded = jsonDecode(responseModel.responseJson);
        autoClosed = decoded['auto_closed'] == true;
      } catch (_) {}

      if (autoClosed) {
        CustomSnackBar.success(successList: [
          'Ticket closed automatically (no phone number on file).'
        ]);
        await loadTicketDetails(ticketId);
        update();
        return true;
      }

      isOtpScreenShowing = true;
      update();
      return true;
    } else {
      update();
      return false;
    }
  }

  Future<bool> resendCloseOtp(String ticketId) async {
    isOtpRequesting = true;
    otpErrorMessage = null;
    update();

    ResponseModel responseModel = await ticketRepo.resendTicketOtp(ticketId);

    isOtpRequesting = false;

    if (responseModel.status) {
      CustomSnackBar.success(successList: [responseModel.message]);
      update();
      return true;
    } else {
      update();
      return false;
    }
  }

  Future<bool> verifyCloseOtp(String ticketId, String otp) async {
    if (otp.trim().isEmpty) {
      otpErrorMessage = 'Please enter OTP';
      update();
      return false;
    }

    isOtpVerifying = true;
    otpErrorMessage = null;
    update();

    ResponseModel responseModel =
        await ticketRepo.verifyCloseOtp(ticketId, otp);

    isOtpVerifying = false;

    if (responseModel.status) {
      isOtpScreenShowing = false;
      await loadTicketDetails(ticketId);
      update();
      return true;
    } else {
      otpErrorMessage = 'Invalid OTP. Please try again.';
      update();
      return false;
    }
  }

  void cancelOtpVerification() {
    isOtpScreenShowing = false;
    otpErrorMessage = null;
    update();
  }

  Future<bool> editReply(
      String ticketId, String replyId, String message) async {
    if (message.trim().isEmpty) return false;
    isReplySubmitting = true;
    update();
    final response = await ticketRepo.editTicketReply(replyId, message);
    isReplySubmitting = false;
    if (response.status) {
      await loadTicketDetails(ticketId);
      CustomSnackBar.success(successList: ['Reply updated']);
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
      update();
      return false;
    }
  }

  Future<bool> deleteReply(String ticketId, String replyId) async {
    final response = await ticketRepo.deleteTicketReply(replyId);
    if (response.status) {
      await loadTicketDetails(ticketId);
      CustomSnackBar.success(successList: ['Reply deleted']);
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
      update();
      return false;
    }
  }

  // ── Predefined replies ────────────────────────────────────────────────────
  List<Map<String, dynamic>> predefinedReplies = [];
  bool isPredefinedRepliesLoaded = false;

  Future<void> loadPredefinedReplies() async {
    if (isPredefinedRepliesLoaded) return;
    final response = await ticketRepo.getPredefinedReplies();
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final data = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
      if (data is List) {
        predefinedReplies = data
            .whereType<Map>()
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        predefinedReplies = [];
      }
      isPredefinedRepliesLoaded = true;
    }
    update();
  }

  // ── Priorities Admin ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> prioritiesAdminList = [];
  bool isPrioritiesAdminLoading = false;

  Future<void> loadPrioritiesAdmin() async {
    isPrioritiesAdminLoading = true;
    update();
    final resp = await ticketRepo.getPrioritiesAdmin();
    if (resp.status) {
      final decoded = jsonDecode(resp.responseJson);
      final data = decoded['data'] as List? ?? [];
      prioritiesAdminList =
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    isPrioritiesAdminLoading = false;
    update();
  }

  Future<void> addPriority(String name) async {
    final resp = await ticketRepo.addPriority(name);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Priority added']);
      await loadPrioritiesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> editPriority(String id, String name) async {
    final resp = await ticketRepo.updatePriority(id, name);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Priority updated']);
      await loadPrioritiesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> deletePriority(String id) async {
    final resp = await ticketRepo.deletePriority(id);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Priority deleted']);
      await loadPrioritiesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  // ── Ticket Statuses Admin ─────────────────────────────────────────────────
  List<Map<String, dynamic>> ticketStatusesAdminList = [];
  bool isTicketStatusesAdminLoading = false;

  Future<void> loadTicketStatusesAdmin() async {
    isTicketStatusesAdminLoading = true;
    update();
    final resp = await ticketRepo.getTicketStatusesAdmin();
    if (resp.status) {
      final decoded = jsonDecode(resp.responseJson);
      final data = decoded['data'] as List? ?? [];
      ticketStatusesAdminList =
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    isTicketStatusesAdminLoading = false;
    update();
  }

  Future<void> addTicketStatusAdmin(String name, String color) async {
    final resp = await ticketRepo.addTicketStatus(name, color);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Status added']);
      await loadTicketStatusesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> editTicketStatusAdmin(
      String id, String name, String color) async {
    final resp = await ticketRepo.updateTicketStatus(id, name, color);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Status updated']);
      await loadTicketStatusesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> deleteTicketStatusAdmin(String id) async {
    final resp = await ticketRepo.deleteTicketStatus(id);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Status deleted']);
      await loadTicketStatusesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  // ── Services Admin ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> servicesAdminList = [];
  bool isServicesAdminLoading = false;

  Future<void> loadServicesAdmin() async {
    isServicesAdminLoading = true;
    update();
    final resp = await ticketRepo.getServicesAdmin();
    if (resp.status) {
      final decoded = jsonDecode(resp.responseJson);
      final data = decoded['data'] as List? ?? [];
      servicesAdminList =
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    isServicesAdminLoading = false;
    update();
  }

  Future<void> addService(String name) async {
    final resp = await ticketRepo.addService(name);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Service added']);
      await loadServicesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> editService(String id, String name) async {
    final resp = await ticketRepo.updateService(id, name);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Service updated']);
      await loadServicesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> deleteService(String id) async {
    final resp = await ticketRepo.deleteService(id);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Service deleted']);
      await loadServicesAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  // ── Spam Filters Admin ────────────────────────────────────────────────────
  List<Map<String, dynamic>> spamFiltersAdminList = [];
  bool isSpamFiltersAdminLoading = false;

  Future<void> loadSpamFiltersAdmin() async {
    isSpamFiltersAdminLoading = true;
    update();
    final resp = await ticketRepo.getSpamFiltersAdmin();
    if (resp.status) {
      final decoded = jsonDecode(resp.responseJson);
      final data = decoded['data'] as List? ?? [];
      spamFiltersAdminList =
          data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    isSpamFiltersAdminLoading = false;
    update();
  }

  Future<void> addSpamFilter(String type, String value) async {
    final resp = await ticketRepo.addSpamFilter(type, value);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Spam filter added']);
      await loadSpamFiltersAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> editSpamFilter(String id, String type, String value) async {
    final resp = await ticketRepo.updateSpamFilter(id, type, value);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Spam filter updated']);
      await loadSpamFiltersAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  Future<void> deleteSpamFilter(String id) async {
    final resp = await ticketRepo.deleteSpamFilter(id);
    if (resp.status) {
      CustomSnackBar.success(successList: ['Spam filter deleted']);
      await loadSpamFiltersAdmin();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }

  // ── Bulk Actions ──────────────────────────────────────────────────────────
  Set<String> selectedTicketIds = {};
  bool isBulkMode = false;

  void toggleBulkMode() {
    isBulkMode = !isBulkMode;
    if (!isBulkMode) selectedTicketIds.clear();
    update();
  }

  void toggleTicketSelection(String id) {
    if (selectedTicketIds.contains(id)) {
      selectedTicketIds.remove(id);
    } else {
      selectedTicketIds.add(id);
    }
    update();
  }

  void selectAllTickets(List<String> ids) {
    selectedTicketIds = Set.from(ids);
    update();
  }

  void clearSelection() {
    selectedTicketIds.clear();
    isBulkMode = false;
    update();
  }

  Future<void> bulkDeleteSelected() async {
    if (selectedTicketIds.isEmpty) return;
    final ids = List<String>.from(selectedTicketIds);
    final resp = await ticketRepo.bulkDeleteTickets(ids);
    if (resp.status) {
      CustomSnackBar.success(successList: ['${ids.length} ticket(s) deleted']);
      clearSelection();
      await loadTickets();
    } else {
      CustomSnackBar.error(errorList: [resp.message.tr]);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/ticket/model/departments_model.dart';
import 'package:flutex_admin/features/ticket/model/priorities_model.dart';
import 'package:flutex_admin/features/ticket/model/services_model.dart';
import 'package:flutex_admin/features/ticket/model/ticket_create_model.dart';
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
}

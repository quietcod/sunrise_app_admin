import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/currencies_model.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/countries_model.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';
import 'package:flutex_admin/features/customer/model/contact_post_model.dart';
import 'package:flutex_admin/features/customer/model/customer_details_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/customer/model/customer_post_model.dart';
import 'package:flutex_admin/features/customer/model/groups_model.dart';
import 'package:flutex_admin/features/customer/repo/customer_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CustomerController extends GetxController {
  CustomerRepo customerRepo;
  CustomerController({required this.customerRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  CustomersModel customersModel = CustomersModel();
  CustomerDetailsModel customerDetailsModel = CustomerDetailsModel();
  ContactsModel customerContactsModel = ContactsModel();
  GroupsModel groupsModel = GroupsModel();
  CountriesModel countriesModel = CountriesModel();
  CurrenciesModel currenciesModel = CurrenciesModel();
  List<String> groupsList = [];

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadCustomers();
    isLoading = false;
    update();
  }

  Future<void> loadCustomers() async {
    ResponseModel responseModel = await customerRepo.getAllCustomers();
    if (responseModel.status) {
      customersModel =
          CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      customersModel = CustomersModel();
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadCustomerDetails(customerId) async {
    ResponseModel responseModel =
        await customerRepo.getCustomerDetails(customerId);
    if (responseModel.status) {
      customerDetailsModel =
          CustomerDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  Future<GroupsModel> loadCustomerGroups() async {
    ResponseModel responseModel = await customerRepo.getCustomerGroups();
    return groupsModel =
        GroupsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<CountriesModel> loadCountries() async {
    ResponseModel responseModel = await customerRepo.getCountries();
    return countriesModel =
        CountriesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<CurrenciesModel> loadCurrencies() async {
    ResponseModel responseModel = await customerRepo.getCurrencies();
    return currenciesModel =
        CurrenciesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<void> loadCustomerUpdateData(customerId) async {
    ResponseModel responseModel =
        await customerRepo.getCustomerDetails(customerId);
    if (responseModel.status) {
      customerDetailsModel =
          CustomerDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      companyController.text = customerDetailsModel.data?.company ?? '';
      vatController.text = customerDetailsModel.data?.vat ?? '';
      phoneNumberController.text = customerDetailsModel.data?.phoneNumber ?? '';
      websiteController.text = customerDetailsModel.data?.website ?? '';
      currencyController.text =
          customerDetailsModel.data?.defaultCurrency ?? '';
      addressController.text = customerDetailsModel.data?.address ?? '';
      cityController.text = customerDetailsModel.data?.city ?? '';
      stateController.text = customerDetailsModel.data?.state ?? '';
      zipController.text = customerDetailsModel.data?.zip ?? '';
      countryController.text = customerDetailsModel.data?.country ?? '';

      billingStreetController.text =
          customerDetailsModel.data?.billingStreet ?? '';
      billingCityController.text = customerDetailsModel.data?.billingCity ?? '';
      billingStateController.text =
          customerDetailsModel.data?.billingState ?? '';
      billingZipController.text = customerDetailsModel.data?.billingZip ?? '';
      billingCountryController.text =
          customerDetailsModel.data?.billingCountry ?? '';
      shippingStreetController.text =
          customerDetailsModel.data?.shippingStreet ?? '';
      shippingCityController.text =
          customerDetailsModel.data?.shippingCity ?? '';
      shippingStateController.text =
          customerDetailsModel.data?.shippingState ?? '';
      shippingZipController.text = customerDetailsModel.data?.shippingZip ?? '';
      shippingCountryController.text =
          customerDetailsModel.data?.shippingCountry ?? '';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  TextEditingController companyController = TextEditingController();
  TextEditingController vatController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  MultiSelectController<Object> groupController = MultiSelectController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  TextEditingController billingStreetController = TextEditingController();
  TextEditingController billingCityController = TextEditingController();
  TextEditingController billingStateController = TextEditingController();
  TextEditingController billingZipController = TextEditingController();
  TextEditingController billingCountryController = TextEditingController();
  TextEditingController shippingStreetController = TextEditingController();
  TextEditingController shippingCityController = TextEditingController();
  TextEditingController shippingStateController = TextEditingController();
  TextEditingController shippingZipController = TextEditingController();
  TextEditingController shippingCountryController = TextEditingController();

  FocusNode companyFocusNode = FocusNode();
  FocusNode vatFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode websiteFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode groupFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  FocusNode billingStreetFocusNode = FocusNode();
  FocusNode billingCityFocusNode = FocusNode();
  FocusNode billingStateFocusNode = FocusNode();
  FocusNode billingZipFocusNode = FocusNode();
  FocusNode billingCountryFocusNode = FocusNode();
  FocusNode shippingStreetFocusNode = FocusNode();
  FocusNode shippingCityFocusNode = FocusNode();
  FocusNode shippingStateFocusNode = FocusNode();
  FocusNode shippingZipFocusNode = FocusNode();
  FocusNode shippingCountryFocusNode = FocusNode();

  Future<void> submitCustomer(
      {String? customerId, bool isUpdate = false}) async {
    String company = companyController.text.toString();
    String vat = vatController.text.toString();
    String phoneNumber = phoneNumberController.text.toString();
    String website = websiteController.text.toString();
    String currency = currencyController.text.toString();
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String state = stateController.text.toString();
    String zip = zipController.text.toString();
    String country = countryController.text.toString();

    String billingStreet = billingStreetController.text.toString();
    String billingCity = billingCityController.text.toString();
    String billingState = billingStateController.text.toString();
    String billingZip = billingZipController.text.toString();
    String billingCountry = billingCountryController.text.toString();
    String shippingStreet = shippingStreetController.text.toString();
    String shippingCity = shippingCityController.text.toString();
    String shippingState = shippingStateController.text.toString();
    String shippingZip = shippingZipController.text.toString();
    String shippingCountry = shippingCountryController.text.toString();

    if (company.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterCompanyName.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    CustomerPostModel customerModel = CustomerPostModel(
      company: company,
      vat: vat,
      phoneNumber: phoneNumber,
      website: website,
      address: address,
      groupsIn: groupsList,
      defaultCurrency: currency,
      city: city,
      state: state,
      zip: zip,
      country: country,
      billingStreet: billingStreet,
      billingCity: billingCity,
      billingState: billingState,
      billingZip: billingZip,
      billingCountry: billingCountry,
      shippingStreet: shippingStreet,
      shippingCity: shippingCity,
      shippingState: shippingState,
      shippingZip: shippingZip,
      shippingCountry: shippingCountry,
    );

    ResponseModel responseModel = await customerRepo.submitCustomer(
        customerModel,
        customerId: customerId,
        isUpdate: isUpdate);
    if (responseModel.status) {
      clearCustomerData();
      Get.back();
      if (isUpdate) await loadCustomerDetails(customerId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Customer
  Future<void> deleteCustomer(customerId) async {
    ResponseModel responseModel = await customerRepo.deleteCustomer(customerId);

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

  Future<void> toggleCustomerActive(
      String customerId, bool currentlyActive) async {
    isSubmitLoading = true;
    update();

    final response =
        await customerRepo.toggleCustomerActive(customerId, !currentlyActive);
    if (response.status) {
      await loadCustomerDetails(customerId);
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Search Customers
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchCustomer() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await customerRepo.searchCustomer(keysearch);
    if (responseModel.status) {
      customersModel =
          CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
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

  Future<void> loadCustomerContacts(customerId) async {
    ResponseModel responseModel =
        await customerRepo.getCustomerContacts(customerId);
    if (responseModel.status) {
      customerContactsModel =
          ContactsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode titleFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  // Contact toggles & permissions
  bool contactIsPrimary = false;
  bool contactIsActive = true;
  bool contactInvoiceEmails = false;
  bool contactEstimateEmails = false;
  bool contactCreditNoteEmails = false;
  bool contactContractEmails = false;
  bool contactTaskEmails = false;
  bool contactProjectEmails = false;
  bool contactTicketEmails = false;
  List<int> contactPermissions = [];

  void loadContactForUpdate(Contact contact) {
    firstNameController.text = contact.firstName ?? '';
    lastNameController.text = contact.lastName ?? '';
    emailController.text = contact.email ?? '';
    titleController.text = contact.title ?? '';
    phoneController.text = contact.phoneNumber ?? '';
    passwordController.text = '';
    contactIsPrimary = contact.isPrimary == '1';
    contactIsActive = contact.active == '1';
    contactInvoiceEmails = contact.invoiceEmails == '1';
    contactEstimateEmails = contact.estimateEmails == '1';
    contactCreditNoteEmails = contact.creditNoteEmails == '1';
    contactContractEmails = contact.contractEmails == '1';
    contactTaskEmails = contact.taskEmails == '1';
    contactProjectEmails = contact.projectEmails == '1';
    contactTicketEmails = contact.ticketEmail == '1';
    contactPermissions = List<int>.from(contact.permissions ?? []);
  }

  Future<void> updateContact(String contactId, String customerId) async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String title = titleController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (firstName.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterFirstName.tr]);
      return;
    }
    if (lastName.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterLastName.tr]);
      return;
    }
    if (email.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterEmail.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    ContactPostModel contactModel = ContactPostModel(
      customerId: customerId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      title: title,
      phone: phone,
      password: password,
      isPrimary: contactIsPrimary,
      isActive: contactIsActive,
      invoiceEmails: contactInvoiceEmails,
      estimateEmails: contactEstimateEmails,
      creditNoteEmails: contactCreditNoteEmails,
      contractEmails: contactContractEmails,
      taskEmails: contactTaskEmails,
      projectEmails: contactProjectEmails,
      ticketEmails: contactTicketEmails,
      permissions: contactPermissions,
    );

    ResponseModel responseModel =
        await customerRepo.updateContact(contactModel, contactId);
    if (responseModel.status) {
      Get.back();
      clearData();
      await loadCustomerContacts(customerId);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  Future<void> submitContact(String customerId) async {
    String firstName = firstNameController.text.toString();
    String lastName = lastNameController.text.toString();
    String email = emailController.text.toString();
    String title = titleController.text.toString();
    String phone = phoneController.text.toString();
    String password = passwordController.text.toString();

    if (firstName.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterSubject.tr]);
      return;
    }
    if (lastName.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.billingType.tr]);
      return;
    }
    if (email.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.customer.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    ContactPostModel contactModel = ContactPostModel(
      customerId: customerId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      title: title,
      phone: phone,
      password: password,
    );

    ResponseModel responseModel =
        await customerRepo.createContact(contactModel);
    if (responseModel.status) {
      Get.back();
      clearData();
      await loadCustomerContacts(customerId);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  void clearCustomerData() {
    isLoading = false;
    isSubmitLoading = false;
    groupsList = [];
    companyController.text = '';
    vatController.text = '';
    phoneNumberController.text = '';
    websiteController.text = '';
    groupController.clearAll();
    addressController.text = '';
    currencyController.text = '';
    countryController.text = '';
    cityController.text = '';
    stateController.text = '';
    zipController.text = '';
    billingStreetController.text = '';
    billingCityController.text = '';
    billingStateController.text = '';
    billingZipController.text = '';
    billingCountryController.text = '';
    shippingStreetController.text = '';
    shippingCityController.text = '';
    shippingStateController.text = '';
    shippingZipController.text = '';
    shippingCountryController.text = '';
  }

  void clearData() {
    isLoading = false;
    isSubmitLoading = false;
    firstNameController.text = '';
    lastNameController.text = '';
    emailController.text = '';
    titleController.text = '';
    phoneController.text = '';
  }

  // ── Customer sub-resource lists ────────────────────────────────────────────
  List<Map<String, dynamic>> customerInvoicesList = [];
  bool isCustomerInvoicesLoading = false;
  List<Map<String, dynamic>> customerTicketsList = [];
  bool isCustomerTicketsLoading = false;

  Future<void> loadCustomerInvoices(String clientId) async {
    isCustomerInvoicesLoading = true;
    update();
    final response = await customerRepo.getCustomerInvoices(clientId);
    isCustomerInvoicesLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['invoices'] ?? [])
          : decoded;
      customerInvoicesList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerInvoicesList = [];
    }
    update();
  }

  Future<void> loadCustomerTickets(String clientId) async {
    isCustomerTicketsLoading = true;
    update();
    final response = await customerRepo.getCustomerTickets(clientId);
    isCustomerTicketsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['tickets'] ?? [])
          : decoded;
      customerTicketsList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerTicketsList = [];
    }
    update();
  }

  // ── Notes ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerNotesList = [];
  bool isCustomerNotesLoading = false;

  Future<void> loadCustomerNotes(String customerId) async {
    isCustomerNotesLoading = true;
    update();
    final response = await customerRepo.getCustomerNotes(customerId);
    isCustomerNotesLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['notes'] ?? [])
          : decoded;
      customerNotesList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerNotesList = [];
    }
    update();
  }

  Future<void> addCustomerNote(String customerId, String description) async {
    final response =
        await customerRepo.addCustomerNote(customerId, description);
    if (response.status) {
      loadCustomerNotes(customerId);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to add note'
      ]);
    }
  }

  Future<void> deleteCustomerNote(String customerId, String noteId) async {
    final response = await customerRepo.deleteCustomerNote(customerId, noteId);
    if (response.status) {
      loadCustomerNotes(customerId);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to delete note'
      ]);
    }
  }

  // ── Credit notes ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerCreditNotesList = [];
  bool isCustomerCreditNotesLoading = false;

  Future<void> loadCustomerCreditNotes(String customerId) async {
    isCustomerCreditNotesLoading = true;
    update();
    final response = await customerRepo.getCustomerCreditNotes(customerId);
    isCustomerCreditNotesLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['credit_notes'] ?? [])
          : decoded;
      customerCreditNotesList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerCreditNotesList = [];
    }
    update();
  }

  // ── Activities ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerActivitiesList = [];
  bool isCustomerActivitiesLoading = false;

  Future<void> loadCustomerActivities(String customerId) async {
    isCustomerActivitiesLoading = true;
    update();
    final response = await customerRepo.getCustomerActivities(customerId);
    isCustomerActivitiesLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['activities'] ?? [])
          : decoded;
      customerActivitiesList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerActivitiesList = [];
    }
    update();
  }

  Future<void> toggleContactStatus(
      String contactId, bool currentlyActive, String customerId) async {
    final response =
        await customerRepo.toggleContactStatus(contactId, !currentlyActive);
    if (response.status) {
      await loadCustomerContacts(customerId);
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  Future<void> deleteContactImage(String contactId, String customerId) async {
    final response = await customerRepo.deleteContactImage(contactId);
    if (response.status) {
      await loadCustomerContacts(customerId);
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  Future<void> toggleContactFileAccess(
      String contactId, bool currentlyAllowed, String customerId) async {
    final response = await customerRepo.updateContactFileAccess(
        contactId, !currentlyAllowed);
    if (response.status) {
      await loadCustomerContacts(customerId);
      CustomSnackBar.success(successList: [
        !currentlyAllowed ? 'File access granted' : 'File access revoked'
      ]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  // ── Customer Subscriptions ────────────────────────────────────────────────
  List<Map<String, dynamic>> customerSubscriptionsList = [];
  bool isCustomerSubscriptionsLoading = false;

  Future<void> loadCustomerSubscriptions(String customerId) async {
    isCustomerSubscriptionsLoading = true;
    update();
    final response = await customerRepo.getCustomerSubscriptions(customerId);
    isCustomerSubscriptionsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['subscriptions'] ?? [])
          : decoded;
      customerSubscriptionsList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerSubscriptionsList = [];
    }
    update();
  }

  // ── Statement ─────────────────────────────────────────────────────────────
  Future<void> sendStatement(String customerId, String from, String to) async {
    isSubmitLoading = true;
    update();
    final response =
        await customerRepo.sendCustomerStatement(customerId, from, to);
    isSubmitLoading = false;
    if (response.status) {
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  // ── Group Assignment ──────────────────────────────────────────────────────
  Future<void> assignToGroup(String customerId, List<String> groupIds) async {
    isSubmitLoading = true;
    update();
    final response =
        await customerRepo.assignCustomerToGroup(customerId, groupIds);
    isSubmitLoading = false;
    if (response.status) {
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  // ── Attachments ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerAttachmentsList = [];
  bool isAttachmentsLoading = false;

  Future<void> loadCustomerAttachments(String customerId) async {
    isAttachmentsLoading = true;
    update();
    final response = await customerRepo.getCustomerAttachments(customerId);
    isAttachmentsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      customerAttachmentsList =
          List<Map<String, dynamic>>.from(decoded['data'] ?? decoded ?? []);
    } else {
      customerAttachmentsList = [];
    }
    update();
  }

  Future<void> uploadCustomerAttachment(String customerId) async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    isSubmitLoading = true;
    update();
    final response =
        await customerRepo.uploadCustomerAttachment(customerId, filePath);
    isSubmitLoading = false;
    if (response.status) {
      CustomSnackBar.success(successList: [response.message.tr]);
      await loadCustomerAttachments(customerId);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
    update();
  }

  Future<void> deleteCustomerAttachment(
      String customerId, String attachmentId) async {
    final response = await customerRepo.deleteCustomerAttachment(attachmentId);
    if (response.status) {
      CustomSnackBar.success(successList: [response.message.tr]);
      await loadCustomerAttachments(customerId);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  // ── Admins ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerAdminsList = [];
  bool isCustomerAdminsLoading = false;
  List<Map<String, dynamic>> allStaffList = [];

  Future<void> loadCustomerAdmins(String customerId) async {
    isCustomerAdminsLoading = true;
    update();
    final response = await customerRepo.getCustomerAdmins(customerId);
    isCustomerAdminsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['admins'] ?? [])
          : decoded;
      customerAdminsList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerAdminsList = [];
    }
    update();
  }

  Future<void> loadAllStaff() async {
    final response = await customerRepo.getAllStaff();
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['staff'] ?? [])
          : decoded;
      allStaffList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      allStaffList = [];
    }
    update();
  }

  Future<void> assignCustomerAdmin(String customerId, String staffId) async {
    isSubmitLoading = true;
    update();
    final response =
        await customerRepo.assignCustomerAdmin(customerId, staffId);
    isSubmitLoading = false;
    if (response.status) {
      CustomSnackBar.success(successList: ['Admin assigned']);
      await loadCustomerAdmins(customerId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> removeCustomerAdmin(String customerId, String staffId) async {
    isSubmitLoading = true;
    update();
    final response =
        await customerRepo.removeCustomerAdmin(customerId, staffId);
    isSubmitLoading = false;
    if (response.status) {
      CustomSnackBar.success(successList: ['Admin removed']);
      await loadCustomerAdmins(customerId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── GDPR Consents ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> customerGdprConsentsList = [];
  bool isCustomerGdprConsentsLoading = false;

  Future<void> loadCustomerGdprConsents(String customerId) async {
    isCustomerGdprConsentsLoading = true;
    update();
    final response = await customerRepo.getCustomerGdprConsents(customerId);
    isCustomerGdprConsentsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map
          ? (decoded['data'] ?? decoded['consents'] ?? [])
          : decoded;
      customerGdprConsentsList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      customerGdprConsentsList = [];
    }
    update();
  }
}

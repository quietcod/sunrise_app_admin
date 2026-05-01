import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/currencies_model.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_details_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_item_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/estimate/model/estimate_post_model.dart';
import 'package:flutex_admin/features/estimate/repo/estimate_repo.dart';
import 'package:flutex_admin/features/item/model/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateController extends GetxController {
  EstimateRepo estimateRepo;
  EstimateController({required this.estimateRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  bool isSendingEmail = false;
  bool isCopyingEstimate = false;
  bool isSendingExpiryReminder = false;
  String? fromProjectId;
  EstimatesModel estimatesModel = EstimatesModel();
  EstimateDetailsModel estimateDetailsModel = EstimateDetailsModel();
  CustomersModel customersModel = CustomersModel();
  CurrenciesModel currenciesModel = CurrenciesModel();
  ItemsModel itemsModel = ItemsModel();
  List<EstimateItemsModel> estimateItemList = [];
  List<String> removedItemsList = [];

  final Map<String, String> estimateStatus = {
    '1': LocalStrings.draft.tr,
    '2': LocalStrings.sent.tr,
    '3': LocalStrings.declined.tr,
    '4': LocalStrings.accepted.tr,
    '5': LocalStrings.expired.tr,
  };

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadEstimates();
    isLoading = false;
    update();
  }

  Future<void> loadEstimates() async {
    ResponseModel responseModel = await estimateRepo.getAllEstimates();
    if (responseModel.status) {
      estimatesModel =
          EstimatesModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      estimatesModel = EstimatesModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadEstimateDetails(estimateId) async {
    ResponseModel responseModel =
        await estimateRepo.getEstimateDetails(estimateId);
    if (responseModel.status) {
      estimateDetailsModel =
          EstimateDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  Future<CustomersModel> loadCustomers() async {
    try {
      ResponseModel responseModel = await estimateRepo.getAllCustomers();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return customersModel = CustomersModel(status: false, data: []);
      }
      return customersModel =
          CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return customersModel = CustomersModel(status: false, data: []);
    }
  }

  Future<CurrenciesModel> loadCurrencies() async {
    try {
      ResponseModel responseModel = await estimateRepo.getCurrencies();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return currenciesModel = CurrenciesModel();
      }
      return currenciesModel =
          CurrenciesModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return currenciesModel = CurrenciesModel();
    }
  }

  Future<ItemsModel> loadItems() async {
    try {
      ResponseModel responseModel = await estimateRepo.getItems();
      if (!responseModel.status || responseModel.responseJson.isEmpty) {
        return itemsModel = ItemsModel();
      }
      return itemsModel =
          ItemsModel.fromJson(jsonDecode(responseModel.responseJson));
    } catch (_) {
      return itemsModel = ItemsModel();
    }
  }

  Future<void> loadEstimateUpdateData(estimateId) async {
    ResponseModel responseModel =
        await estimateRepo.getEstimateDetails(estimateId);
    if (responseModel.status) {
      estimateDetailsModel =
          EstimateDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      numberController.text = estimateDetailsModel.data?.number ?? '';
      clientController.text = estimateDetailsModel.data?.clientId ?? '';
      dateController.text = estimateDetailsModel.data?.date ?? '';
      dueDateController.text = estimateDetailsModel.data?.expiryDate ?? '';
      billingStreetController.text =
          estimateDetailsModel.data?.clientData?.address ?? '';
      currencyController.text = estimateDetailsModel.data?.currency ?? '';
      statusController.text = estimateDetailsModel.data?.status ?? '';
      clientNoteController.text = estimateDetailsModel.data?.clientNote ?? '';
      termsController.text = estimateDetailsModel.data?.terms ?? '';
      // Items
      removedItemsList.clear();
      estimateItemList.clear();
      itemController.text =
          estimateDetailsModel.data?.items?.first.description ?? '';
      descriptionController.text =
          estimateDetailsModel.data?.items?.first.longDescription ?? '';
      qtyController.text = estimateDetailsModel.data?.items?.first.qty ?? '';
      unitController.text = estimateDetailsModel.data?.items?.first.unit ?? '';
      rateController.text = estimateDetailsModel.data?.items?.first.rate ?? '';
      if (estimateDetailsModel.data!.items!.length > 1) {
        for (var i = 1; i < estimateDetailsModel.data!.items!.length; i++) {
          estimateItemList.add(EstimateItemsModel(
            itemNameController: TextEditingController(
                text: estimateDetailsModel.data!.items![i].description
                    .toString()),
            descriptionController: TextEditingController(
                text: estimateDetailsModel.data!.items![i].longDescription
                    .toString()),
            qtyController: TextEditingController(
                text: estimateDetailsModel.data!.items![i].qty.toString()),
            unitController: TextEditingController(
                text: estimateDetailsModel.data!.items![i].unit.toString()),
            rateController: TextEditingController(
                text: estimateDetailsModel.data!.items![i].rate.toString()),
          ));
        }
      }
      for (var i = 0; i < estimateDetailsModel.data!.items!.length; i++) {
        removedItemsList
            .add(estimateDetailsModel.data!.items![i].id.toString());
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  TextEditingController numberController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController billingStreetController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController clientNoteController = TextEditingController();
  TextEditingController termsController = TextEditingController();

  TextEditingController itemController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController rateController = TextEditingController();

  FocusNode numberFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode dueDateFocusNode = FocusNode();
  FocusNode billingStreetFocusNode = FocusNode();
  FocusNode clientNoteFocusNode = FocusNode();
  FocusNode termsFocusNode = FocusNode();

  FocusNode itemFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode qtyFocusNode = FocusNode();
  FocusNode unitFocusNode = FocusNode();
  FocusNode rateFocusNode = FocusNode();

  void increaseItemField() {
    estimateItemList.add(EstimateItemsModel(
      itemNameController: TextEditingController(),
      descriptionController: TextEditingController(),
      qtyController: TextEditingController(),
      unitController: TextEditingController(),
      rateController: TextEditingController(),
    ));
    update();
  }

  void decreaseItemField(int index) {
    estimateItemList.removeAt(index);
    calculateEstimateAmount();
    update();
  }

  String totalEstimateAmount = '';

  void calculateEstimateAmount() {
    double totalAmount = 0;

    double firstEstimateAmount =
        double.tryParse(rateController.text.toString()) ?? 0;
    double firstEstimateQty =
        double.tryParse(qtyController.text.toString()) ?? 0;

    totalAmount = totalAmount + (firstEstimateAmount * firstEstimateQty);

    for (var estimate in estimateItemList) {
      double estimateAmount =
          double.tryParse(estimate.rateController.text) ?? 0;
      double estimateQty = double.tryParse(estimate.qtyController.text) ?? 0;
      totalAmount = totalAmount + (estimateAmount * estimateQty);
    }

    totalEstimateAmount = totalAmount.toString();

    //update();
  }

  Future<void> submitEstimate(
      {String? estimateId, bool isUpdate = false}) async {
    String number = numberController.text.toString();
    String client = clientController.text.toString();
    String date = dateController.text.toString();
    String dueDate = dueDateController.text.toString();
    String currency = currencyController.text.toString();
    String billingStreet = billingStreetController.text.toString();
    String status = statusController.text.toString();
    String clientNote = clientNoteController.text.toString();
    String terms = termsController.text.toString();

    if (number.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterNumber.tr]);
      return;
    }
    if (client.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.selectClient.tr]);
      return;
    }
    if (date.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.pleaseEnterDate.tr]);
      return;
    }

    String firstItemName = itemController.text.toString();
    String firstItemDescription = descriptionController.text.toString();
    String firstItemQty = qtyController.text.toString();
    String firstItemRate = rateController.text.toString();
    String firstItemUnit = unitController.text.toString();

    if (firstItemName.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterItemName.tr]);
      return;
    }
    if (firstItemQty.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterItemQty.tr]);
      return;
    }
    if (firstItemRate.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterRate.tr]);
      return;
    }

    // Ensure totals are always sent even if no onChanged fired.
    calculateEstimateAmount();
    final String safeTotal = totalEstimateAmount.isEmpty
        ? ((double.tryParse(firstItemRate) ?? 0) *
                (double.tryParse(firstItemQty) ?? 0))
            .toString()
        : totalEstimateAmount;

    isSubmitLoading = true;
    update();

    EstimatePostModel estimateModel = EstimatePostModel(
      clientId: client,
      projectId: fromProjectId,
      number: number,
      date: date,
      duedate: dueDate,
      currency: currency,
      firstItemName: firstItemName,
      firstItemDescription: firstItemDescription,
      firstItemQty: firstItemQty,
      firstItemRate: firstItemRate,
      firstItemUnit: firstItemUnit,
      newItems: estimateItemList,
      subtotal: safeTotal,
      total: safeTotal,
      billingStreet: billingStreet,
      status: status,
      removedItems: removedItemsList,
      clientNote: clientNote,
      terms: terms,
    );

    ResponseModel responseModel = await estimateRepo.createEstimate(
        estimateModel,
        estimateId: estimateId,
        isUpdate: isUpdate);
    if (responseModel.status) {
      Get.back();
      if (isUpdate) await loadEstimateDetails(estimateId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      isSubmitLoading = false;
      update();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
      return;
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Estimate
  Future<void> deleteEstimate(estimateId) async {
    ResponseModel responseModel = await estimateRepo.deleteEstimate(estimateId);

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

  Future<void> convertToInvoice(String estimateId) async {
    isSubmitLoading = true;
    update();

    final response = await estimateRepo.convertEstimateToInvoice(estimateId);
    if (response.status) {
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Search Estimates
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchEstimate() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await estimateRepo.searchEstimate(keysearch);
    if (responseModel.status) {
      estimatesModel =
          EstimatesModel.fromJson(jsonDecode(responseModel.responseJson));
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
    isSendingEmail = false;
    isCopyingEstimate = false;
    isSendingExpiryReminder = false;
    numberController.text = '';
    clientController.text = '';
    dateController.text = '';
    dueDateController.text = '';
    billingStreetController.text = '';
    statusController.text = '';
    currencyController.text = '';
    billingStreetController.text = '';
    clientNoteController.text = '';
    termsController.text = '';

    itemController.text = '';
    descriptionController.text = '';
    qtyController.text = '';
    unitController.text = '';
    rateController.text = '';

    estimateItemList.clear();
    fromProjectId = null;
  }

  Future<void> sendByEmail(String estimateId) async {
    isSendingEmail = true;
    update();
    final response = await estimateRepo.sendByEmail(estimateId);
    isSendingEmail = false;
    update();
    if (response.status) {
      CustomSnackBar.success(
          successList: ['Estimate sent to client successfully']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> openPdf(String estimateId) async {
    final uri = Uri.parse('${UrlContainer.pdfEstimateWebUrl}$estimateId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.error(errorList: ['Could not open PDF']);
    }
  }

  Future<void> markActionStatus(String estimateId, String status) async {
    isSubmitLoading = true;
    update();
    final response = await estimateRepo.markActionStatus(estimateId, status);
    isSubmitLoading = false;
    if (response.status) {
      await loadEstimateDetails(estimateId);
      final label = estimateStatus[status] ?? status;
      CustomSnackBar.success(successList: ['Estimate marked as $label']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Copy estimate ─────────────────────────────────────────────────────────
  Future<void> copyEstimate(String estimateId) async {
    isCopyingEstimate = true;
    update();
    final response = await estimateRepo.copyEstimate(estimateId);
    isCopyingEstimate = false;
    if (response.status) {
      CustomSnackBar.success(successList: ['Estimate copied successfully']);
      await loadEstimates();
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Send expiry reminder ──────────────────────────────────────────────────
  Future<void> sendExpiryReminder(String estimateId) async {
    isSendingExpiryReminder = true;
    update();
    final response = await estimateRepo.sendExpiryReminder(estimateId);
    isSendingExpiryReminder = false;
    if (response.status) {
      CustomSnackBar.success(successList: ['Expiry reminder sent']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Attachments ──────────────────────────────────────────────────────────
  Future<void> pickAndUploadAttachment(
      String estimateId, bool visibleToCustomer) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'png',
        'jpg',
        'jpeg',
        'gif',
        'zip',
        'txt'
      ],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;

    isSubmitLoading = true;
    update();
    final response = await estimateRepo.uploadAttachment(
        estimateId, filePath, visibleToCustomer);
    isSubmitLoading = false;
    if (response.status) {
      await loadEstimateDetails(estimateId);
      CustomSnackBar.success(successList: ['Attachment uploaded']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> deleteAttachment(String estimateId, String attachmentId) async {
    isSubmitLoading = true;
    update();
    final response =
        await estimateRepo.deleteAttachment(estimateId, attachmentId);
    isSubmitLoading = false;
    if (response.status) {
      await loadEstimateDetails(estimateId);
      CustomSnackBar.success(successList: ['Attachment deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Clear signature ───────────────────────────────────────────────────────
  Future<void> clearSignature(String estimateId) async {
    isSubmitLoading = true;
    update();
    final response = await estimateRepo.clearSignature(estimateId);
    isSubmitLoading = false;
    if (response.status) {
      await loadEstimateDetails(estimateId);
      CustomSnackBar.success(successList: ['Signature cleared']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Admin note ────────────────────────────────────────────────────────────
  Future<void> updateAdminNote(String estimateId, String note) async {
    isSubmitLoading = true;
    update();
    final response = await estimateRepo.updateAdminNote(estimateId, note);
    isSubmitLoading = false;
    if (response.status) {
      await loadEstimateDetails(estimateId);
      CustomSnackBar.success(successList: ['Admin note saved']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }
}

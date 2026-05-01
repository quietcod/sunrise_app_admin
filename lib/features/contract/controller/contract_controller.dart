import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/contract/model/contract_details_model.dart';
import 'package:flutex_admin/features/contract/model/contract_model.dart';
import 'package:flutex_admin/features/contract/model/contract_post_model.dart';
import 'package:flutex_admin/features/contract/repo/contract_repo.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class ContractController extends GetxController {
  ContractRepo contractRepo;
  ContractController({required this.contractRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  ContractsModel contractsModel = ContractsModel();
  ContractDetailsModel contractDetailsModel = ContractDetailsModel();
  CustomersModel customersModel = CustomersModel();
  List<Map<String, dynamic>> contractRenewals = [];

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadContracts();
    isLoading = false;
    update();
  }

  Future<void> loadContracts() async {
    ResponseModel responseModel = await contractRepo.getAllContracts();
    if (responseModel.status) {
      contractsModel =
          ContractsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      contractsModel = ContractsModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadContractDetails(contractId) async {
    ResponseModel responseModel =
        await contractRepo.getContractDetails(contractId);
    if (responseModel.status) {
      contractDetailsModel =
          ContractDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    await Future.wait([
      loadContractNotes(contractId.toString()),
      loadContractComments(contractId.toString()),
    ]);

    isLoading = false;
    update();
  }

  Future<CustomersModel> loadCustomers() async {
    ResponseModel responseModel = await contractRepo.getAllCustomers();
    return customersModel =
        CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<void> loadContractUpdateData(contractId) async {
    ResponseModel responseModel =
        await contractRepo.getContractDetails(contractId);
    if (responseModel.status) {
      contractDetailsModel =
          ContractDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      subjectController.text = contractDetailsModel.data?.subject ?? '';
      clientController.text = contractDetailsModel.data?.userId ?? '';
      dateStartController.text = contractDetailsModel.data?.dateStart ?? '';
      dateEndController.text = contractDetailsModel.data?.dateEnd ?? '';
      contractValueController.text =
          contractDetailsModel.data?.contractValue ?? '';
      descriptionController.text = contractDetailsModel.data?.description ?? '';
      contentController.text = contractDetailsModel.data?.content ?? '';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  TextEditingController subjectController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController dateStartController = TextEditingController();
  TextEditingController dateEndController = TextEditingController();
  TextEditingController contractValueController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  FocusNode subjectFocusNode = FocusNode();
  FocusNode clientFocusNode = FocusNode();
  FocusNode dateStartFocusNode = FocusNode();
  FocusNode dateEndFocusNode = FocusNode();
  FocusNode contractValueFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode contentFocusNode = FocusNode();

  Future<void> submitContract(
      {String? contractId, bool isUpdate = false}) async {
    String subject = subjectController.text.toString();
    String client = clientController.text.toString();
    String dateStart = dateStartController.text.toString();
    String dateEnd = dateEndController.text.toString();
    String contractValue = contractValueController.text.toString();
    String description = descriptionController.text.toString();
    String content = contentController.text.toString();

    if (subject.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterSubject.tr]);
    }
    if (dateStart.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterStartDate.tr]);
    }
    if (client.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.client.tr]);
    }

    isSubmitLoading = true;
    update();

    ContractPostModel contractModel = ContractPostModel(
      subject: subject,
      client: client,
      startDate: dateStart,
      endDate: dateEnd,
      contractValue: contractValue,
      description: description,
      content: content,
    );

    ResponseModel responseModel = await contractRepo.createContract(
        contractModel,
        contractId: contractId,
        isUpdate: isUpdate);
    if (responseModel.status) {
      Get.back();
      if (isUpdate) await loadContractDetails(contractId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isSubmitLoading = false;
    update();
  }

  // Delete Contract
  Future<void> deleteContract(contractId) async {
    ResponseModel responseModel = await contractRepo.deleteContract(contractId);

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

  void clearData() {
    isLoading = false;
    subjectController.text = '';
    clientController.text = '';
    dateStartController.text = '';
    dateEndController.text = '';
    contractValueController.text = '';
    descriptionController.text = '';
    contentController.text = '';
  }

  Future<void> sendByEmail(String contractId) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.sendByEmail(contractId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      CustomSnackBar.success(
          successList: ['Contract sent to client successfully']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> openPdf(String contractId) async {
    final uri = Uri.parse('${UrlContainer.pdfContractWebUrl}$contractId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.error(errorList: ['Could not open PDF']);
    }
  }

  Future<void> markSigned(String contractId, {bool signed = true}) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.markSigned(contractId, signed: signed);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: [
        signed ? 'Contract marked as signed' : 'Contract signature removed'
      ]);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> copyContract(String contractId) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.copyContract(contractId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContracts();
      CustomSnackBar.success(successList: ['Contract copied successfully']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Notes ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> contractNotes = [];

  Future<void> loadContractNotes(String contractId) async {
    final response = await contractRepo.getContractNotes(contractId);
    if (response.status) {
      try {
        final decoded = jsonDecode(response.message);
        contractNotes = List<Map<String, dynamic>>.from(
            (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)));
      } catch (_) {
        contractNotes = [];
      }
    }
    update();
  }

  Future<void> addNote(String contractId, String description) async {
    isSubmitLoading = true;
    update();
    final response =
        await contractRepo.addContractNote(contractId, description);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractNotes(contractId);
      CustomSnackBar.success(successList: ['Note added']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> deleteNote(String contractId, String noteId) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.deleteContractNote(contractId, noteId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractNotes(contractId);
      CustomSnackBar.success(successList: ['Note deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Comments ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> contractComments = [];

  Future<void> loadContractComments(String contractId) async {
    final response = await contractRepo.getContractComments(contractId);
    if (response.status) {
      try {
        final decoded = jsonDecode(response.message);
        contractComments = List<Map<String, dynamic>>.from(
            (decoded['data'] as List).map((e) => Map<String, dynamic>.from(e)));
      } catch (_) {
        contractComments = [];
      }
    }
    update();
  }

  Future<void> addComment(String contractId, String content) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.addContractComment(contractId, content);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractComments(contractId);
      CustomSnackBar.success(successList: ['Comment added']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> deleteComment(String contractId, String commentId) async {
    isSubmitLoading = true;
    update();
    final response =
        await contractRepo.deleteContractComment(contractId, commentId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractComments(contractId);
      CustomSnackBar.success(successList: ['Comment deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Attachments ─────────────────────────────────────────────────────────
  Future<void> pickAndUploadAttachment(
      String contractId, bool visibleToCustomer) async {
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
    if (result == null || result.files.single.path == null) return;
    final filePath = result.files.single.path!;

    isSubmitLoading = true;
    update();
    final response = await contractRepo.uploadContractAttachment(
        contractId, filePath, visibleToCustomer);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: ['Attachment uploaded']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> deleteAttachment(String contractId, String attachmentId) async {
    isSubmitLoading = true;
    update();
    final response =
        await contractRepo.deleteContractAttachment(contractId, attachmentId);
    isSubmitLoading = false;
    update();
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: ['Attachment deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Clear signature ───────────────────────────────────────────────────────
  Future<void> clearSignature(String contractId) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.clearSignature(contractId);
    isSubmitLoading = false;
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: ['Signature cleared']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  // ── Renewals ──────────────────────────────────────────────────────────────
  Future<void> loadRenewals(String contractId) async {
    final response = await contractRepo.getRenewals(contractId);
    if (response.status) {
      try {
        final decoded = jsonDecode(response.responseJson);
        contractRenewals =
            List<Map<String, dynamic>>.from(decoded['data'] ?? []);
      } catch (_) {
        contractRenewals = [];
      }
    }
    update();
  }

  Future<void> renewContract(
      String contractId, String dateStart, String dateEnd) async {
    isSubmitLoading = true;
    update();
    final response =
        await contractRepo.renewContract(contractId, dateStart, dateEnd);
    isSubmitLoading = false;
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: ['Contract renewed']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }

  Future<void> deleteRenewal(String contractId, String renewalId) async {
    isSubmitLoading = true;
    update();
    final response = await contractRepo.deleteRenewal(contractId, renewalId);
    isSubmitLoading = false;
    if (response.status) {
      await loadContractDetails(contractId);
      CustomSnackBar.success(successList: ['Renewal deleted']);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
    update();
  }
}

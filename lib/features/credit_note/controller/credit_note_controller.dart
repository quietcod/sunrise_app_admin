import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/credit_note/model/credit_note_model.dart';
import 'package:flutex_admin/features/credit_note/repo/credit_note_repo.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditNoteController extends GetxController {
  CreditNoteRepo creditNoteRepo;
  CreditNoteController({required this.creditNoteRepo});

  bool isLoading = true;
  bool isSubmitting = false;
  List<CreditNote> creditNoteList = [];
  CreditNote? selectedCreditNote;

  // For forms
  List<dynamic> customers = [];
  List<dynamic> currencies = [];

  @override
  void onInit() {
    super.onInit();
    initialData();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    if (shouldLoad) {
      isLoading = true;
      update();
    }
    await _loadCreditNotes();
    isLoading = false;
    update();
  }

  Future<void> _loadCreditNotes() async {
    final response = await creditNoteRepo.getAllCreditNotes();
    if (response.status) {
      final model =
          CreditNotesModel.fromJson(jsonDecode(response.responseJson));
      creditNoteList = model.data ?? [];
    }
  }

  Future<void> loadDetails(String id) async {
    isLoading = true;
    update();
    final response = await creditNoteRepo.getCreditNoteDetails(id);
    if (response.status) {
      final json = jsonDecode(response.responseJson);
      selectedCreditNote = CreditNote.fromJson(json['data']);
    }
    isLoading = false;
    update();
  }

  Future<void> loadFormData() async {
    final custRes = await creditNoteRepo.getAllCustomers();
    if (custRes.status) {
      final json = jsonDecode(custRes.responseJson);
      customers = json['data'] ?? [];
    }
    final curRes = await creditNoteRepo.getCurrencies();
    if (curRes.status) {
      final json = jsonDecode(curRes.responseJson);
      currencies = json['data'] ?? [];
    }
    update();
  }

  Future<bool> addCreditNote(Map<String, dynamic> data) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.addCreditNote(data);
    isSubmitting = false;
    if (response.status) {
      CustomSnackBar.success(successList: [LocalStrings.requestSuccess.tr]);
      await initialData(shouldLoad: false);
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [LocalStrings.somethingWentWrong.tr]);
      update();
      return false;
    }
  }

  Future<bool> updateCreditNote(String id, Map<String, dynamic> data) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.updateCreditNote(id, data);
    isSubmitting = false;
    if (response.status) {
      CustomSnackBar.success(successList: [LocalStrings.requestSuccess.tr]);
      await initialData(shouldLoad: false);
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [LocalStrings.somethingWentWrong.tr]);
      update();
      return false;
    }
  }

  Future<bool> deleteCreditNote(String id) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.deleteCreditNote(id);
    isSubmitting = false;
    if (response.status) {
      creditNoteList.removeWhere((c) => c.id == id);
      CustomSnackBar.success(successList: [LocalStrings.requestSuccess.tr]);
      update();
      return true;
    } else {
      CustomSnackBar.error(errorList: [LocalStrings.somethingWentWrong.tr]);
      update();
      return false;
    }
  }

  // ── PDF / Email / Apply / Refund ──────────────────────────────────────

  Future<void> openPdf(String creditNoteId) async {
    final uri = Uri.parse('${UrlContainer.pdfCreditNoteWebUrl}$creditNoteId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.error(errorList: ['Could not open PDF']);
    }
  }

  Future<void> sendByEmail(String creditNoteId) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.sendByEmail(creditNoteId);
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Email sent successfully']);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<void> applyToInvoice(
      String creditNoteId, String invoiceId, String amount) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.applyToInvoice(creditNoteId, {
      'invoice_id': invoiceId,
      'amount': amount,
    });
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Applied to invoice successfully']);
      await loadDetails(creditNoteId);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<void> refund(String creditNoteId, String amount, String note) async {
    isSubmitting = true;
    update();
    final response = await creditNoteRepo.refund(creditNoteId, {
      'amount': amount,
      'note': note,
    });
    isSubmitting = false;
    update();
    if (response.status) {
      CustomSnackBar.success(successList: ['Refund processed successfully']);
      await loadDetails(creditNoteId);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }
}

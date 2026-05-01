import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/invoice/model/invoice_post_model.dart';

class InvoiceRepo {
  ApiClient apiClient;
  InvoiceRepo({required this.apiClient});

  Future<ResponseModel> getAllInvoices() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnInvoicesFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/invoices",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Invoice access denied', '');
    for (final url in candidates) {
      final response = await apiClient.request(url, Method.getMethod, null,
          passHeader: true);
      if (response.status) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse;
  }

  Future<ResponseModel> getInvoiceDetails(invoiceId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/id/$invoiceId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllCustomers() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getCurrencies() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/currencies";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getTaxes() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/tax_data";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getPaymentModes() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/payment_modes";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getItems() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.itemsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createInvoice(InvoicePostModel invoiceModel,
      {String? invoiceId, bool isUpdate = false, String? projectId}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}";

    Map<String, dynamic> params = {
      "clientid": invoiceModel.clientId,
      "number": invoiceModel.number,
      "date": invoiceModel.date,
      "duedate": invoiceModel.duedate,
      "currency": invoiceModel.currency,
      "newitems[0][description]": invoiceModel.firstItemName,
      "newitems[0][long_description]": invoiceModel.firstItemDescription,
      "newitems[0][qty]": invoiceModel.firstItemQty,
      "newitems[0][rate]": invoiceModel.firstItemRate,
      "newitems[0][unit]": invoiceModel.firstItemUnit,
      "subtotal": invoiceModel.subtotal,
      "total": invoiceModel.total,
      "billing_street": invoiceModel.billingStreet,
      //"billing_city": invoiceModel.billingCity,
      //"billing_state": invoiceModel.billingState,
      //"billing_zip": invoiceModel.billingZip,
      //"billing_country": invoiceModel.billingCountry,
      //"include_shipping": invoiceModel.includeShipping,
      //"show_shipping_on_invoice": invoiceModel.showShippingOnInvoice,
      //"shipping_street": invoiceModel.shippingStreet,
      //"shipping_city": invoiceModel.shippingCity,
      //"shipping_state": invoiceModel.shippingState,
      //"shipping_zip": invoiceModel.shippingZip,
      //"shipping_country": invoiceModel.shippingCountry,
      //"cancel_overdue_reminders": invoiceModel.cancelOverdueReminders,
      //"tags": invoiceModel.tags,
      //"sale_agent": invoiceModel.saleAgent,
      //"recurring": invoiceModel.recurring,
      //"discount_type": invoiceModel.discountType,
      //"repeat_every_custom": invoiceModel.repeatEveryCustom,
      //"repeat_type_custom": invoiceModel.repeatTypeCustom,
      //"cycles": invoiceModel.cycles,
      //"adminnote": invoiceModel.adminNote,
      "clientnote": invoiceModel.clientNote,
      "terms": invoiceModel.terms,
    };

    if (projectId != null && projectId.isNotEmpty) {
      params["project_id"] = projectId;
    }

    int i = 0;
    for (var invoice in invoiceModel.newItems) {
      String invoiceItemName = invoice.itemNameController.text;
      String invoiceItemDescription = invoice.descriptionController.text;
      String invoiceItemQty = invoice.qtyController.text;
      String invoiceItemRate = invoice.rateController.text;
      String invoiceItemUnit = invoice.unitController.text;

      if (invoiceItemName.isNotEmpty && invoiceItemRate.isNotEmpty) {
        i = i + 1;
        params['newitems[$i][description]'] = invoiceItemName;
        params['newitems[$i][long_description]'] = invoiceItemDescription;
        params['newitems[$i][qty]'] = invoiceItemQty;
        params['newitems[$i][rate]'] = invoiceItemRate;
        params['newitems[$i][unit]'] = invoiceItemUnit;
        //params['newitems[$i][order]'] = '1';
        //params['newitems[0][taxname][]'] = 'CGST|9.00';
        //params['newitems[0][taxname][]'] = 'SGST|9.00';
      }
    }

    if (invoiceModel.removedItems != null) {
      int r = 0;
      for (var removedItems in invoiceModel.removedItems!) {
        params['removed_items[$r]'] = removedItems;
        r++;
      }
    }

    int p = 0;
    for (var paymentModes in invoiceModel.allowedPaymentModes) {
      params['allowed_payment_modes[$p]'] = paymentModes;
      p++;
    }

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$invoiceId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteInvoice(invoiceId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/id/$invoiceId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> recordPayment(
      String invoiceId, Map<String, dynamic> data) async {
    final url = '${UrlContainer.baseUrl}payments';
    return apiClient.request(url, Method.postMethod, data, passHeader: true);
  }

  Future<ResponseModel> searchInvoice(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendByEmail(String invoiceId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.emailInvoiceUrl}/$invoiceId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> markAsSent(String invoiceId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/id/$invoiceId';
    return apiClient.request(url, Method.putMethod, {'mark_sent': '1'},
        passHeader: true);
  }

  Future<ResponseModel> markCancelled(String invoiceId,
      {bool cancel = true}) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}/id/$invoiceId';
    return apiClient.request(
        url, Method.putMethod, {'status': cancel ? '5' : '1'},
        passHeader: true);
  }

  Future<ResponseModel> copyInvoice(String invoiceId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceCopyUrl}?id=$invoiceId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> sendOverdueNotice(String invoiceId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceOverdueNoticeUrl}?id=$invoiceId';
    return apiClient.request(url, Method.postMethod, {}, passHeader: true);
  }

  Future<ResponseModel> toggleOverdueReminders(
      String invoiceId, bool pause) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceToggleRemindersUrl}?id=$invoiceId';
    return apiClient.request(
        url, Method.putMethod, {'pause': pause ? '1' : '0'},
        passHeader: true);
  }

  Future<ResponseModel> uploadAttachment(
      String invoiceId, String filePath, bool visibleToCustomer) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceAttachmentsUrl}?id=$invoiceId';
    return apiClient.multipartRequest(
      url,
      filePath,
      {'visible_to_customer': visibleToCustomer ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteAttachment(
      String invoiceId, String attachmentId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceAttachmentDeleteUrl}?id=$invoiceId&attachment_id=$attachmentId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  Future<ResponseModel> getAvailableCredits(String invoiceId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.invoiceAvailableCreditsUrl}?invoice_id=$invoiceId';
    return apiClient.request(url, Method.getMethod, null, passHeader: true);
  }

  Future<ResponseModel> applyCredit(
      String invoiceId, String creditNoteId, String amount) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.invoiceApplyCreditUrl}';
    return apiClient.request(
        url,
        Method.postMethod,
        {
          'invoice_id': invoiceId,
          'credit_note_id': creditNoteId,
          'amount': amount
        },
        passHeader: true);
  }

  Future<ResponseModel> mergeInvoices(List<String> invoiceIds) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.invoiceMergeUrl}';
    final Map<String, dynamic> params = {};
    for (int i = 0; i < invoiceIds.length; i++) {
      params['invoice_ids[$i]'] = invoiceIds[i];
    }
    return apiClient.request(url, Method.postMethod, params, passHeader: true);
  }
}

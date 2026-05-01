class ProjectExpensesModel {
  ProjectExpensesModel({this.data});

  ProjectExpensesModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data!.add(ProjectExpense.fromJson(v)));
    }
  }

  List<ProjectExpense>? data;
}

class ProjectExpense {
  ProjectExpense.fromJson(dynamic json) {
    id = json['id']?.toString();
    category =
        json['category_name']?.toString() ?? json['category']?.toString() ?? '';
    amount = json['amount']?.toString() ?? '0';
    name = json['expense_name']?.toString() ?? json['name']?.toString() ?? '';
    note = json['note']?.toString() ?? '';
    date = json['date']?.toString() ?? json['dateadded']?.toString() ?? '';
    currencySymbol =
        json['currency_symbol']?.toString() ?? json['symbol']?.toString() ?? '';
    billable = json['billable']?.toString() ?? '0';
    invoiceId = json['invoiceid']?.toString() ?? json['invoice_id']?.toString();
  }

  String? id;
  String category = '';
  String amount = '0';
  String name = '';
  String note = '';
  String date = '';
  String currencySymbol = '';
  String billable = '0';
  String? invoiceId;

  bool get isBillable => billable == '1';
}

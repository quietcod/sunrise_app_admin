class ExpensesModel {
  ExpensesModel({
    bool? status,
    String? message,
    List<Expense>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  ExpensesModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Expense.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Expense>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<Expense>? get data => _data;
}

class Expense {
  Expense({
    String? id,
    String? category,
    String? categoryName,
    String? currency,
    String? currencySymbol,
    String? currencyName,
    String? amount,
    String? tax,
    String? tax2,
    String? referenceNo,
    String? note,
    String? expenseName,
    String? clientId,
    String? clientName,
    String? projectId,
    String? projectName,
    String? billable,
    String? invoiceId,
    String? recurring,
    String? date,
    String? createAt,
    String? addedFrom,
  }) {
    _id = id;
    _category = category;
    _categoryName = categoryName;
    _currency = currency;
    _currencySymbol = currencySymbol;
    _currencyName = currencyName;
    _amount = amount;
    _tax = tax;
    _tax2 = tax2;
    _referenceNo = referenceNo;
    _note = note;
    _expenseName = expenseName;
    _clientId = clientId;
    _clientName = clientName;
    _projectId = projectId;
    _projectName = projectName;
    _billable = billable;
    _invoiceId = invoiceId;
    _recurring = recurring;
    _date = date;
    _createAt = createAt;
    _addedFrom = addedFrom;
  }

  Expense.fromJson(dynamic json) {
    _id = json['id']?.toString();
    _category = json['category']?.toString();
    _categoryName = json['category_name']?.toString();
    _currency = json['currency']?.toString();
    _currencySymbol = json['symbol']?.toString();
    _currencyName = json['currency_name']?.toString();
    _amount = json['amount']?.toString();
    _tax = json['tax']?.toString();
    _tax2 = json['tax2']?.toString();
    _referenceNo = json['reference_no']?.toString();
    _note = json['note']?.toString();
    _expenseName = json['expense_name']?.toString();
    _clientId = json['clientid']?.toString();
    _clientName = json['client_name']?.toString();
    _projectId = json['project_id']?.toString();
    _projectName = json['project_name']?.toString();
    _billable = json['billable']?.toString();
    _invoiceId = json['invoiceid']?.toString();
    _recurring = json['recurring']?.toString();
    _date = json['date']?.toString();
    _createAt = json['create_at']?.toString();
    _addedFrom = json['addedfrom']?.toString();
  }

  String? _id;
  String? _category;
  String? _categoryName;
  String? _currency;
  String? _currencySymbol;
  String? _currencyName;
  String? _amount;
  String? _tax;
  String? _tax2;
  String? _referenceNo;
  String? _note;
  String? _expenseName;
  String? _clientId;
  String? _clientName;
  String? _projectId;
  String? _projectName;
  String? _billable;
  String? _invoiceId;
  String? _recurring;
  String? _date;
  String? _createAt;
  String? _addedFrom;

  String? get id => _id;
  String? get category => _category;
  String? get categoryName => _categoryName;
  String? get currency => _currency;
  String? get currencySymbol => _currencySymbol;
  String? get currencyName => _currencyName;
  String? get amount => _amount;
  String? get tax => _tax;
  String? get tax2 => _tax2;
  String? get referenceNo => _referenceNo;
  String? get note => _note;
  String? get expenseName => _expenseName;
  String? get clientId => _clientId;
  String? get clientName => _clientName;
  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get billable => _billable;
  String? get invoiceId => _invoiceId;
  String? get recurring => _recurring;
  String? get date => _date;
  String? get createAt => _createAt;
  String? get addedFrom => _addedFrom;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['category'] = _category;
    map['category_name'] = _categoryName;
    map['currency'] = _currency;
    map['symbol'] = _currencySymbol;
    map['currency_name'] = _currencyName;
    map['amount'] = _amount;
    map['tax'] = _tax;
    map['tax2'] = _tax2;
    map['reference_no'] = _referenceNo;
    map['note'] = _note;
    map['expense_name'] = _expenseName;
    map['clientid'] = _clientId;
    map['client_name'] = _clientName;
    map['project_id'] = _projectId;
    map['project_name'] = _projectName;
    map['billable'] = _billable;
    map['invoiceid'] = _invoiceId;
    map['recurring'] = _recurring;
    map['date'] = _date;
    map['create_at'] = _createAt;
    map['addedfrom'] = _addedFrom;
    return map;
  }
}

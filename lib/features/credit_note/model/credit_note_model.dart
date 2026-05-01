class CreditNotesModel {
  CreditNotesModel({
    bool? status,
    String? message,
    List<CreditNote>? data,
    List<CreditNoteStatus>? statuses,
  }) {
    _status = status;
    _message = message;
    _data = data;
    _statuses = statuses;
  }

  CreditNotesModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(CreditNote.fromJson(v));
      });
    }
    if (json['statuses'] != null) {
      _statuses = [];
      json['statuses'].forEach((v) {
        _statuses?.add(CreditNoteStatus.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<CreditNote>? _data;
  List<CreditNoteStatus>? _statuses;

  bool? get status => _status;
  String? get message => _message;
  List<CreditNote>? get data => _data;
  List<CreditNoteStatus>? get statuses => _statuses;
}

class CreditNote {
  CreditNote({
    String? id,
    String? clientid,
    String? clientName,
    String? number,
    String? prefix,
    String? status,
    String? date,
    String? expirydate,
    String? subtotal,
    String? total,
    String? discountPercent,
    String? discountTotal,
    String? currency,
    String? currencySymbol,
    String? referenceNo,
    String? adminnote,
    String? clientnote,
    String? datecreated,
    List<dynamic>? items,
  }) {
    _id = id;
    _clientid = clientid;
    _clientName = clientName;
    _number = number;
    _prefix = prefix;
    _status = status;
    _date = date;
    _expirydate = expirydate;
    _subtotal = subtotal;
    _total = total;
    _discountPercent = discountPercent;
    _discountTotal = discountTotal;
    _currency = currency;
    _currencySymbol = currencySymbol;
    _referenceNo = referenceNo;
    _adminnote = adminnote;
    _clientnote = clientnote;
    _datecreated = datecreated;
    _items = items;
  }

  CreditNote.fromJson(dynamic json) {
    _id = json['id']?.toString();
    _clientid = json['clientid']?.toString();
    _clientName =
        json['client_name']?.toString() ?? json['company']?.toString() ?? '';
    _number = json['number']?.toString();
    _prefix = json['prefix']?.toString() ?? '';
    _status = json['status']?.toString();
    _date = json['date']?.toString();
    _expirydate = json['expirydate']?.toString();
    _subtotal = json['subtotal']?.toString();
    _total = json['total']?.toString();
    _discountPercent = json['discount_percent']?.toString();
    _discountTotal = json['discount_total']?.toString();
    _currency = json['currency']?.toString();
    _currencySymbol = json['currency_symbol']?.toString() ?? '\$';
    _referenceNo = json['reference_no']?.toString();
    _adminnote = json['adminnote']?.toString();
    _clientnote = json['clientnote']?.toString();
    _datecreated = json['datecreated']?.toString();
    _items = json['items'] != null ? List<dynamic>.from(json['items']) : null;
  }

  String? _id;
  String? _clientid;
  String? _clientName;
  String? _number;
  String? _prefix;
  String? _status;
  String? _date;
  String? _expirydate;
  String? _subtotal;
  String? _total;
  String? _discountPercent;
  String? _discountTotal;
  String? _currency;
  String? _currencySymbol;
  String? _referenceNo;
  String? _adminnote;
  String? _clientnote;
  String? _datecreated;
  List<dynamic>? _items;

  String? get id => _id;
  String? get clientid => _clientid;
  String? get clientName => _clientName;
  String? get number => _number;
  String? get prefix => _prefix;
  String? get status => _status;
  String? get date => _date;
  String? get expirydate => _expirydate;
  String? get subtotal => _subtotal;
  String? get total => _total;
  String? get discountPercent => _discountPercent;
  String? get discountTotal => _discountTotal;
  String? get currency => _currency;
  String? get currencySymbol => _currencySymbol;
  String? get referenceNo => _referenceNo;
  String? get adminnote => _adminnote;
  String? get clientnote => _clientnote;
  String? get datecreated => _datecreated;
  List<dynamic>? get items => _items;

  String get formattedNumber => '${_prefix ?? ''}${_number ?? ''}';

  String get statusLabel {
    switch (_status) {
      case '1':
        return 'Open';
      case '2':
        return 'Closed';
      case '3':
        return 'Void';
      default:
        return 'Unknown';
    }
  }
}

class CreditNoteStatus {
  CreditNoteStatus.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    color = json['color']?.toString();
  }
  String? id;
  String? name;
  String? color;
}

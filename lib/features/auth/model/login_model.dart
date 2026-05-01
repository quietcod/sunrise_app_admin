class LoginModel {
  LoginModel({
    bool? status,
    String? message,
    Data? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  LoginModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'].toString();
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  Data? _data;

  bool? get status => _status;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    String? staffId,
    String? staffEmail,
    String? firstName,
    String? lastName,
    String? fullName,
    String? accessToken,
  }) {
    _staffId = staffId;
    _staffEmail = staffEmail;
    _firstName = firstName;
    _lastName = lastName;
    _fullName = fullName;
    _accessToken = accessToken;
  }

  Data.fromJson(dynamic json) {
    _staffId = json['staff_id'];
    _staffEmail = json['staff_email'];
    _firstName = json['firstname'];
    _lastName = json['lastname'];
    _fullName = json['full_name'];
    _accessToken = json['token'];
    _canCloseWithoutOtp = json['can_close_ticket_without_otp'] == true;
  }
  String? _staffId;
  String? _staffEmail;
  String? _firstName;
  String? _lastName;
  String? _fullName;
  String? _accessToken;
  bool _canCloseWithoutOtp = false;

  String? get staffId => _staffId;
  String? get staffEmail => _staffEmail;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get fullName => _fullName;
  String get displayName {
    final name = (_fullName ?? '').trim();
    if (name.isNotEmpty) return name;
    return '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
  }

  String? get accessToken => _accessToken;
  bool get canCloseWithoutOtp => _canCloseWithoutOtp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['staff_id'] = _staffId;
    map['staff_email'] = _staffEmail;
    map['firstname'] = _firstName;
    map['lastname'] = _lastName;
    map['full_name'] = _fullName;
    map['token'] = _accessToken;
    map['can_close_ticket_without_otp'] = _canCloseWithoutOtp;
    return map;
  }
}

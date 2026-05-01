import 'package:flutex_admin/features/expense/model/expense_model.dart';

class ExpenseDetailsModel {
  ExpenseDetailsModel({
    bool? status,
    String? message,
    Expense? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  ExpenseDetailsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = Expense.fromJson(json['data']);
    }
  }

  bool? _status;
  String? _message;
  Expense? _data;

  bool? get status => _status;
  String? get message => _message;
  Expense? get data => _data;
}

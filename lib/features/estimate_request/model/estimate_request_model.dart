import 'dart:ui';

class EstimateRequestsModel {
  EstimateRequestsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(EstimateRequest.fromJson(v)));
    }
  }
  EstimateRequestsModel() : data = [];
  String? message;
  List<EstimateRequest>? data;
}

class EstimateRequest {
  EstimateRequest.fromJson(dynamic json) {
    id = json['id']?.toString();
    subject = json['subject']?.toString();
    status = json['status']?.toString();
    dateSubmitted = json['date_submitted']?.toString();
    assigned = json['assigned']?.toString();
    assignedName = json['assigned_name']?.toString();
    email = json['email']?.toString();
  }
  String? id;
  String? subject;
  String? status;
  String? dateSubmitted;
  String? assigned;
  String? assignedName;
  String? email;

  String get statusLabel {
    switch (status) {
      case '0':
        return 'Pending';
      case '1':
        return 'In Progress';
      case '2':
        return 'Done';
      case '3':
        return 'Converted';
      default:
        return status ?? '';
    }
  }

  Color get statusColor {
    switch (status) {
      case '0':
        return const Color(0xFFFFA000);
      case '1':
        return const Color(0xFF1976D2);
      case '2':
        return const Color(0xFF388E3C);
      case '3':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

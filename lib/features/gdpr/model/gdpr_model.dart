class GdprPurposesModel {
  GdprPurposesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(GdprPurpose.fromJson(v)));
    }
  }
  GdprPurposesModel() : data = [];
  String? message;
  List<GdprPurpose>? data;
}

class GdprPurpose {
  GdprPurpose.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    retentionPeriod = json['retention_period']?.toString();
  }
  String? id;
  String? name;
  String? description;
  String? retentionPeriod;
}

class GdprRemovalRequestsModel {
  GdprRemovalRequestsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(GdprRemovalRequest.fromJson(v)));
    }
  }
  GdprRemovalRequestsModel() : data = [];
  String? message;
  List<GdprRemovalRequest>? data;
}

class GdprRemovalRequest {
  GdprRemovalRequest.fromJson(dynamic json) {
    id = json['id']?.toString();
    email = json['email']?.toString();
    description = json['description']?.toString();
    status = json['status']?.toString();
    requestedDate = json['requested_date']?.toString();
  }
  String? id;
  String? email;
  String? description;
  String? status;
  String? requestedDate;

  String get statusLabel {
    switch (status) {
      case '0':
        return 'Pending';
      case '1':
        return 'Processed';
      default:
        return status ?? '';
    }
  }
}

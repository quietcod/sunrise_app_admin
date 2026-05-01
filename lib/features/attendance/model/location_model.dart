class LocationUpdate {
  String? id;
  String? staffId;
  String? updateDate;
  String? updateTime;
  double? latitude;
  double? longitude;
  String? address;
  String? activityNote;

  // Joined staff fields (admin-only listings)
  String? firstname;
  String? lastname;

  LocationUpdate({
    this.id,
    this.staffId,
    this.updateDate,
    this.updateTime,
    this.latitude,
    this.longitude,
    this.address,
    this.activityNote,
    this.firstname,
    this.lastname,
  });

  String get staffFullName {
    final f = (firstname ?? '').trim();
    final l = (lastname ?? '').trim();
    final name = '$f $l'.trim();
    if (name.isNotEmpty) return name;
    if (staffId != null) return 'Staff #$staffId';
    return 'Unknown';
  }

  factory LocationUpdate.fromJson(dynamic json) {
    return LocationUpdate(
      id: json['id']?.toString(),
      staffId: json['staff_id']?.toString(),
      updateDate: json['update_date']?.toString(),
      updateTime: json['update_time']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      address: json['address']?.toString(),
      activityNote: json['activity_note']?.toString(),
      firstname: json['firstname']?.toString(),
      lastname: json['lastname']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'update_date': updateDate,
        'update_time': updateTime,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'activity_note': activityNote,
      };
}

class LocationHistoryModel {
  bool? status;
  String? message;
  List<LocationUpdate>? data;

  LocationHistoryModel({this.status, this.message, this.data});

  factory LocationHistoryModel.fromJson(dynamic json) {
    List<LocationUpdate> list = [];
    if (json['data'] is List) {
      for (final item in json['data'] as List) {
        list.add(LocationUpdate.fromJson(item));
      }
    }
    return LocationHistoryModel(
      status: json['status'],
      message: json['message']?.toString(),
      data: list,
    );
  }
}

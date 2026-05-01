class AttendanceRecord {
  String? id;
  String? staffId;
  String? attendanceDate;

  // Check-In
  String? checkInTime;
  double? checkInLatitude;
  double? checkInLongitude;
  String? checkInAddress;

  // Check-Out
  String? checkOutTime;
  double? checkOutLatitude;
  double? checkOutLongitude;
  String? checkOutAddress;

  // Calculated
  int? durationMinutes;

  // Joined staff fields (only populated when admin fetches all-staff records)
  String? firstname;
  String? lastname;
  String? email;

  AttendanceRecord({
    this.id,
    this.staffId,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAddress,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAddress,
    this.durationMinutes,
    this.firstname,
    this.lastname,
    this.email,
  });

  String get staffFullName {
    final f = (firstname ?? '').trim();
    final l = (lastname ?? '').trim();
    final name = '$f $l'.trim();
    if (name.isNotEmpty) return name;
    if (staffId != null) return 'Staff #$staffId';
    return 'Unknown';
  }

  factory AttendanceRecord.fromJson(dynamic json) {
    return AttendanceRecord(
      id: json['id']?.toString(),
      staffId: json['staff_id']?.toString(),
      attendanceDate: json['attendance_date']?.toString(),
      checkInTime: json['check_in_time']?.toString(),
      checkInLatitude: json['check_in_latitude'] != null
          ? double.tryParse(json['check_in_latitude'].toString())
          : null,
      checkInLongitude: json['check_in_longitude'] != null
          ? double.tryParse(json['check_in_longitude'].toString())
          : null,
      checkInAddress: json['check_in_address']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
      checkOutLatitude: json['check_out_latitude'] != null
          ? double.tryParse(json['check_out_latitude'].toString())
          : null,
      checkOutLongitude: json['check_out_longitude'] != null
          ? double.tryParse(json['check_out_longitude'].toString())
          : null,
      checkOutAddress: json['check_out_address']?.toString(),
      durationMinutes: json['duration_minutes'] != null
          ? int.tryParse(json['duration_minutes'].toString())
          : null,
      firstname: json['firstname']?.toString(),
      lastname: json['lastname']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staff_id': staffId,
        'attendance_date': attendanceDate,
        'check_in_time': checkInTime,
        'check_in_latitude': checkInLatitude,
        'check_in_longitude': checkInLongitude,
        'check_in_address': checkInAddress,
        'check_out_time': checkOutTime,
        'check_out_latitude': checkOutLatitude,
        'check_out_longitude': checkOutLongitude,
        'check_out_address': checkOutAddress,
        'duration_minutes': durationMinutes,
      };

  // Helper: Format duration as HH:MM
  String get formattedDuration {
    if (durationMinutes == null) return '--:--';
    int hours = durationMinutes! ~/ 60;
    int mins = durationMinutes! % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  // Helper: Check if checked in today
  bool get isCheckedIn => checkInTime != null && checkInTime!.isNotEmpty;

  // Helper: Check if checked out today
  bool get isCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;
}

class AttendanceListModel {
  bool? status;
  String? message;
  List<AttendanceRecord>? data;

  AttendanceListModel({this.status, this.message, this.data});

  factory AttendanceListModel.fromJson(dynamic json) {
    List<AttendanceRecord> list = [];
    if (json['data'] is List) {
      for (final item in json['data'] as List) {
        list.add(AttendanceRecord.fromJson(item));
      }
    }
    return AttendanceListModel(
      status: json['status'],
      message: json['message']?.toString(),
      data: list,
    );
  }
}

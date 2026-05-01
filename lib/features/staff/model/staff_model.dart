class StaffListModel {
  StaffListModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(StaffMember.fromJson(v)));
    }
  }
  bool? status;
  String? message;
  List<StaffMember>? data;
}

class StaffMember {
  StaffMember.fromJson(dynamic json) {
    id = json['id']?.toString() ?? json['staffid']?.toString();
    firstname = json['firstname']?.toString();
    lastname = json['lastname']?.toString();
    email = json['email']?.toString();
    phonenumber = json['phonenumber']?.toString();
    position = json['position']?.toString();
    department = json['department']?.toString();
    active = json['active']?.toString();
    lastLogin = json['last_login']?.toString();
    profileImage = json['profile_image']?.toString();
  }

  String? id;
  String? firstname;
  String? lastname;
  String? email;
  String? phonenumber;
  String? position;
  String? department;
  String? active;
  String? lastLogin;
  String? profileImage;

  String get fullName {
    final parts = [firstname, lastname].where((p) => p != null && p.isNotEmpty);
    return parts.join(' ');
  }

  bool get isActive => active == '1';

  String get initials {
    final f = firstname?.isNotEmpty == true ? firstname![0] : '';
    final l = lastname?.isNotEmpty == true ? lastname![0] : '';
    return '$f$l'.toUpperCase();
  }
}

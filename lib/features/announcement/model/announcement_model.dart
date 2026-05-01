class AnnouncementsModel {
  AnnouncementsModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(Announcement.fromJson(v)));
    }
  }
  bool? status;
  String? message;
  List<Announcement>? data;
}

class Announcement {
  Announcement.fromJson(dynamic json) {
    id = json['announcementid']?.toString() ?? json['id']?.toString();
    name = json['name']?.toString();
    message = json['message']?.toString();
    dateadded = json['dateadded']?.toString();
    showto = json['showto']?.toString();
    staffId = json['staff_id']?.toString() ?? json['staffid']?.toString();
  }

  String? id;
  String? name;
  String? message;
  String? dateadded;
  String? showto;
  String? staffId;
}

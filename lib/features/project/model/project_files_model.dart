class ProjectFilesModel {
  ProjectFilesModel({this.data});

  ProjectFilesModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data!.add(ProjectFile.fromJson(v)));
    }
  }

  List<ProjectFile>? data;
}

class ProjectFile {
  ProjectFile.fromJson(dynamic json) {
    id = json['id']?.toString();
    fileName = json['file_name']?.toString() ??
        json['original_name']?.toString() ??
        '';
    fileType =
        json['filetype']?.toString() ?? json['file_type']?.toString() ?? '';
    dateAdded =
        json['dateadded']?.toString() ?? json['date_added']?.toString() ?? '';
    staffId = json['staffid']?.toString() ?? json['staff_id']?.toString();
    lastActivity = json['last_activity']?.toString();
    subject = json['subject']?.toString() ?? '';
    externalLink = json['external_link']?.toString();
    thumbnailLink = json['thumbnail_link']?.toString();
    visible = json['visible_to_customer']?.toString() ?? '0';
  }

  String? id;
  String fileName = '';
  String fileType = '';
  String dateAdded = '';
  String? staffId;
  String? lastActivity;
  String subject = '';
  String? externalLink;
  String? thumbnailLink;
  String visible = '0';
}

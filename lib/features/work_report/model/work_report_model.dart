/// Models for the staff Work Reports feature.
///
/// The server response includes a `meta` block with the current viewer's
/// admin/staff identity so the UI can adapt without a separate profile call.
class WorkReportsModel {
  WorkReportsModel.fromJson(dynamic json) {
    message = json['message'];
    meta = json['meta'] != null ? WorkReportMeta.fromJson(json['meta']) : null;
    if (json['data'] is List) {
      data = [];
      for (final v in (json['data'] as List)) {
        data!.add(WorkReport.fromJson(v));
      }
    }
  }
  WorkReportsModel() : data = [];
  String? message;
  WorkReportMeta? meta;
  List<WorkReport>? data;
}

class WorkReportDetailResponse {
  WorkReportDetailResponse.fromJson(dynamic json) {
    message = json['message'];
    meta = json['meta'] != null ? WorkReportMeta.fromJson(json['meta']) : null;
    data = json['data'] != null ? WorkReport.fromJson(json['data']) : null;
  }
  String? message;
  WorkReportMeta? meta;
  WorkReport? data;
}

class WorkReportMeta {
  WorkReportMeta.fromJson(dynamic json) {
    isAdmin = json['is_admin'] == true ||
        json['is_admin']?.toString() == '1' ||
        json['is_admin']?.toString().toLowerCase() == 'true';
    staffId = json['staff_id']?.toString();
    staffName = json['staff_name']?.toString();
  }
  bool isAdmin = false;
  String? staffId;
  String? staffName;
}

class WorkReport {
  WorkReport.fromJson(dynamic json) {
    id = json['id']?.toString();
    staffId = json['staff_id']?.toString();
    staffName = json['staff_name']?.toString();
    staffImage = json['staff_image']?.toString();
    summary = json['summary']?.toString();
    tasksDone = json['tasks_done']?.toString();
    hoursWorked = json['hours_worked']?.toString();
    blockers = json['blockers']?.toString();
    location = json['location']?.toString();
    project = json['project']?.toString();
    details = json['details']?.toString();
    reportDate = json['report_date']?.toString();
    createdAt = json['created_at']?.toString();
    repliesCount = _toInt(json['replies_count']);
    if (json['replies'] is List) {
      replies = [];
      for (final v in (json['replies'] as List)) {
        replies!.add(WorkReportReply.fromJson(v));
      }
    }
  }
  String? id;
  String? staffId;
  String? staffName;
  String? staffImage;
  String? summary;
  String? tasksDone;
  String? hoursWorked;
  String? blockers;
  String? location;
  String? project;
  String? details;
  String? reportDate;
  String? createdAt;
  int repliesCount = 0;
  List<WorkReportReply>? replies;

  /// Preferred display body — favours new `details` field, falls back to
  /// the legacy `summary` for backward compatibility.
  String get displayDetails {
    final d = (details ?? '').trim();
    if (d.isNotEmpty) return d;
    return (summary ?? '').trim();
  }
}

class WorkReportReply {
  WorkReportReply.fromJson(dynamic json) {
    id = json['id']?.toString();
    reportId = json['report_id']?.toString();
    staffId = json['staff_id']?.toString();
    staffName = json['staff_name']?.toString();
    staffImage = json['staff_image']?.toString();
    isAdmin = json['is_admin'] == true ||
        json['is_admin']?.toString() == '1' ||
        json['is_admin']?.toString().toLowerCase() == 'true';
    message = json['message']?.toString();
    createdAt = json['created_at']?.toString();
  }
  String? id;
  String? reportId;
  String? staffId;
  String? staffName;
  String? staffImage;
  bool isAdmin = false;
  String? message;
  String? createdAt;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

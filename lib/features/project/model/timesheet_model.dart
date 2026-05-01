class TimesheetsModel {
  List<TimesheetEntry>? data;

  TimesheetsModel({this.data});

  TimesheetsModel.fromJson(dynamic json) {
    if (json == null) return;
    // The Perfex API may return either a root array or a map with a 'data'
    // or top-level list key.
    final raw = json is Map ? (json['data'] ?? json['timesheets'] ?? []) : json;
    if (raw is List) {
      data =
          raw.whereType<Map>().map((e) => TimesheetEntry.fromJson(e)).toList();
    } else {
      data = [];
    }
  }
}

class TimesheetEntry {
  TimesheetEntry({
    this.id,
    this.taskId,
    this.taskName,
    this.staffId,
    this.staffName,
    this.startTime,
    this.endTime,
    this.timeSpent,
    this.note,
  });

  factory TimesheetEntry.fromJson(dynamic json) {
    return TimesheetEntry(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString(),
      taskName: json['task_name']?.toString(),
      staffId: json['staff_id']?.toString(),
      staffName: json['staff_name']?.toString() ??
          [json['firstname'], json['lastname']]
              .where((v) => v != null && v.toString().trim().isNotEmpty)
              .join(' '),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      timeSpent:
          json['time_spent']?.toString() ?? json['hours_worked']?.toString(),
      note: json['note']?.toString(),
    );
  }

  final String? id;
  final String? taskId;
  final String? taskName;
  final String? staffId;
  final String? staffName;
  final String? startTime;
  final String? endTime;
  final String? timeSpent;
  final String? note;
}

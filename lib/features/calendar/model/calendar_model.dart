class CalendarEventsModel {
  CalendarEventsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(CalendarEvent.fromJson(v)));
    }
  }
  CalendarEventsModel() : data = [];
  String? message;
  List<CalendarEvent>? data;
}

class CalendarEvent {
  CalendarEvent.fromJson(dynamic json) {
    id = json['id']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();
    start = json['start']?.toString();
    end = json['end']?.toString();
    color = json['color']?.toString();
    isPublic = json['public']?.toString();
    addedFrom = json['addedfrom']?.toString();
  }
  String? id;
  String? title;
  String? description;
  String? start;
  String? end;
  String? color;
  String? isPublic;
  String? addedFrom;

  DateTime? get startDate => start != null ? DateTime.tryParse(start!) : null;
  DateTime? get endDate => end != null ? DateTime.tryParse(end!) : null;
}

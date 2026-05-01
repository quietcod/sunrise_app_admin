class MilestonesModel {
  List<MilestoneEntry>? data;

  MilestonesModel({this.data});

  MilestonesModel.fromJson(dynamic json) {
    if (json == null) return;
    final raw = json is Map ? (json['data'] ?? json['milestones'] ?? []) : json;
    if (raw is List) {
      data =
          raw.whereType<Map>().map((e) => MilestoneEntry.fromJson(e)).toList();
    } else {
      data = [];
    }
  }
}

class MilestoneEntry {
  MilestoneEntry({
    this.id,
    this.name,
    this.dueDate,
    this.milestoneOrder,
    this.description,
    this.color,
  });

  factory MilestoneEntry.fromJson(dynamic json) {
    return MilestoneEntry(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      dueDate: json['due_date']?.toString(),
      milestoneOrder: json['milestone_order']?.toString(),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
    );
  }

  final String? id;
  final String? name;
  final String? dueDate;
  final String? milestoneOrder;
  final String? description;
  final String? color;
}

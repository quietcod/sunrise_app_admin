class TodosModel {
  TodosModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(TodoItem.fromJson(v)));
    }
  }

  bool? status;
  String? message;
  List<TodoItem>? data;
}

class TodoItem {
  TodoItem({
    this.id,
    this.description,
    this.finished,
    this.dateadded,
    this.datefinished,
    this.itemOrder,
  });

  TodoItem.fromJson(dynamic json) {
    id = json['todoid']?.toString() ?? json['id']?.toString();
    description = json['description']?.toString();
    finished = json['finished']?.toString();
    dateadded = json['dateadded']?.toString();
    datefinished = json['datefinished']?.toString();
    itemOrder = json['item_order']?.toString();
  }

  String? id;
  String? description;
  String? finished;
  String? dateadded;
  String? datefinished;
  String? itemOrder;

  bool get isDone => finished == '1';
}

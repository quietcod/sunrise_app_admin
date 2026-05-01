class KbGroupsModel {
  KbGroupsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(KbGroup.fromJson(v)));
    }
  }
  KbGroupsModel() : data = [];
  String? message;
  List<KbGroup>? data;
}

class KbGroup {
  KbGroup.fromJson(dynamic json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    articleCount = json['article_count']?.toString() ?? '0';
  }
  String? id;
  String? name;
  String? articleCount;
}

class KbArticlesModel {
  KbArticlesModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(KbArticle.fromJson(v)));
    }
  }
  KbArticlesModel() : data = [];
  String? message;
  List<KbArticle>? data;
}

class KbArticle {
  KbArticle.fromJson(dynamic json) {
    id = json['id']?.toString();
    subject = json['subject']?.toString();
    description = json['description']?.toString();
    active = json['active']?.toString();
    groupId = json['group_id']?.toString();
    groupName = json['group_name']?.toString();
  }
  String? id;
  String? subject;
  String? description;
  String? active;
  String? groupId;
  String? groupName;

  bool get isActive => active == '1';
}

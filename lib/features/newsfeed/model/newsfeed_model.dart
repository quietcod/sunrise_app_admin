class NewsfeedPostsModel {
  NewsfeedPostsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(NewsfeedPost.fromJson(v)));
    }
  }
  NewsfeedPostsModel() : data = [];
  String? message;
  List<NewsfeedPost>? data;
}

class NewsfeedPost {
  NewsfeedPost.fromJson(dynamic json) {
    id = json['id']?.toString();
    message = json['message']?.toString();
    staffName = json['staff_name']?.toString();
    profileImage = json['profile_image']?.toString();
    dateAdded = json['date_added']?.toString();
    pinned = json['pinned']?.toString();
    likesCount = int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0;
    commentsCount =
        int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0;
    likedByMe = json['liked_by_me'] == true || json['liked_by_me'] == 1;
  }
  String? id;
  String? message;
  String? staffName;
  String? profileImage;
  String? dateAdded;
  String? pinned;
  int likesCount = 0;
  int commentsCount = 0;
  bool likedByMe = false;

  bool get isPinned => pinned == '1';
}

class NewsfeedCommentsModel {
  NewsfeedCommentsModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) => data?.add(NewsfeedComment.fromJson(v)));
    }
  }
  NewsfeedCommentsModel() : data = [];
  String? message;
  List<NewsfeedComment>? data;
}

class NewsfeedComment {
  NewsfeedComment.fromJson(dynamic json) {
    id = json['id']?.toString();
    postId = json['post_id']?.toString();
    content = json['content']?.toString();
    staffName = json['staff_name']?.toString();
    dateAdded = json['date_added']?.toString();
  }
  String? id;
  String? postId;
  String? content;
  String? staffName;
  String? dateAdded;
}

class NotificationsModel {
  NotificationsModel({
    bool? status,
    String? message,
    List<NotificationItem>? data,
    int? unreadCount,
  }) {
    _status = status;
    _message = message;
    _data = data;
    _unreadCount = unreadCount;
  }

  NotificationsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _unreadCount = json['unread_count'] as int? ?? 0;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(NotificationItem.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<NotificationItem>? _data;
  int? _unreadCount;

  bool? get status => _status;
  String? get message => _message;
  List<NotificationItem>? get data => _data;
  int get unreadCount => _unreadCount ?? 0;
}

class NotificationItem {
  NotificationItem({
    String? id,
    String? description,
    String? fromuserid,
    String? fromclientid,
    String? touserid,
    String? isread,
    String? isreadInline,
    String? link,
    String? additionalData,
    String? date,
  }) {
    _id = id;
    _description = description;
    _fromuserid = fromuserid;
    _fromclientid = fromclientid;
    _touserid = touserid;
    _isread = isread;
    _isreadInline = isreadInline;
    _link = link;
    _additionalData = additionalData;
    _date = date;
  }

  NotificationItem.fromJson(dynamic json) {
    _id = json['id']?.toString();
    _description = json['description']?.toString();
    _fromuserid = json['fromuserid']?.toString();
    _fromclientid = json['fromclientid']?.toString();
    _touserid = json['touserid']?.toString();
    _isread = json['isread']?.toString();
    _isreadInline = json['isread_inline']?.toString();
    _link = json['link']?.toString();
    _additionalData = json['additional_data']?.toString();
    _date = json['date']?.toString();
  }

  String? _id;
  String? _description;
  String? _fromuserid;
  String? _fromclientid;
  String? _touserid;
  String? _isread;
  String? _isreadInline;
  String? _link;
  String? _additionalData;
  String? _date;

  String? get id => _id;
  String? get description => _description;
  String? get fromuserid => _fromuserid;
  String? get fromclientid => _fromclientid;
  String? get touserid => _touserid;
  String? get isread => _isread;
  String? get isreadInline => _isreadInline;
  String? get link => _link;
  String? get additionalData => _additionalData;
  String? get date => _date;

  bool get isUnread => _isread == '0' || _isreadInline == '0';

  /// Format the description key into a human-readable title.
  String get displayTitle {
    if (_description == null || _description!.isEmpty) return 'Notification';
    return _description!
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

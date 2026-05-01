import 'dart:convert';

import 'package:flutex_admin/features/notification/model/notification_model.dart';
import 'package:flutex_admin/features/notification/repo/notification_repo.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  bool isLoading = true;
  List<NotificationItem> notificationList = [];

  @override
  void onInit() {
    super.onInit();
    initialData();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    if (shouldLoad) {
      isLoading = true;
      update();
    }
    await _loadNotifications();
    isLoading = false;
    update();
  }

  Future<void> _loadNotifications() async {
    final response = await notificationRepo.getAllNotifications();
    if (response.status) {
      final model =
          NotificationsModel.fromJson(jsonDecode(response.responseJson));
      notificationList = model.data ?? [];
    }
  }

  Future<void> markAsRead(String id) async {
    await notificationRepo.markNotificationRead(id);
    final idx = notificationList.indexWhere((n) => n.id == id);
    if (idx != -1) {
      // Replace with updated read state (rebuild from existing data)
      final old = notificationList[idx];
      notificationList[idx] = NotificationItem.fromJson({
        'id': old.id,
        'description': old.description,
        'fromuserid': old.fromuserid,
        'fromclientid': old.fromclientid,
        'touserid': old.touserid,
        'isread': '1',
        'isread_inline': '1',
        'link': old.link,
        'additional_data': old.additionalData,
        'date': old.date,
      });
    }
    update();
  }

  Future<void> markAllAsRead() async {
    await notificationRepo.markAllNotificationsRead();
    notificationList = notificationList.map((n) {
      return NotificationItem.fromJson({
        'id': n.id,
        'description': n.description,
        'fromuserid': n.fromuserid,
        'fromclientid': n.fromclientid,
        'touserid': n.touserid,
        'isread': '1',
        'isread_inline': '1',
        'link': n.link,
        'additional_data': n.additionalData,
        'date': n.date,
      });
    }).toList();
    update();
  }

  int get unreadCount => notificationList.where((n) => n.isUnread).length;
}

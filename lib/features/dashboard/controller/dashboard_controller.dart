import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardRepo dashboardRepo;
  DashboardController({required this.dashboardRepo});

  bool isLoading = true;
  bool logoutLoading = false;
  int currentPageIndex = 0;
  int unreadNotificationCount = 0;
  int scopedTicketTotal = 0;
  int scopedTicketLow = 0;
  int scopedTicketMedium = 0;
  int scopedTicketHigh = 0;
  bool scopedTicketLoaded = false;
  DashboardModel homeModel = DashboardModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<dynamic> loadData() async {
    final results = await Future.wait([
      dashboardRepo.getData(),
      dashboardRepo.fetchUnreadNotificationCount(),
      dashboardRepo.getTicketsSnapshot(),
    ]);
    final responseModel = results[0] as ResponseModel;
    unreadNotificationCount = results[1] as int;
    final ticketResponse = results[2] as ResponseModel;
    if (responseModel.status) {
      homeModel =
          DashboardModel.fromJson(jsonDecode(responseModel.responseJson));
      _hydrateScopedTicketStats(ticketResponse);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  void _hydrateScopedTicketStats(ResponseModel responseModel) {
    scopedTicketTotal = 0;
    scopedTicketLow = 0;
    scopedTicketMedium = 0;
    scopedTicketHigh = 0;
    scopedTicketLoaded = true;

    if (!responseModel.status) return;

    try {
      final data = jsonDecode(responseModel.responseJson);
      final tickets = data['data'];

      if (tickets is List && tickets.isNotEmpty) {
        for (final raw in tickets) {
          if (raw is! Map) continue;
          scopedTicketTotal += 1;

          final priorityRaw = '${raw['priority'] ?? raw['priorityid'] ?? ''}'
              .trim()
              .toLowerCase();
          final priorityName =
              '${raw['priority_name'] ?? raw['priorityname'] ?? ''}'
                  .trim()
                  .toLowerCase();

          if (priorityRaw == '1' || priorityName.contains('low')) {
            scopedTicketLow += 1;
          } else if (priorityRaw == '2' ||
              priorityName.contains('medium') ||
              priorityName.contains('med')) {
            scopedTicketMedium += 1;
          } else if (priorityRaw == '3' ||
              priorityRaw == '4' ||
              priorityName.contains('high') ||
              priorityName.contains('urgent') ||
              priorityName.contains('critical')) {
            scopedTicketHigh += 1;
          }
        }
        return;
      }

      // Fallback: some payloads return only overview buckets.
      final overview = data['overview'];
      if (overview is List && overview.isNotEmpty) {
        for (final raw in overview) {
          if (raw is! Map) continue;
          final status = '${raw['status'] ?? ''}'.trim().toLowerCase();
          final total = int.tryParse('${raw['total'] ?? '0'}') ?? 0;
          scopedTicketTotal += total;

          if (status == '1' || status.contains('low')) {
            scopedTicketLow += total;
          } else if (status == '2' || status.contains('medium')) {
            scopedTicketMedium += total;
          } else if (status == '3' ||
              status == '4' ||
              status.contains('high') ||
              status.contains('urgent') ||
              status.contains('critical')) {
            scopedTicketHigh += total;
          }
        }
      }
    } catch (_) {
      // Keep zeroed defaults when payload shape is unexpected.
    }
  }

  Future<void> logout() async {
    logoutLoading = true;
    update();

    ResponseModel responseModel = await dashboardRepo.logout();

    if (responseModel.status) {
      await dashboardRepo.apiClient.sharedPreferences
          .setString(SharedPreferenceHelper.accessTokenKey, '');
      await dashboardRepo.apiClient.sharedPreferences
          .setBool(SharedPreferenceHelper.rememberMeKey, false);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
      Get.offAllNamed(RouteHelper.loginScreen);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    logoutLoading = false;
    update();
  }
}

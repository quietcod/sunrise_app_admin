import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/calendar/model/calendar_model.dart';
import 'package:flutex_admin/features/calendar/repo/calendar_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  CalendarRepo calendarRepo;
  CalendarController({required this.calendarRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  CalendarEventsModel eventsModel = CalendarEventsModel();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime? selectedStart;
  DateTime? selectedEnd;
  bool isPublic = false;

  Future<void> loadEvents({DateTime? focusedDay}) async {
    isLoading = true;
    update();
    final day = focusedDay ?? DateTime.now();
    final start =
        DateTime(day.year, day.month, 1).toIso8601String().split('T').first;
    final end =
        DateTime(day.year, day.month + 1, 0).toIso8601String().split('T').first;
    final res = await calendarRepo.getEvents(start: start, end: end);
    eventsModel = res.status
        ? CalendarEventsModel.fromJson(jsonDecode(res.responseJson))
        : CalendarEventsModel();
    isLoading = false;
    update();
  }

  List<CalendarEvent> eventsForDay(DateTime day) {
    return (eventsModel.data ?? []).where((e) {
      final s = e.startDate;
      final en = e.endDate;
      if (s == null) return false;
      final d = DateTime(day.year, day.month, day.day);
      final start = DateTime(s.year, s.month, s.day);
      final endDay = en != null ? DateTime(en.year, en.month, en.day) : start;
      return !d.isBefore(start) && !d.isAfter(endDay);
    }).toList();
  }

  Future<void> addEvent() async {
    if (titleController.text.trim().isEmpty || selectedStart == null) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res = await calendarRepo.addEvent({
      'title': titleController.text.trim(),
      'description': descController.text.trim(),
      'start': selectedStart!.toIso8601String(),
      'end': (selectedEnd ?? selectedStart!).toIso8601String(),
      'public': isPublic ? '1' : '0',
    });
    isSubmitLoading = false;
    update();
    if (res.status) {
      clearForm();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadEvents(focusedDay: selectedStart);
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteEvent(String id) async {
    final res = await calendarRepo.deleteEvent(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadEvents();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  void clearForm() {
    titleController.clear();
    descController.clear();
    selectedStart = null;
    selectedEnd = null;
    isPublic = false;
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}

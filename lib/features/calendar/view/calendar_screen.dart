import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/helper/my_permissions.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/util.dart';
import 'package:flutex_admin/features/calendar/controller/calendar_controller.dart';
import 'package:flutex_admin/features/calendar/model/calendar_model.dart';
import 'package:flutex_admin/features/calendar/repo/calendar_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CalendarRepo(apiClient: Get.find()));
    final c = Get.put(CalendarController(calendarRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => c.loadEvents(focusedDay: _focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(builder: (controller) {
      final eventsForDay = controller.eventsForDay(_selectedDay);

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.calendar.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canCreateCalendar)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showAddDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Column(
                children: [
                  // Month navigator
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space15,
                        vertical: Dimensions.space10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {
                            setState(() {
                              _focusedDay = DateTime(
                                  _focusedDay.year, _focusedDay.month - 1);
                            });
                            controller.loadEvents(focusedDay: _focusedDay);
                          },
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            textAlign: TextAlign.center,
                            style: regularDefault.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            setState(() {
                              _focusedDay = DateTime(
                                  _focusedDay.year, _focusedDay.month + 1);
                            });
                            controller.loadEvents(focusedDay: _focusedDay);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Mini calendar grid
                  _MiniCalendar(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    events: controller.eventsModel.data ?? [],
                    onDaySelected: (day) {
                      setState(() => _selectedDay = day);
                    },
                  ),

                  // Events for selected day
                  Expanded(
                    child: eventsForDay.isEmpty
                        ? Center(
                            child: Text(LocalStrings.noData.tr,
                                style: regularSmall.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            itemCount: eventsForDay.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: Dimensions.space10),
                            itemBuilder: (context, i) {
                              final ev = eventsForDay[i];
                              return _EventCard(
                                event: ev,
                                onDelete: MyPermissions.canDeleteCalendar
                                    ? () => _confirmDelete(
                                        context, controller, ev.id!)
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
      );
    });
  }

  void _showAddDialog(BuildContext context, CalendarController controller) {
    controller.clearForm();
    controller.selectedStart = _selectedDay;
    showDialog(
      context: context,
      builder: (_) => GetBuilder<CalendarController>(builder: (c) {
        return AlertDialog(
          title: Text(LocalStrings.addEvent.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: c.titleController,
                  decoration: InputDecoration(labelText: LocalStrings.title.tr),
                ),
                TextField(
                  controller: c.descController,
                  decoration:
                      InputDecoration(labelText: LocalStrings.description.tr),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(c.selectedStart != null
                        ? DateFormat('MMM dd, yyyy').format(c.selectedStart!)
                        : LocalStrings.selectDate.tr),
                    TextButton(
                      child: Text(LocalStrings.change.tr),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: c.selectedStart ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          c.selectedStart = picked;
                          c.update();
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.public_rounded,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(LocalStrings.public.tr),
                    Checkbox(
                      value: c.isPublic,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (v) {
                        c.isPublic = v ?? false;
                        c.update();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child: Text(LocalStrings.cancel.tr)),
            c.isSubmitLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: c.addEvent,
                    child: Text(LocalStrings.submit.tr,
                        style: const TextStyle(color: Colors.white))),
          ],
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, CalendarController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteEvent(id);
      },
      title: LocalStrings.deleteEvent.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar(
      {required this.focusedDay,
      required this.selectedDay,
      required this.events,
      required this.onDaySelected});
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final void Function(DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(focusedDay.year, focusedDay.month, 1);
    final daysInMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // 0=Sun
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final eventDays = events
        .map((e) => e.startDate)
        .where((d) => d != null)
        .map((d) => d!)
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space10, vertical: 4),
      child: Column(
        children: [
          // Day headers
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: regularSmall.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color)),
                    ))
                .toList(),
          ),
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final day = index - startWeekday + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 36));
                }
                final date = DateTime(focusedDay.year, focusedDay.month, day);
                final isSelected = date.year == selectedDay.year &&
                    date.month == selectedDay.month &&
                    date.day == selectedDay.day;
                final hasEvent = eventDays.contains(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDaySelected(date),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle)
                          : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('$day',
                              style: regularSmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color)),
                          if (hasEvent && !isSelected)
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onDelete});
  final CalendarEvent event;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          boxShadow: MyUtils.getCardShadow(context)),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title ?? '',
                    style: regularDefault.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium!.color)),
                if ((event.description ?? '').isNotEmpty)
                  Text(event.description!,
                      style: regularSmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
                icon: Icon(Icons.delete_rounded,
                    size: 18, color: Theme.of(context).colorScheme.error),
                onPressed: onDelete),
        ],
      ),
    );
  }
}

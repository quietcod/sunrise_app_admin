import 'dart:convert';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTimesheetsScreen extends StatefulWidget {
  const MyTimesheetsScreen({super.key});

  @override
  State<MyTimesheetsScreen> createState() => _MyTimesheetsScreenState();
}

class _MyTimesheetsScreenState extends State<MyTimesheetsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final repo = Get.find<ProfileRepo>();
    final ResponseModel resp = await repo.getMyTimesheets();
    if (resp.status) {
      final data = jsonDecode(resp.responseJson);
      final list = data['data'] as List? ?? [];
      setState(() {
        _entries =
            list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(dynamic startRaw, dynamic endRaw) {
    if (startRaw == null) return '';
    try {
      final int startTs = int.tryParse(startRaw.toString()) ?? 0;
      final int endTs = endRaw != null && endRaw.toString().isNotEmpty
          ? (int.tryParse(endRaw.toString()) ?? 0)
          : 0;
      if (startTs == 0) return '';
      final start = DateTime.fromMillisecondsSinceEpoch(startTs * 1000);
      final end = endTs > 0
          ? DateTime.fromMillisecondsSinceEpoch(endTs * 1000)
          : DateTime.now();
      final diff = end.difference(start);
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      if (h > 0) return '${h}h ${m}m';
      return '${m}m';
    } catch (_) {
      return '';
    }
  }

  String _formatTimestamp(dynamic tsRaw) {
    if (tsRaw == null || tsRaw.toString().isEmpty) return '';
    try {
      final int ts = int.tryParse(tsRaw.toString()) ?? 0;
      if (ts == 0) return '';
      final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timesheets'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const CustomLoader()
          : _entries.isEmpty
              ? const Center(child: NoDataWidget())
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space8),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      final taskName =
                          entry['task_name']?.toString() ?? 'Unknown Task';
                      final startRaw = entry['start_time'];
                      final endRaw = entry['end_time'];
                      final isActive = endRaw == null ||
                          endRaw.toString() == '0' ||
                          endRaw.toString().isEmpty;
                      final duration =
                          _formatDuration(startRaw, isActive ? null : endRaw);
                      final startFormatted = _formatTimestamp(startRaw);
                      final endFormatted =
                          isActive ? 'Running...' : _formatTimestamp(endRaw);
                      final note = entry['note']?.toString() ?? '';
                      final hourlyRate = entry['hourly_rate']?.toString() ?? '';

                      return Container(
                        padding: const EdgeInsets.all(Dimensions.space12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.4)
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (isActive
                                        ? Colors.green
                                        : Theme.of(context).primaryColor)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isActive
                                    ? Icons.timer_outlined
                                    : Icons.timer_off_outlined,
                                size: 20,
                                color: isActive
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taskName,
                                    style: regularDefault.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.play_arrow_rounded,
                                          size: 14,
                                          color: ColorResources.blueGreyColor),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          startFormatted,
                                          style: regularSmall.copyWith(
                                              color:
                                                  ColorResources.blueGreyColor,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        isActive
                                            ? Icons.fiber_manual_record
                                            : Icons.stop_rounded,
                                        size: 14,
                                        color: isActive
                                            ? Colors.green
                                            : ColorResources.blueGreyColor,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          endFormatted,
                                          style: regularSmall.copyWith(
                                              color: isActive
                                                  ? Colors.green
                                                  : ColorResources
                                                      .blueGreyColor,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (note.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      note,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: regularSmall.copyWith(
                                          color: isDark
                                              ? Colors.white70
                                              : ColorResources.contentTextColor,
                                          fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: Dimensions.space8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (duration.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      duration,
                                      style: regularSmall.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                    ),
                                  ),
                                if (hourlyRate.isNotEmpty &&
                                    hourlyRate != '0.00') ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$$hourlyRate/h',
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor,
                                        fontSize: 10),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.index,
    required this.projectModel,
  });
  final int index;
  final ProjectsModel projectModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final project = projectModel.data![index];
    final statusColor = ColorResources.projectStatusColor(project.status ?? '');
    final progress = double.tryParse(project.progress ?? '0') ?? 0;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(RouteHelper.projectDetailsScreen, arguments: project.id!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF343434), const Color(0xFF343434)]
                    : [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                        const Color(0xFFEFF3F8).withValues(alpha: 0.65),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    (isDark ? const Color(0xFF2A3347) : const Color(0xFFD8E2F0))
                        .withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.blueGrey)
                      .withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (Get.find<ProjectController>()
                                .isProjectPinned(project.id)) ...[
                              Icon(Icons.push_pin,
                                  size: 14,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                project.name ?? '',
                                style: semiBoldDefault.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          Converter.projectStatusString(project.status ?? ''),
                          style: regularSmall.copyWith(
                              color: statusColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if ((project.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: Dimensions.space5),
                    Text(
                      Converter.parseHtmlString(project.description ?? ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor),
                    ),
                  ],
                  const SizedBox(height: Dimensions.space10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: progress * 0.01,
                            color: statusColor,
                            backgroundColor: (isDark
                                    ? const Color(0xFF2A3347)
                                    : const Color(0xFFD0DAE8))
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Text(
                        '${progress.toInt()}%',
                        style: regularSmall.copyWith(
                            color: statusColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Divider(
                    color: (isDark
                            ? const Color(0xFF2A3347)
                            : const Color(0xFFD0DAE8))
                        .withValues(alpha: 0.7),
                    height: 1,
                  ),
                  const SizedBox(height: Dimensions.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 13, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          project.startDate ?? '',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ]),
                      Row(children: [
                        Icon(Icons.business_center_outlined,
                            size: 13, color: ColorResources.blueGreyColor),
                        const SizedBox(width: 4),
                        Text(
                          project.company ?? '',
                          style: regularSmall.copyWith(
                              color: ColorResources.blueGreyColor),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

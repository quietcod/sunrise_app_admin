import 'dart:ui';

import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutter/material.dart';

class StaffCard extends StatelessWidget {
  const StaffCard({
    super.key,
    required this.member,
    required this.isDark,
    required this.onTap,
  });

  final StaffMember member;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF343434) : Colors.white)
                    .withValues(alpha: .45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ColorResources.secondaryColor.withValues(alpha: .2),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        ColorResources.secondaryColor.withValues(alpha: .18),
                    backgroundImage: member.profileImage != null &&
                            member.profileImage!.isNotEmpty
                        ? NetworkImage(member.profileImage!)
                        : null,
                    child: member.profileImage == null ||
                            member.profileImage!.isEmpty
                        ? Text(
                            member.initials,
                            style: semiBoldDefault.copyWith(
                              color: ColorResources.secondaryColor,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          style: semiBoldDefault.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (member.position != null &&
                            member.position!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            member.position!,
                            style: regularSmall.copyWith(
                                color: ColorResources.contentTextColor),
                          ),
                        ],
                        if (member.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            member.email!,
                            style: regularSmall.copyWith(
                              color: ColorResources.contentTextColor,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Active badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: member.isActive
                          ? ColorResources.colorGreen.withValues(alpha: .15)
                          : ColorResources.colorGrey.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member.isActive ? 'Active' : 'Inactive',
                      style: semiBoldSmall.copyWith(
                        color: member.isActive
                            ? ColorResources.colorGreen
                            : ColorResources.contentTextColor,
                        fontSize: 10,
                      ),
                    ),
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

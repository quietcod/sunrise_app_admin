import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMembersWidget extends StatefulWidget {
  const ProjectMembersWidget({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectMembersWidget> createState() => _ProjectMembersWidgetState();
}

class _ProjectMembersWidgetState extends State<ProjectMembersWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(builder: (controller) {
      if (controller.isLoading) return const CustomLoader();

      final members = controller.projectDetailsModel.data?.projectMembers ?? [];

      return Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 0),
            child: Row(
              children: [
                const Icon(Icons.group_outlined, size: 18),
                const SizedBox(width: 6),
                Text('Members',
                    style: regularDefault.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add', style: TextStyle(fontSize: 12)),
                  onPressed: () =>
                      _showAddMemberSheet(context, controller, members),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── List ──────────────────────────────────────────────────
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(Dimensions.space20),
              child: Center(
                child: Text('No members yet',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space10),
                itemCount: members.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 0.4),
                itemBuilder: (ctx, i) {
                  final m = members[i];
                  final name = m.staffName ?? 'Staff';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey.shade300,
                      child: Text(initial,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white)),
                    ),
                    title: Text(name, style: regularDefault),
                    subtitle: m.email != null && m.email!.isNotEmpty
                        ? Text(m.email!,
                            style: regularSmall.copyWith(
                                color: ColorResources.blueGreyColor,
                                fontSize: 11))
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          size: 18,
                          color: Colors.redAccent.withValues(alpha: 0.8)),
                      onPressed: () => controller.removeProjectMember(
                          widget.projectId, m.staffId ?? ''),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Future<void> _showAddMemberSheet(BuildContext context,
      ProjectController controller, currentMembers) async {
    final staffList = await controller.loadAllStaff();
    if (!context.mounted) return;

    final existingIds = currentMembers.map((m) => m.staffId ?? '').toSet();
    final available =
        staffList.where((s) => !existingIds.contains(s.id ?? '')).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('All staff members are already in this project.')));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Add Member',
                  style: regularDefault.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                itemCount: available.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = available[i];
                  final name = s.fullName.isNotEmpty ? s.fullName : 'Staff';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey.shade200,
                      child: Text(initial,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white)),
                    ),
                    title: Text(name, style: regularDefault),
                    subtitle: s.position != null && s.position!.isNotEmpty
                        ? Text(s.position!,
                            style: regularSmall.copyWith(
                                color: ColorResources.blueGreyColor,
                                fontSize: 11))
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.addProjectMember(
                          widget.projectId, s.id ?? '', () {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/task/controller/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskTeam extends StatefulWidget {
  const TaskTeam({super.key, required this.taskId});
  final String taskId;

  @override
  State<TaskTeam> createState() => _TaskTeamState();
}

class _TaskTeamState extends State<TaskTeam> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TaskController>().loadTaskTeam(widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(builder: (controller) {
      if (controller.isTeamLoading) return const CustomLoader();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.space15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Assignees ─────────────────────────────────────────────
            _SectionHeader(
              title: 'Assignees',
              icon: Icons.person_outlined,
              color: Colors.blueAccent,
              onAdd: () => _showAddStaffDialog(
                context,
                controller,
                isAssignee: true,
              ),
            ),
            const SizedBox(height: Dimensions.space8),
            if (controller.taskAssignees.isEmpty)
              _EmptyHint(text: 'No assignees yet')
            else
              ...controller.taskAssignees.map((m) => _MemberTile(
                    member: m,
                    onRemove: () => controller.removeAssignee(
                      widget.taskId,
                      m['staffid']?.toString() ?? m['id']?.toString() ?? '',
                    ),
                  )),
            const SizedBox(height: Dimensions.space20),
            // ── Followers ─────────────────────────────────────────────
            _SectionHeader(
              title: 'Followers',
              icon: Icons.visibility_outlined,
              color: Colors.orangeAccent,
              onAdd: () => _showAddStaffDialog(
                context,
                controller,
                isAssignee: false,
              ),
            ),
            const SizedBox(height: Dimensions.space8),
            if (controller.taskFollowers.isEmpty)
              _EmptyHint(text: 'No followers yet')
            else
              ...controller.taskFollowers.map((m) => _MemberTile(
                    member: m,
                    onRemove: () => controller.removeFollower(
                      widget.taskId,
                      m['staffid']?.toString() ?? m['id']?.toString() ?? '',
                    ),
                  )),
          ],
        ),
      );
    });
  }

  Future<void> _showAddStaffDialog(
    BuildContext context,
    TaskController controller, {
    required bool isAssignee,
  }) async {
    final staffList = await controller.loadAllStaff();
    if (!context.mounted) return;

    final existing =
        isAssignee ? controller.taskAssignees : controller.taskFollowers;
    final existingIds = existing
        .map((m) => m['staffid']?.toString() ?? m['id']?.toString() ?? '')
        .toSet();

    final available =
        staffList.where((s) => !existingIds.contains(s.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'All staff members are already ${isAssignee ? 'assigned' : 'following'}.'),
        ),
      );
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
              child: Text(isAssignee ? 'Add Assignee' : 'Add Follower',
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
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey.shade200,
                      child: Text(
                          (s.firstname?.isNotEmpty == true
                                  ? s.firstname![0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white)),
                    ),
                    title: Text(s.fullName,
                        style: regularDefault.copyWith(fontSize: 13)),
                    subtitle: s.position != null && s.position!.isNotEmpty
                        ? Text(s.position!,
                            style: regularSmall.copyWith(
                                color: ColorResources.blueGreyColor,
                                fontSize: 11))
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isAssignee) {
                        controller.addAssignee(widget.taskId, s.id ?? '');
                      } else {
                        controller.addFollower(widget.taskId, s.id ?? '');
                      }
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.onAdd,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(title,
            style: regularDefault.copyWith(
                fontWeight: FontWeight.bold, fontSize: 14)),
        const Spacer(),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add', style: TextStyle(fontSize: 12)),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onRemove});
  final Map<String, dynamic> member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = [
      member['firstname']?.toString(),
      member['lastname']?.toString()
    ].where((v) => v != null && v.isNotEmpty).join(' ').trim();
    final displayName = name.isNotEmpty ? name : 'Staff member';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space8),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space12, vertical: Dimensions.space8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
            .withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueGrey.shade300,
            child: Text(initial,
                style: const TextStyle(fontSize: 12, color: Colors.white)),
          ),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child:
                Text(displayName, style: regularDefault.copyWith(fontSize: 13)),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline,
                size: 18, color: Colors.redAccent.withValues(alpha: 0.8)),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
      child: Text(text,
          style: regularSmall.copyWith(
              color: ColorResources.blueGreyColor, fontSize: 13)),
    );
  }
}

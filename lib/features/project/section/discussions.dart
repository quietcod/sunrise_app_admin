import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectDiscussions extends StatefulWidget {
  const ProjectDiscussions({super.key, required this.id});
  final String id;

  @override
  State<ProjectDiscussions> createState() => _ProjectDiscussionsState();
}

class _ProjectDiscussionsState extends State<ProjectDiscussions> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDiscussions(widget.id);
    });
  }

  void _showAddDiscussionDialog(
      BuildContext context, ProjectController controller) {
    final subjectCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool visibleToClient = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Discussion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Subject *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                      value: visibleToClient,
                      onChanged: (val) =>
                          setDialogState(() => visibleToClient = val),
                    ),
                    const SizedBox(width: 8),
                    const Text('Visible to client'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final subject = subjectCtrl.text.trim();
                if (subject.isEmpty) return;
                Navigator.pop(ctx);
                controller.addDiscussion(widget.id, subject,
                    contentCtrl.text.trim(), visibleToClient);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommentDialog(
      BuildContext context, ProjectController controller, String discussionId) {
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: contentCtrl,
          decoration: const InputDecoration(
              labelText: 'Comment', border: OutlineInputBorder()),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final content = contentCtrl.text.trim();
              if (content.isEmpty) return;
              Navigator.pop(ctx);
              controller.addDiscussionComment(widget.id, discussionId, content);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isDiscussionsLoading) return const CustomLoader();
        final discussions = controller.projectDiscussionsList;
        return Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              onRefresh: () async => controller.loadDiscussions(widget.id),
              child: discussions.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: NoDataWidget()),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                          left: Dimensions.space15,
                          right: Dimensions.space15,
                          top: Dimensions.space10,
                          bottom: 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: discussions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, index) {
                        final d = discussions[index];
                        return _DiscussionCard(
                          discussion: d,
                          projectId: widget.id,
                          onDelete: () => controller.deleteDiscussion(
                              widget.id, d['id']?.toString() ?? ''),
                          onAddComment: () => _showAddCommentDialog(
                              context, controller, d['id']?.toString() ?? ''),
                          onDeleteComment: (commentId) => controller
                              .deleteDiscussionComment(widget.id, commentId),
                          onToggleVisibility: (val) =>
                              controller.toggleDiscussionVisibility(
                                  widget.id, d['id']?.toString() ?? '', val),
                        );
                      },
                    ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: 'add_discussion_fab',
                onPressed: () => _showAddDiscussionDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('New Discussion'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DiscussionCard extends StatefulWidget {
  const _DiscussionCard({
    required this.discussion,
    required this.projectId,
    required this.onDelete,
    required this.onAddComment,
    required this.onDeleteComment,
    required this.onToggleVisibility,
  });
  final Map<String, dynamic> discussion;
  final String projectId;
  final VoidCallback onDelete;
  final VoidCallback onAddComment;
  final void Function(String commentId) onDeleteComment;
  final void Function(bool visible) onToggleVisibility;

  @override
  State<_DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<_DiscussionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE9EEF8) : const Color(0xFF233247);
    final subtleColor =
        isDark ? const Color(0xFFBCC8DA) : const Color(0xFF4F6079);

    final d = widget.discussion;
    final subject = d['subject']?.toString() ?? 'Discussion';
    final description = d['description']?.toString() ?? '';
    final addedByName = d['staff_name']?.toString() ?? '';
    final dateCreated = d['datecreated']?.toString() ?? '';
    final comments = d['comments'];
    final commentList =
        comments is List ? comments.whereType<Map>().toList() : <Map>[];
    final showToCustomer = d['show_to_customer']?.toString() == '1';

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E2A3B) : Colors.white)
            .withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(Dimensions.space12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject,
                          style: semiBoldDefault.copyWith(
                              color: textColor, fontSize: 14)),
                      if (addedByName.isNotEmpty || dateCreated.isNotEmpty)
                        const SizedBox(height: 4),
                      Text(
                        [addedByName, dateCreated]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: regularSmall.copyWith(
                            color: subtleColor, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.65,
                            alignment: Alignment.centerLeft,
                            child: Switch(
                              value: showToCustomer,
                              onChanged: widget.onToggleVisibility,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          Text(
                            'Visible to client',
                            style: regularSmall.copyWith(
                                color: showToCustomer
                                    ? Theme.of(context).primaryColor
                                    : subtleColor,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red.shade400,
                ),
              ],
            ),
          ),
          if (description.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimensions.space12, 0, Dimensions.space12, Dimensions.space8),
              child: Text(description,
                  style: regularSmall.copyWith(color: subtleColor)),
            ),
          ],
          // Comments toggle
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space12, vertical: Dimensions.space8),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.comment_outlined,
                    size: 16,
                    color: subtleColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${commentList.length} comment${commentList.length == 1 ? '' : 's'}',
                    style:
                        regularSmall.copyWith(color: subtleColor, fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: widget.onAddComment,
                    icon: const Icon(Icons.add_comment_outlined, size: 14),
                    label: const Text('Add', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && commentList.isNotEmpty) ...[
            const Divider(height: 1),
            ...commentList.map((c) {
              final commentId = c['id']?.toString() ?? '';
              final staffName = c['staff_name']?.toString() ??
                  c['fullname']?.toString() ??
                  c['firstname']?.toString() ??
                  '';
              final content = c['content']?.toString() ?? '';
              // Model may return 'dateadded' (string) or 'created' (ms timestamp)
              String date = c['dateadded']?.toString() ?? '';
              if (date.isEmpty) {
                final raw = c['created'];
                if (raw is int) {
                  date = DateTime.fromMillisecondsSinceEpoch(raw)
                      .toLocal()
                      .toString()
                      .substring(0, 16);
                } else if (raw != null) {
                  date = raw.toString();
                }
              }
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  child: Text(
                    staffName.isNotEmpty ? staffName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                title: Text(content,
                    style: regularSmall.copyWith(color: textColor)),
                subtitle: Text('$staffName · $date',
                    style: regularSmall.copyWith(
                        color: subtleColor, fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: () => widget.onDeleteComment(commentId),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red.shade400,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

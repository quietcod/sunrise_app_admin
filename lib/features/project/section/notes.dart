import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectNotes extends StatefulWidget {
  const ProjectNotes({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectNotes> createState() => _ProjectNotesState();
}

class _ProjectNotesState extends State<ProjectNotes> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectNotes(widget.projectId);
    });
  }

  void _showAddNoteDialog(BuildContext context, ProjectController controller) {
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: contentCtrl,
          decoration: const InputDecoration(
              labelText: 'Note content', border: OutlineInputBorder()),
          maxLines: 5,
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
              controller.addProjectNote(widget.projectId, content);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        if (controller.isNotesLoading) return const CustomLoader();
        final notes = controller.projectNotesList;
        return Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              onRefresh: () async =>
                  controller.loadProjectNotes(widget.projectId),
              child: notes.isEmpty
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
                      itemCount: notes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          note: note,
                          onDelete: () => controller.deleteProjectNote(
                              widget.projectId, note['id']?.toString() ?? ''),
                        );
                      },
                    ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: 'add_project_note_fab',
                onPressed: () => _showAddNoteDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Note'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onDelete});
  final Map<String, dynamic> note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE9EEF8) : const Color(0xFF233247);
    final subtleColor =
        isDark ? const Color(0xFFBCC8DA) : const Color(0xFF4F6079);

    final content = note['content']?.toString() ?? '';
    final addedByName = note['added_by_name']?.toString() ?? '';
    final dateAdded = note['dateadded']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(content,
                    style: regularDefault.copyWith(color: textColor)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.red.shade400,
              ),
            ],
          ),
          if (addedByName.isNotEmpty || dateAdded.isNotEmpty) ...[
            const SizedBox(height: Dimensions.space8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: subtleColor),
                const SizedBox(width: 4),
                Text(
                  [addedByName, dateAdded]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style:
                      regularSmall.copyWith(color: subtleColor, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

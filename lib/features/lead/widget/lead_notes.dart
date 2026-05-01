import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadNotes extends StatefulWidget {
  const LeadNotes({super.key, required this.leadId});
  final String leadId;

  @override
  State<LeadNotes> createState() => _LeadNotesState();
}

class _LeadNotesState extends State<LeadNotes> {
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LeadController>().loadLeadNotes(widget.leadId);
    });
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<LeadController>(builder: (controller) {
      return Column(
        children: [
          // ── Add note input ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.space15, Dimensions.space15, Dimensions.space15, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addCtrl,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: regularSmall.copyWith(
                          color: ColorResources.blueGreyColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: (isDark
                                    ? const Color(0xFF2A3347)
                                    : const Color(0xFFD0DAE8))
                                .withValues(alpha: 0.7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: (isDark
                                    ? const Color(0xFF2A3347)
                                    : const Color(0xFFD0DAE8))
                                .withValues(alpha: 0.7)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    style: regularDefault,
                  ),
                ),
                const SizedBox(width: Dimensions.space8),
                ElevatedButton(
                  onPressed: () {
                    final text = _addCtrl.text.trim();
                    if (text.isNotEmpty) {
                      controller.addLeadNote(widget.leadId, text);
                      _addCtrl.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          // ── Notes list ────────────────────────────────────────────
          if (controller.isNotesLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (controller.leadNotes.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sticky_note_2_outlined,
                        size: 48,
                        color: ColorResources.blueGreyColor
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: Dimensions.space10),
                    Text('No notes yet',
                        style: regularDefault.copyWith(
                            color: ColorResources.blueGreyColor)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space5),
                itemCount: controller.leadNotes.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 0.5),
                itemBuilder: (ctx, index) {
                  final note = controller.leadNotes[index];
                  final noteId = note['id']?.toString() ?? '';
                  final noteText = note['note']?.toString() ?? '';
                  final dateAdded = note['date_added']?.toString() ??
                      note['date']?.toString() ??
                      '';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(noteText, style: regularDefault),
                    subtitle: dateAdded.isNotEmpty
                        ? Text(dateAdded,
                            style: regularSmall.copyWith(
                                color: ColorResources.blueGreyColor,
                                fontSize: 11))
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18,
                              color: Colors.blueAccent.withValues(alpha: 0.8)),
                          onPressed: () => _showEditDialog(
                              context, controller, noteId, noteText),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent.withValues(alpha: 0.8)),
                          onPressed: () =>
                              controller.deleteLeadNote(widget.leadId, noteId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  void _showEditDialog(BuildContext context, LeadController controller,
      String noteId, String currentText) {
    final editCtrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          maxLines: 4,
          minLines: 2,
          decoration: const InputDecoration(
              hintText: 'Note text', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateLeadNote(widget.leadId, noteId, editCtrl.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/extras/entity_extras_section.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/contract/controller/contract_controller.dart';
import 'package:flutex_admin/features/contract/repo/contract_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class ContractDetailsScreen extends StatefulWidget {
  const ContractDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ContractRepo(apiClient: Get.find()));
    final controller = Get.put(ContractController(contractRepo: Get.find()));
    controller.isLoading = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadContractDetails(widget.id);
      controller.loadRenewals(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContractController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;

      if (controller.isLoading ||
          controller.contractDetailsModel.data == null) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
          body: const CustomLoader(),
        );
      }

      final d = controller.contractDetailsModel.data!;
      final signed = d.signed ?? '0';
      final statusColor = ColorResources.contractStatusColor(signed);

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async => controller.loadContractDetails(widget.id),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF000000), Color(0xFF000000)]
                    : const [Color(0xFFEFF3F8), Color(0xFFDDE3EC)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  left: -60,
                  child: _BlurOrb(
                    size: 200,
                    color: (isDark
                            ? const Color(0xFF343434)
                            : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.25 : 0.62),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  right: -60,
                  child: _BlurOrb(
                    size: 160,
                    color: (isDark
                            ? const Color(0xFF23324A)
                            : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.2 : 0.5),
                  ),
                ),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.space15,
                    topPad,
                    Dimensions.space15,
                    Dimensions.space25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header bar ────────────────────────────────
                      _DetailHeader(
                        isDark: isDark,
                        title: LocalStrings.contractDetails.tr,
                        onBack: () => Get.back(),
                        onEdit: () => Get.toNamed(
                            RouteHelper.updateContractScreen,
                            arguments: widget.id),
                        onDelete: () {
                          const WarningAlertDialog().warningAlertDialog(
                            context,
                            () {
                              Get.back();
                              Get.find<ContractController>()
                                  .deleteContract(widget.id);
                              Navigator.pop(context);
                            },
                            title: LocalStrings.deleteContract.tr,
                            subTitle: LocalStrings.deleteContractWarningMSg.tr,
                            image: MyImages.exclamationImage,
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.space15),

                      // ── Hero card ─────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        accentColor: statusColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.description_outlined,
                                  color: statusColor, size: 26),
                            ),
                            const SizedBox(width: Dimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.subject ?? '',
                                    style: boldExtraLarge.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                  if ((d.company ?? '').isNotEmpty)
                                    Text(
                                      d.company!,
                                      style: regularDefault.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                  if ((d.typeName ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      d.typeName!,
                                      style: regularSmall.copyWith(
                                          color: ColorResources.blueGreyColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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
                                signed == '0'
                                    ? LocalStrings.notSigned.tr
                                    : LocalStrings.signed.tr,
                                style: regularSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Value + Dates ─────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoColumn(
                                    label: LocalStrings.contractValue.tr,
                                    value: d.contractValue ?? '-',
                                    icon: Icons.attach_money,
                                    isDark: isDark,
                                  ),
                                ),
                                _VerticalDivider(isDark: isDark),
                                Expanded(
                                  child: _InfoColumn(
                                    label: LocalStrings.contractType.tr,
                                    value: d.typeName ?? '-',
                                    icon: Icons.category_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space12),
                            Divider(
                              color: (isDark
                                      ? const Color(0xFF2A3347)
                                      : const Color(0xFFD0DAE8))
                                  .withValues(alpha: 0.7),
                              height: 1,
                            ),
                            const SizedBox(height: Dimensions.space12),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoColumn(
                                    label: LocalStrings.startDate.tr,
                                    value: d.dateStart ?? '-',
                                    icon: Icons.calendar_today_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                                _VerticalDivider(isDark: isDark),
                                Expanded(
                                  child: _InfoColumn(
                                    label: LocalStrings.endDate.tr,
                                    value: d.dateEnd ?? '-',
                                    icon: Icons.event_busy_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),

                      // ── Description ───────────────────────────────
                      if ((d.description ?? '').isNotEmpty)
                        _NoteCard(
                          isDark: isDark,
                          label: LocalStrings.description.tr,
                          content: d.description!,
                          icon: Icons.notes_outlined,
                        ),
                      if ((d.description ?? '').isNotEmpty)
                        const SizedBox(height: Dimensions.space12),

                      // ── Contract content (HTML) ───────────────────
                      if ((d.content ?? '').isNotEmpty) ...[
                        _SectionTitle(
                            title: 'Contract Content', isDark: isDark),
                        const SizedBox(height: Dimensions.space8),
                        _GlassCard(
                          isDark: isDark,
                          child: Html(
                            data: d.content ?? '',
                            style: {
                              'body': Style(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: FontSize(14),
                              ),
                            },
                          ),
                        ),
                      ],

                      // ── Mark Signed, Send Email, View PDF ─────────
                      const SizedBox(height: Dimensions.space12),
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Mark signed toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      d.signed == '1'
                                          ? Icons.verified_outlined
                                          : Icons.pending_outlined,
                                      size: 20,
                                      color: d.signed == '1'
                                          ? Colors.green
                                          : ColorResources.blueGreyColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      d.signed == '1' ? 'Signed' : 'Not Signed',
                                      style: semiBoldDefault.copyWith(
                                        color: d.signed == '1'
                                            ? Colors.green
                                            : ColorResources.blueGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: controller.isSubmitLoading
                                      ? null
                                      : () => controller.markSigned(
                                            widget.id,
                                            signed: d.signed != '1',
                                          ),
                                  child: Text(
                                    d.signed == '1'
                                        ? 'Remove Signature'
                                        : 'Mark as Signed',
                                    style: TextStyle(
                                      color: d.signed == '1'
                                          ? Colors.orange
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Clear Signature button – only when signed
                            if (d.signed == '1' ||
                                (d.signature ?? '').isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: controller.isSubmitLoading
                                      ? null
                                      : () => const WarningAlertDialog()
                                              .warningAlertDialog(
                                            context,
                                            () async {
                                              Navigator.pop(context);
                                              await controller
                                                  .clearSignature(widget.id);
                                            },
                                            image: MyImages.exclamationImage,
                                          ),
                                  icon: const Icon(Icons.delete_sweep_outlined,
                                      size: 16, color: Colors.red),
                                  label: const Text('Clear Signature',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 13)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.email_outlined,
                              label: 'Send Email',
                              color: const Color(0xFF2196F3),
                              isLoading: controller.isSubmitLoading,
                              onPressed: () =>
                                  controller.sendByEmail(widget.id),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'View PDF',
                              color: const Color(0xFFE53935),
                              onPressed: () => controller.openPdf(widget.id),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: _ActionOutlineButton(
                              icon: Icons.copy_outlined,
                              label: 'Copy',
                              color: const Color(0xFF4CAF50),
                              isLoading: controller.isSubmitLoading,
                              onPressed: () =>
                                  controller.copyContract(widget.id),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Dimensions.space15),
                      // ── Attachments ──────────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.attach_file,
                                  size: 16,
                                  color: ColorResources.blueGreyColor),
                              const SizedBox(width: Dimensions.space8),
                              Text('Attachments',
                                  style: semiBoldDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: controller.isSubmitLoading
                                    ? null
                                    : () => _showUploadAttachmentSheet(
                                        context, controller, widget.id),
                                icon:
                                    const Icon(Icons.upload_outlined, size: 15),
                                label: const Text('Upload',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ]),
                            const CustomDivider(),
                            if (controller.contractDetailsModel.data
                                    ?.attachments?.isEmpty ??
                                true)
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space10),
                                child: Text('No attachments',
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor)),
                              ))
                            else
                              ...controller
                                  .contractDetailsModel.data!.attachments!
                                  .map((a) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: Icon(
                                            _attachmentIcon(a.fileType ?? ''),
                                            size: 20,
                                            color:
                                                ColorResources.blueGreyColor),
                                        title: Text(a.fileName ?? '',
                                            style: regularDefault),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 18,
                                              color: ColorResources.redColor),
                                          onPressed: controller.isSubmitLoading
                                              ? null
                                              : () =>
                                                  controller.deleteAttachment(
                                                      widget.id, a.id ?? ''),
                                        ),
                                      )),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.space12),
                      // ── Notes ────────────────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.sticky_note_2_outlined,
                                  size: 16,
                                  color: ColorResources.blueGreyColor),
                              const SizedBox(width: Dimensions.space8),
                              Text('Notes',
                                  style: semiBoldDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: controller.isSubmitLoading
                                    ? null
                                    : () => _showAddNoteSheet(
                                        context, controller, widget.id),
                                icon: const Icon(Icons.add, size: 15),
                                label: const Text('Add',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ]),
                            const CustomDivider(),
                            if (controller.contractNotes.isEmpty)
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space10),
                                child: Text('No notes',
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor)),
                              ))
                            else
                              ...controller.contractNotes.map((n) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: const Icon(Icons.note_outlined,
                                        size: 18,
                                        color: ColorResources.blueGreyColor),
                                    title: Text(
                                        n['description']?.toString() ?? '',
                                        style: regularDefault),
                                    subtitle: Text(
                                        n['dateadded']?.toString() ?? '',
                                        style: regularSmall.copyWith(
                                            color:
                                                ColorResources.blueGreyColor)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18,
                                          color: ColorResources.redColor),
                                      onPressed: controller.isSubmitLoading
                                          ? null
                                          : () => controller.deleteNote(
                                              widget.id,
                                              n['id']?.toString() ?? ''),
                                    ),
                                  )),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.space12),
                      // ── Comments ─────────────────────────────────────────
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.comment_outlined,
                                  size: 16,
                                  color: ColorResources.blueGreyColor),
                              const SizedBox(width: Dimensions.space8),
                              Text('Comments',
                                  style: semiBoldDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: controller.isSubmitLoading
                                    ? null
                                    : () => _showAddCommentSheet(
                                        context, controller, widget.id),
                                icon: const Icon(Icons.add, size: 15),
                                label: const Text('Add',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ]),
                            const CustomDivider(),
                            if (controller.contractComments.isEmpty)
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space10),
                                child: Text('No comments',
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor)),
                              ))
                            else
                              ...controller.contractComments
                                  .map((c) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: const CircleAvatar(
                                            radius: 14,
                                            child: Icon(Icons.person_outline,
                                                size: 14)),
                                        title: Text(
                                            c['content']?.toString() ?? '',
                                            style: regularDefault),
                                        subtitle: Text(
                                            c['dateadded']?.toString() ?? '',
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor)),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 18,
                                              color: ColorResources.redColor),
                                          onPressed: controller.isSubmitLoading
                                              ? null
                                              : () => controller.deleteComment(
                                                  widget.id,
                                                  c['id']?.toString() ?? ''),
                                        ),
                                      )),
                          ],
                        ),
                      ),

                      // ── Renewals ─────────────────────────────────────────
                      const SizedBox(height: Dimensions.space15),
                      _GlassCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.autorenew_outlined,
                                  size: 16,
                                  color: ColorResources.blueGreyColor),
                              const SizedBox(width: Dimensions.space8),
                              Text('Renewals',
                                  style: semiBoldDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: controller.isSubmitLoading
                                    ? null
                                    : () => _showRenewSheet(
                                        context, controller, widget.id),
                                icon: const Icon(Icons.add, size: 15),
                                label: const Text('Renew',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ]),
                            const CustomDivider(),
                            if (controller.contractRenewals.isEmpty)
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space10),
                                child: Text('No renewals',
                                    style: regularSmall.copyWith(
                                        color: ColorResources.blueGreyColor)),
                              ))
                            else
                              ...controller.contractRenewals.map((r) =>
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: ColorResources.blueGreyColor),
                                    title: Text(
                                        '${r['date_start'] ?? ''} → ${r['date_end'] ?? ''}',
                                        style: regularDefault),
                                    subtitle: r['note'] != null &&
                                            (r['note']?.toString().isNotEmpty ??
                                                false)
                                        ? Text(r['note']?.toString() ?? '',
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .blueGreyColor))
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 18,
                                          color: ColorResources.redColor),
                                      onPressed: controller.isSubmitLoading
                                          ? null
                                          : () => controller.deleteRenewal(
                                              widget.id,
                                              r['id']?.toString() ?? ''),
                                    ),
                                  )),
                          ],
                        ),
                      ),

                      const SizedBox(height: Dimensions.space20),
                      EntityExtrasSection(
                        relType: 'contract',
                        relId: widget.id,
                        // attachments already shown above as a dedicated card
                        show: const {'reminders', 'activity', 'custom_fields'},
                      ),
                      const SizedBox(height: Dimensions.space25),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Helper methods ──────────────────────────────────────────────────────

  IconData _attachmentIcon(String ext) {
    final e = ext.replaceAll('.', '').toLowerCase();
    if (['pdf'].contains(e)) return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(e)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(e)) return Icons.table_chart_outlined;
    if (['png', 'jpg', 'jpeg', 'gif'].contains(e)) return Icons.image_outlined;
    if (['zip'].contains(e)) return Icons.folder_zip_outlined;
    return Icons.attach_file;
  }

  void _showUploadAttachmentSheet(
      BuildContext context, ContractController controller, String contractId) {
    bool visibleToCustomer = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Attachment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible to customer'),
                value: visibleToCustomer,
                onChanged: (v) =>
                    setSheetState(() => visibleToCustomer = v ?? false),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    controller.pickAndUploadAttachment(
                        contractId, visibleToCustomer);
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Pick & Upload File'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteSheet(
      BuildContext context, ContractController controller, String contractId) {
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Note',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter note...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = noteCtrl.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(context);
                  controller.addNote(contractId, text);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommentSheet(
      BuildContext context, ContractController controller, String contractId) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Comment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter comment...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(context);
                  controller.addComment(contractId, text);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenewSheet(
      BuildContext context, ContractController controller, String contractId) {
    final dateStartCtrl = TextEditingController();
    final dateEndCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Renew Contract',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: dateStartCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'New Start Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dateStartCtrl.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateEndCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'New End Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dateEndCtrl.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (dateStartCtrl.text.isEmpty || dateEndCtrl.text.isEmpty) {
                    return;
                  }
                  Navigator.pop(context);
                  controller.renewContract(
                      contractId, dateStartCtrl.text, dateEndCtrl.text);
                },
                child: const Text('Renew'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.isDark,
    required this.title,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDark;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              Expanded(
                child: Text(
                  title,
                  style: boldExtraLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit'),
              IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: ColorResources.redColor),
                  tooltip: 'Delete'),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.isDark,
    required this.child,
    this.accentColor,
  });

  final bool isDark;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          child: Container(
            decoration: accentColor != null
                ? BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 4, color: accentColor!)),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: semiBoldLarge.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color),
      );
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 13, color: ColorResources.blueGreyColor),
          const SizedBox(width: 4),
          Text(label,
              style:
                  regularSmall.copyWith(color: ColorResources.blueGreyColor)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: semiBoldDefault),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: VerticalDivider(
          width: 1,
          color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
              .withValues(alpha: 0.7),
        ),
      );
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.isDark,
    required this.label,
    required this.content,
    required this.icon,
  });

  final bool isDark;
  final String label;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: ColorResources.blueGreyColor),
            const SizedBox(width: 6),
            Text(label,
                style: semiBoldDefault.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
          ]),
          const SizedBox(height: Dimensions.space8),
          Divider(
            color: (isDark ? const Color(0xFF2A3347) : const Color(0xFFD0DAE8))
                .withValues(alpha: 0.7),
            height: 1,
          ),
          const SizedBox(height: Dimensions.space8),
          Text(content,
              style:
                  regularDefault.copyWith(color: ColorResources.blueGreyColor)),
        ],
      ),
    );
  }
}

class _ActionOutlineButton extends StatelessWidget {
  const _ActionOutlineButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isDark,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withValues(alpha: isDark ? 0.08 : 0.05),
      ),
    );
  }
}

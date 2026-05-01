import 'dart:ui';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/ticket/controller/ticket_controller.dart';
import 'package:flutex_admin/features/ticket/helper/assigned_staff_name_helper.dart';
import 'package:flutex_admin/features/ticket/repo/ticket_repo.dart';
import 'package:flutex_admin/features/ticket/widget/add_reply_widget.dart';
import 'package:flutex_admin/features/ticket/widget/otp_verification_screen.dart';
import 'package:flutex_admin/features/ticket/widget/status_change_selector.dart';
import 'package:flutex_admin/features/ticket/widget/ticket_reply.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  String _cleanValue(String? value, {String fallback = '-'}) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return fallback;
    }
    return normalized;
  }

  String _firstNonEmpty(List<String?> values, {String fallback = '-'}) {
    for (final value in values) {
      final normalized = value?.trim() ?? '';
      if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
        return normalized;
      }
    }
    return fallback;
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TicketRepo(apiClient: Get.find()));
    final controller = Get.put(TicketController(ticketRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadTicketDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      body: Container(
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
                color:
                    (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.25 : 0.62),
              ),
            ),
            Positioned(
              bottom: 160,
              right: -60,
              child: _BlurOrb(
                size: 160,
                color:
                    (isDark ? const Color(0xFF23324A) : const Color(0xFFD0E7FF))
                        .withValues(alpha: isDark ? 0.2 : 0.5),
              ),
            ),
            GetBuilder<TicketController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return const CustomLoader();
                }

                final ticket = controller.ticketDetailsModel.data;

                if (ticket == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.space20),
                      child: Text(
                        'Ticket not found or failed to load.',
                        style: regularDefault,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (controller.isOtpScreenShowing) {
                  return OtpVerificationScreen(
                    ticketId: widget.id,
                    ticketSubject:
                        '#${ticket.ticketId ?? ''} - ${ticket.subject ?? ''}',
                    clientName:
                        '${ticket.firstName ?? ''} ${ticket.lastName ?? ''}',
                    clientMobile: ticket.phoneNumber ?? '',
                  );
                }

                final contactName = _firstNonEmpty([
                  [ticket.firstName, ticket.lastName]
                      .where((value) => (value ?? '').trim().isNotEmpty)
                      .join(' '),
                  [ticket.userFirstName, ticket.userLastName]
                      .where((value) => (value ?? '').trim().isNotEmpty)
                      .join(' '),
                  ticket.fromName,
                  ticket.name,
                ]);
                final companyName = _cleanValue(ticket.company);
                final contactLine = companyName == '-'
                    ? contactName
                    : '$contactName ($companyName)';
                final assignedTo = buildAssignedStaffName(ticket.toJson());
                final submittedDate = _cleanValue(
                  ticket.date?.isNotEmpty == true
                      ? DateConverter.formatValidityDate(ticket.date ?? '')
                      : null,
                );
                final lastReplyDate = _cleanValue(
                  ticket.lastReply?.isNotEmpty == true
                      ? DateConverter.formatValidityDate(ticket.lastReply ?? '')
                      : null,
                );
                final detailRows = <MapEntry<String, String>>[
                  MapEntry(LocalStrings.contact.tr, contactLine),
                  MapEntry('Email',
                      _firstNonEmpty([ticket.email, ticket.ticketEmail])),
                  MapEntry('Phone', _cleanValue(ticket.phoneNumber)),
                  MapEntry(LocalStrings.department.tr,
                      _cleanValue(ticket.departmentName)),
                  MapEntry(
                      LocalStrings.service.tr, _cleanValue(ticket.serviceName)),
                  MapEntry(LocalStrings.priority.tr,
                      _cleanValue(ticket.priorityName)),
                  MapEntry('Status', _cleanValue(ticket.statusName)),
                  MapEntry(LocalStrings.submitted.tr, submittedDate),
                  MapEntry('Last Reply', lastReplyDate),
                  MapEntry('Assigned To', assignedTo),
                ];

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                          Dimensions.space15, Dimensions.space10),
                      child: _GlassDetailHeader(
                        isDark: isDark,
                        title: LocalStrings.ticketDetails.tr,
                        onEdit: () => Get.toNamed(
                            RouteHelper.updateTicketScreen,
                            arguments: widget.id),
                        onDelete: () => const WarningAlertDialog()
                            .warningAlertDialog(context, () {
                          Get.back();
                          Get.find<TicketController>().deleteTicket(widget.id);
                          Navigator.pop(context);
                        },
                                title: LocalStrings.deleteTicket.tr,
                                subTitle:
                                    LocalStrings.deleteTicketWarningMSg.tr,
                                image: MyImages.exclamationImage),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).cardColor,
                        onRefresh: () async =>
                            controller.loadTicketDetails(widget.id),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.space12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '#${ticket.ticketId ?? ''} - ${_cleanValue(ticket.subject)}',
                                        style: mediumLarge,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space8),
                                    Text(
                                      _cleanValue(ticket.statusName)
                                              .tr
                                              .capitalize ??
                                          '',
                                      style: mediumDefault.copyWith(
                                        color: ColorResources.ticketStatusColor(
                                          ticket.status ?? '',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space10),
                                _GlassPanel(
                                  isDark: isDark,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.space12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...detailRows
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final row = entry.value;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  index == detailRows.length - 1
                                                      ? 0
                                                      : Dimensions.space10,
                                            ),
                                            child: Column(
                                              children: [
                                                _DetailRow(
                                                  label: row.key,
                                                  value: row.value,
                                                ),
                                                if (index !=
                                                    detailRows.length - 1)
                                                  const CustomDivider(
                                                    space: Dimensions.space10,
                                                  ),
                                              ],
                                            ),
                                          );
                                        }),
                                        const CustomDivider(
                                            space: Dimensions.space10),
                                        Text(LocalStrings.description.tr,
                                            style: lightSmall),
                                        Text(
                                          _cleanValue(
                                            Converter.parseHtmlString(
                                                ticket.message ?? ''),
                                          ),
                                          style: regularDefault,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _GlassPanel(
                                  isDark: isDark,
                                  child: StatusChangeSelector(
                                    ticketId: widget.id,
                                    currentStatus: ticket.status ?? '1',
                                  ),
                                ),
                                if (controller.canAssignTicketToStaff) ...[
                                  const SizedBox(height: Dimensions.space15),
                                  _GlassPanel(
                                    isDark: isDark,
                                    child: _AssignStaffPanel(
                                        ticketId: widget.id,
                                        controller: controller),
                                  ),
                                ],
                                const SizedBox(height: Dimensions.space15),
                                _GlassPanel(
                                  isDark: isDark,
                                  child: AddReplyWidget(ticketId: widget.id),
                                ),
                                if (ticket.ticketReplies?.isNotEmpty ??
                                    false) ...[
                                  const SizedBox(height: Dimensions.space15),
                                  _GlassPanel(
                                    isDark: isDark,
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          Dimensions.space12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextIcon(
                                            text: LocalStrings.ticketReplies.tr,
                                            textStyle: semiBoldDefault,
                                            icon: Icons.comment_outlined,
                                          ),
                                          const SizedBox(
                                              height: Dimensions.space12),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return TicketReplies(
                                                reply: ticket
                                                    .ticketReplies![index],
                                                ticketId: widget.id,
                                              );
                                            },
                                            separatorBuilder: (context,
                                                    index) =>
                                                const SizedBox(
                                                    height: Dimensions.space10),
                                            itemCount:
                                                ticket.ticketReplies?.length ??
                                                    0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.48,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    required this.isDark,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF121926) : Colors.white)
                .withValues(alpha: isDark ? 0.58 : 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF2D3A4D) : const Color(0xFFD5DFEC))
                      .withValues(alpha: isDark ? 0.9 : 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: lightSmall,
          ),
        ),
        const SizedBox(width: Dimensions.space12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: regularDefault,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _GlassDetailHeader extends StatelessWidget {
  const _GlassDetailHeader(
      {required this.isDark,
      required this.title,
      required this.onEdit,
      required this.onDelete});
  final bool isDark;
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF343434) : const Color(0xFFFFFFFF))
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    (isDark ? const Color(0xFF414A5B) : const Color(0xFFFFFFFF))
                        .withValues(alpha: isDark ? 0.46 : 0.55)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(width: Dimensions.space10),
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
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignStaffPanel extends StatelessWidget {
  const _AssignStaffPanel({required this.ticketId, required this.controller});
  final String ticketId;
  final TicketController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_outlined, size: 18),
              const SizedBox(width: 6),
              Text('Assign Staff', style: semiBoldDefault),
              const Spacer(),
              if (controller.isAssignableStaffLoading)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          if (controller.assignableStaff.isEmpty &&
              !controller.isAssignableStaffLoading)
            Text('No staff available', style: lightSmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.assignableStaff.map((staff) {
                return ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: Text(
                    '${staff.firstName} ${staff.lastName}'.trim(),
                    style: regularSmall,
                  ),
                  onPressed: () => controller.assignTicketToStaff(
                      ticketId: ticketId, staffId: staff.staffId),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

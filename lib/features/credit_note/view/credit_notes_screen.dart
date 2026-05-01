import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/credit_note/controller/credit_note_controller.dart';
import 'package:flutex_admin/features/credit_note/repo/credit_note_repo.dart';
import 'package:flutex_admin/features/credit_note/widget/credit_note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class CreditNotesScreen extends StatefulWidget {
  const CreditNotesScreen({super.key});

  @override
  State<CreditNotesScreen> createState() => _CreditNotesScreenState();
}

class _CreditNotesScreenState extends State<CreditNotesScreen> {
  bool showFab = true;
  final scrollController = ScrollController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => CreditNoteRepo(apiClient: Get.find()));
    final controller =
        Get.put(CreditNoteController(creditNoteRepo: Get.find()));
    controller.isLoading = true;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.initialData());
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showFab) setState(() => showFab = false);
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showFab) setState(() => showFab = true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: AnimatedSlide(
        offset: showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 200),
        child: AnimatedOpacity(
          opacity: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(RouteHelper.addCreditNoteScreen),
            backgroundColor: ColorResources.secondaryColor,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(LocalStrings.addCreditNote.tr,
                style: semiBoldDefault.copyWith(color: Colors.white)),
          ),
        ),
      ),
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
              top: -70,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark
                          ? const Color(0xFF343434)
                          : const Color(0xFFFFFFFF))
                      .withValues(alpha: isDark ? 0.28 : 0.65),
                ),
              ),
            ),
            SafeArea(
              child: GetBuilder<CreditNoteController>(builder: (controller) {
                final filtered = controller.creditNoteList.where((n) {
                  if (searchQuery.isEmpty) return true;
                  final q = searchQuery.toLowerCase();
                  return (n.formattedNumber.toLowerCase().contains(q)) ||
                      (n.clientName?.toLowerCase().contains(q) ?? false);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              LocalStrings.creditNotes.tr,
                              style: boldLarge.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.space15, 8, Dimensions.space15, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: TextField(
                            onChanged: (v) => setState(() => searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search credit notes...',
                              hintStyle: regularDefault.copyWith(
                                  color: ColorResources.contentTextColor),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: ColorResources.contentTextColor),
                              filled: true,
                              fillColor: (isDark
                                      ? const Color(0xFF343434)
                                      : Colors.white)
                                  .withValues(alpha: .55),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: controller.isLoading
                          ? const CustomLoader()
                          : filtered.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.credit_card_off_outlined,
                                          size: 60,
                                          color: ColorResources.contentTextColor
                                              .withValues(alpha: .4)),
                                      const SizedBox(height: 12),
                                      Text(LocalStrings.dataNotFound.tr,
                                          style: regularDefault.copyWith(
                                              color: ColorResources
                                                  .contentTextColor)),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  color: Theme.of(context).primaryColor,
                                  backgroundColor: Theme.of(context).cardColor,
                                  onRefresh: () =>
                                      controller.initialData(shouldLoad: false),
                                  child: ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                      Dimensions.space15,
                                      4,
                                      Dimensions.space15,
                                      80,
                                    ),
                                    itemCount: filtered.length,
                                    itemBuilder: (_, i) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: CreditNoteCard(
                                          note: filtered[i], isDark: isDark),
                                    ),
                                  ),
                                ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/expense/controller/expense_controller.dart';
import 'package:flutex_admin/features/expense/model/expense_category_model.dart';
import 'package:flutex_admin/features/expense/repo/expense_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ExpenseRepo(apiClient: Get.find()));
    final controller = Get.put(ExpenseController(expenseRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCategories();
    });
  }

  void _showAddEditDialog(
      {ExpenseCategory? category, required ExpenseController controller}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Dimensions.space12),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isEdit) {
                controller.updateCategory(
                    category.id!, nameCtrl.text.trim(), descCtrl.text.trim());
              } else {
                controller.addCategory(
                    nameCtrl.text.trim(), descCtrl.text.trim());
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String categoryId, ExpenseController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteCategory(categoryId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = Get.find<ExpenseController>();
          _showAddEditDialog(controller: controller);
        },
        child: const Icon(Icons.add),
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
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                      Dimensions.space15, Dimensions.space10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? const Color(0xFF343434)
                                  : const Color(0xFFFFFFFF))
                              .withValues(alpha: isDark ? 0.42 : 0.34),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: (isDark
                                      ? const Color(0xFF414A5B)
                                      : const Color(0xFFFFFFFF))
                                  .withValues(alpha: isDark ? 0.46 : 0.55)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon:
                                  const Icon(Icons.arrow_back_ios_new_rounded),
                            ),
                            const SizedBox(width: Dimensions.space10),
                            Expanded(
                              child: Text(
                                'Expense Categories',
                                style: boldExtraLarge.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GetBuilder<ExpenseController>(builder: (controller) {
                    if (controller.isLoading) return const CustomLoader();
                    final cats = controller.categoriesModel.data ?? [];
                    if (cats.isEmpty) {
                      return const Center(child: NoDataWidget());
                    }
                    return RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async => controller.loadCategories(),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.space15),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: cats.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Dimensions.space10),
                        itemBuilder: (context, index) {
                          final cat = cats[index];
                          return Container(
                            padding: const EdgeInsets.all(Dimensions.space12),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFF1E2A3B)
                                      : Colors.white)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark
                                        ? const Color(0xFF2A3347)
                                        : const Color(0xFFD0DAE8))
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.category_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name ?? '',
                                        style: regularDefault.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                      ),
                                      if ((cat.description ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(cat.description!,
                                            style: regularSmall.copyWith(
                                                color: ColorResources
                                                    .contentTextColor,
                                                fontSize: 11)),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _showAddEditDialog(
                                      category: cat, controller: controller),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 18,
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.85)),
                                  onPressed: () =>
                                      _confirmDelete(cat.id!, controller),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

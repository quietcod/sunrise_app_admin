import 'dart:ui';

import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/todo/controller/todo_controller.dart';
import 'package:flutex_admin/features/todo/model/todo_model.dart';
import 'package:flutex_admin/features/todo/repo/todo_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.lazyPut(() => TodoRepo(apiClient: Get.find()));
    Get.put(TodoController(todoRepo: Get.find()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addController.dispose();
    super.dispose();
  }

  void _showAddDialog(TodoController controller) {
    _addController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(LocalStrings.addTodo.tr, style: semiBoldLarge),
        content: TextField(
          controller: _addController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: LocalStrings.enterTodoDescription.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalStrings.cancel.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorResources.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (_addController.text.trim().isNotEmpty) {
                Get.back();
                controller.addTodo(_addController.text.trim());
              }
            },
            child: Text(LocalStrings.addTodo.tr,
                style: semiBoldDefault.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(TodoController controller, TodoItem item) {
    _addController.text = item.description ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(LocalStrings.editTodo.tr, style: semiBoldLarge),
        content: TextField(
          controller: _addController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: LocalStrings.enterTodoDescription.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalStrings.cancel.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorResources.secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (_addController.text.trim().isNotEmpty) {
                Get.back();
                controller.updateDescription(
                    item.id!, _addController.text.trim());
              }
            },
            child: Text(LocalStrings.update.tr,
                style: semiBoldDefault.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFDCE3EE),
      floatingActionButton: GetBuilder<TodoController>(builder: (controller) {
        return FloatingActionButton.extended(
          onPressed: () => _showAddDialog(controller),
          backgroundColor: ColorResources.secondaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(LocalStrings.addTodo.tr,
              style: semiBoldDefault.copyWith(color: Colors.white)),
        );
      }),
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
            SafeArea(
              child: GetBuilder<TodoController>(builder: (controller) {
                return Column(
                  children: [
                    // Glass Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      child: _GlassHeader(
                        isDark: isDark,
                        title: LocalStrings.todos.tr,
                        trailing: controller.pendingTodos.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ColorResources.secondaryColor
                                      .withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${controller.pendingTodos.length} pending',
                                  style: semiBoldSmall.copyWith(
                                      color: ColorResources.secondaryColor,
                                      fontSize: 11),
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Tab bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? const Color(0xFF343434)
                                      : Colors.white)
                                  .withValues(alpha: .45),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark
                                        ? const Color(0xFF4A5C79)
                                        : Colors.white)
                                    .withValues(alpha: .55),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: ColorResources.secondaryColor
                                    .withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle:
                                  semiBoldDefault.copyWith(fontSize: 13),
                              unselectedLabelStyle:
                                  regularDefault.copyWith(fontSize: 13),
                              labelColor: ColorResources.secondaryColor,
                              unselectedLabelColor:
                                  ColorResources.contentTextColor,
                              tabs: [
                                Tab(
                                    text:
                                        '${LocalStrings.pendingTasks.tr} (${controller.pendingTodos.length})'),
                                Tab(
                                    text:
                                        '${LocalStrings.finishedTasks.tr} (${controller.doneTodos.length})'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: controller.isLoading
                          ? const CustomLoader()
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTodoList(
                                    controller, controller.pendingTodos, isDark,
                                    reorderable: true),
                                _buildTodoList(
                                    controller, controller.doneTodos, isDark),
                              ],
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

  Widget _buildTodoList(
      TodoController controller, List<TodoItem> items, bool isDark,
      {bool reorderable = false}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 60,
                color: ColorResources.contentTextColor.withValues(alpha: .4)),
            const SizedBox(height: 12),
            Text(LocalStrings.dataNotFound.tr,
                style: regularDefault.copyWith(
                    color: ColorResources.contentTextColor)),
          ],
        ),
      );
    }

    if (reorderable) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
        itemCount: items.length,
        onReorder: controller.reorderTodo,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 4,
            child: child,
          );
        },
        itemBuilder: (_, i) => _TodoCard(
          key: ValueKey(items[i].id),
          item: items[i],
          isDark: isDark,
          onToggle: () => controller.toggleDone(items[i].id!, items[i].isDone),
          onEdit: () => _showEditDialog(controller, items[i]),
          onDelete: () {
            const WarningAlertDialog().warningAlertDialog(
              context,
              () {
                Get.back();
                controller.deleteTodo(items[i].id!);
              },
              title: LocalStrings.deleteTodo.tr,
              subTitle: LocalStrings.deleteTodoWarningMsg.tr,
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () => controller.initialData(shouldLoad: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
        itemCount: items.length,
        itemBuilder: (_, i) => _TodoCard(
          item: items[i],
          isDark: isDark,
          onToggle: () => controller.toggleDone(items[i].id!, items[i].isDone),
          onEdit: () => _showEditDialog(controller, items[i]),
          onDelete: () {
            const WarningAlertDialog().warningAlertDialog(
              context,
              () {
                Get.back();
                controller.deleteTodo(items[i].id!);
              },
              title: LocalStrings.deleteTodo.tr,
              subTitle: LocalStrings.deleteTodoWarningMsg.tr,
            );
          },
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoItem item;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color =
        item.isDone ? ColorResources.colorGrey : ColorResources.secondaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF343434) : Colors.white)
                  .withValues(alpha: .45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: .3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: item.isDone
                          ? color.withValues(alpha: .15)
                          : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: item.isDone
                        ? Icon(Icons.check_rounded, size: 14, color: color)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.description ?? '',
                    style: regularDefault.copyWith(
                      color: item.isDone
                          ? ColorResources.contentTextColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: ColorResources.contentTextColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: ColorResources.contentTextColor,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: Colors.red.withValues(alpha: .75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader(
      {required this.isDark, required this.title, this.trailing});
  final bool isDark;
  final String title;
  final Widget? trailing;

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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: boldLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 22),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
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

import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/todo/model/todo_model.dart';
import 'package:flutex_admin/features/todo/repo/todo_repo.dart';
import 'package:get/get.dart';

class TodoController extends GetxController {
  TodoRepo todoRepo;
  TodoController({required this.todoRepo});

  bool isLoading = true;
  bool isSubmitting = false;
  List<TodoItem> todoList = [];

  @override
  void onInit() {
    super.onInit();
    initialData();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    if (shouldLoad) {
      isLoading = true;
      update();
    }
    await _loadTodos();
    isLoading = false;
    update();
  }

  Future<void> _loadTodos() async {
    final response = await todoRepo.getAllTodos();
    if (response.status) {
      final model = TodosModel.fromJson(jsonDecode(response.responseJson));
      todoList = model.data ?? [];
    }
  }

  Future<void> addTodo(String description) async {
    if (description.trim().isEmpty) return;
    isSubmitting = true;
    update();
    final response = await todoRepo.addTodo(description.trim());
    isSubmitting = false;
    if (response.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.todoAddedSuccessfully.tr]);
      await _loadTodos();
    } else {
      CustomSnackBar.error(errorList: [LocalStrings.somethingWentWrong.tr]);
    }
    update();
  }

  Future<void> toggleDone(String id, bool currentlyDone) async {
    await todoRepo.toggleTodoDone(id, !currentlyDone);
    final idx = todoList.indexWhere((t) => t.id == id);
    if (idx != -1) {
      todoList[idx] = TodoItem.fromJson({
        'todoid': todoList[idx].id,
        'description': todoList[idx].description,
        'finished': currentlyDone ? '0' : '1',
        'dateadded': todoList[idx].dateadded,
        'datefinished': todoList[idx].datefinished,
        'item_order': todoList[idx].itemOrder,
      });
    }
    update();
  }

  Future<void> updateDescription(String id, String description) async {
    isSubmitting = true;
    update();
    await todoRepo.updateTodoDescription(id, description);
    isSubmitting = false;
    CustomSnackBar.success(
        successList: [LocalStrings.todoUpdatedSuccessfully.tr]);
    await _loadTodos();
    update();
  }

  Future<void> deleteTodo(String id) async {
    await todoRepo.deleteTodo(id);
    todoList.removeWhere((t) => t.id == id);
    CustomSnackBar.success(
        successList: [LocalStrings.todoDeletedSuccessfully.tr]);
    update();
  }

  List<TodoItem> get pendingTodos => todoList.where((t) => !t.isDone).toList();
  List<TodoItem> get doneTodos => todoList.where((t) => t.isDone).toList();

  Future<void> reorderTodo(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final pending = pendingTodos;
    final item = pending.removeAt(oldIndex);
    pending.insert(newIndex, item);
    // Update local list immediately for responsiveness
    todoList = [...pending, ...doneTodos];
    update();
    // Persist order on server
    await todoRepo.reorderTodo(item.id!, newIndex);
  }
}

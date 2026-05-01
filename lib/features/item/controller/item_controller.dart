import 'dart:async';
import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/item/model/item_details_model.dart';
import 'package:flutex_admin/features/item/model/item_model.dart';
import 'package:flutex_admin/features/item/repo/item_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemController extends GetxController {
  ItemRepo itemRepo;
  ItemController({required this.itemRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  ItemsModel itemsModel = ItemsModel();
  ItemDetailsModel itemDetailsModel = ItemDetailsModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadItems();
    isLoading = false;
    update();
  }

  Future<void> loadItems() async {
    ResponseModel responseModel = await itemRepo.getAllItems();
    if (responseModel.status) {
      itemsModel = ItemsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      isLoading = false;
      update();
      Get.back();
      CustomSnackBar.error(errorList: [LocalStrings.noPermission.tr]);
      return;
    } else {
      itemsModel = ItemsModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadItemDetails(itemId) async {
    ResponseModel responseModel = await itemRepo.getItemDetails(itemId);
    if (responseModel.status) {
      itemDetailsModel =
          ItemDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  // Search Items
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchItem() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await itemRepo.searchItem(keysearch);
    if (responseModel.status) {
      itemsModel = ItemsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  bool isSearch = false;
  void changeSearchIcon() {
    isSearch = !isSearch;
    update();

    if (!isSearch) {
      searchController.clear();
      initialData();
    }
  }

  // Add Item
  TextEditingController nameController = TextEditingController();
  TextEditingController longDescController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  Future<void> submitItem() async {
    if (nameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterItemName.tr]);
      return;
    }
    if (rateController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterRate.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    final data = <String, dynamic>{
      'description': nameController.text.trim(),
      'long_description': longDescController.text.trim(),
      'rate': rateController.text.trim(),
      'unit': unitController.text.trim(),
    };

    ResponseModel responseModel = await itemRepo.createItem(data);

    if (responseModel.status) {
      nameController.clear();
      longDescController.clear();
      rateController.clear();
      unitController.clear();
      Get.back();
      await initialData(shouldLoad: false);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Edit Item
  TextEditingController editNameController = TextEditingController();
  TextEditingController editLongDescController = TextEditingController();
  TextEditingController editRateController = TextEditingController();
  TextEditingController editUnitController = TextEditingController();

  void populateForEdit() {
    final d = itemDetailsModel.data;
    if (d == null) return;
    editNameController.text = d.description ?? '';
    editLongDescController.text = d.longDescription ?? '';
    editRateController.text = d.rate?.toString() ?? '';
    editUnitController.text = d.unit ?? '';
  }

  Future<void> updateItem(itemId) async {
    if (editNameController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterItemName.tr]);
      return;
    }
    if (editRateController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterRate.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    final data = <String, dynamic>{
      'description': editNameController.text.trim(),
      'long_description': editLongDescController.text.trim(),
      'rate': editRateController.text.trim(),
      'unit': editUnitController.text.trim(),
    };

    ResponseModel responseModel = await itemRepo.updateItem(itemId, data);

    if (responseModel.status) {
      Get.back();
      await loadItemDetails(itemId);
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Item (from details screen — navigates back)
  Future<void> deleteItem(itemId) async {
    isSubmitLoading = true;
    update();

    ResponseModel responseModel = await itemRepo.deleteItem(itemId);

    if (responseModel.status) {
      Get.back(); // close dialog
      Get.back(); // leave details screen
      CustomSnackBar.success(successList: [responseModel.message.tr]);
      await loadItems(); // refresh list in background
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Item inline (from list — no navigation)
  Future<void> deleteItemInList(String itemId) async {
    isSubmitLoading = true;
    update();

    ResponseModel responseModel = await itemRepo.deleteItem(itemId);

    if (responseModel.status) {
      CustomSnackBar.success(successList: [responseModel.message.tr]);
      await loadItems();
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Selection mode
  bool isSelectionMode = false;
  Set<String> selectedIds = {};

  void enterSelectionMode([String? initialId]) {
    isSelectionMode = true;
    selectedIds = initialId != null ? {initialId} : {};
    update();
  }

  void exitSelectionMode() {
    isSelectionMode = false;
    selectedIds = {};
    update();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    update();
  }

  void selectAll() {
    selectedIds = (itemsModel.data ?? []).map((e) => e.itemId!).toSet();
    update();
  }

  void deselectAll() {
    selectedIds = {};
    update();
  }

  Future<void> deleteSelectedItems() async {
    isSubmitLoading = true;
    update();

    final ids = List<String>.from(selectedIds);
    int failed = 0;
    for (final id in ids) {
      final r = await itemRepo.deleteItem(id);
      if (!r.status) failed++;
    }

    exitSelectionMode();
    await loadItems();

    if (failed == 0) {
      CustomSnackBar.success(successList: [
        '${ids.length} item${ids.length == 1 ? '' : 's'} deleted successfully'
      ]);
    } else {
      CustomSnackBar.error(errorList: [
        '$failed item${failed == 1 ? '' : 's'} failed to delete'
      ]);
    }

    isSubmitLoading = false;
    update();
  }
}

import 'dart:convert';

import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/newsfeed/model/newsfeed_model.dart';
import 'package:flutex_admin/features/newsfeed/repo/newsfeed_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsfeedController extends GetxController {
  NewsfeedRepo newsfeedRepo;
  NewsfeedController({required this.newsfeedRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  NewsfeedPostsModel postsModel = NewsfeedPostsModel();
  NewsfeedCommentsModel commentsModel = NewsfeedCommentsModel();

  final postController = TextEditingController();
  final commentController = TextEditingController();

  Future<void> loadPosts() async {
    isLoading = true;
    update();
    final res = await newsfeedRepo.getPosts();
    postsModel = res.status
        ? NewsfeedPostsModel.fromJson(jsonDecode(res.responseJson))
        : NewsfeedPostsModel();
    isLoading = false;
    update();
  }

  Future<void> createPost() async {
    if (postController.text.trim().isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.fillAllFields.tr]);
      return;
    }
    isSubmitLoading = true;
    update();
    final res =
        await newsfeedRepo.createPost({'message': postController.text.trim()});
    isSubmitLoading = false;
    update();
    if (res.status) {
      postController.clear();
      Get.back();
      CustomSnackBar.success(successList: [LocalStrings.addedSuccessfully.tr]);
      await loadPosts();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deletePost(String id) async {
    final res = await newsfeedRepo.deletePost(id);
    if (res.status) {
      CustomSnackBar.success(
          successList: [LocalStrings.deletedSuccessfully.tr]);
      await loadPosts();
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> toggleLike(String postId) async {
    final res = await newsfeedRepo.toggleLike(postId);
    if (res.status) {
      await loadPosts();
    }
  }

  Future<void> loadComments(String postId) async {
    final res = await newsfeedRepo.getComments(postId);
    commentsModel = res.status
        ? NewsfeedCommentsModel.fromJson(jsonDecode(res.responseJson))
        : NewsfeedCommentsModel();
    update();
  }

  Future<void> addComment(String postId) async {
    if (commentController.text.trim().isEmpty) return;
    final res =
        await newsfeedRepo.addComment(postId, commentController.text.trim());
    if (res.status) {
      commentController.clear();
      await loadComments(postId);
    } else {
      CustomSnackBar.error(errorList: [res.message.tr]);
    }
  }

  Future<void> deleteComment(String id, String postId) async {
    final res = await newsfeedRepo.deleteComment(id);
    if (res.status) {
      await loadComments(postId);
    }
  }

  @override
  void onClose() {
    postController.dispose();
    commentController.dispose();
    super.onClose();
  }
}

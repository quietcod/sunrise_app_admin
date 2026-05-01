import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/my_permissions.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/util.dart';
import 'package:flutex_admin/features/newsfeed/controller/newsfeed_controller.dart';
import 'package:flutex_admin/features/newsfeed/model/newsfeed_model.dart';
import 'package:flutex_admin/features/newsfeed/repo/newsfeed_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(NewsfeedRepo(apiClient: Get.find()));
    final c = Get.put(NewsfeedController(newsfeedRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsfeedController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.newsfeed.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canCreateNewsfeed)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showCreatePostDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.postsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : RefreshIndicator(
                    onRefresh: controller.loadPosts,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      itemCount: controller.postsModel.data!.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Dimensions.space10),
                      itemBuilder: (context, i) {
                        final post = controller.postsModel.data![i];
                        return _PostCard(
                          post: post,
                          onLike: () => controller.toggleLike(post.id!),
                          onComments: () =>
                              _showCommentsSheet(context, controller, post),
                          onDelete: MyPermissions.canDeleteNewsfeed
                              ? () =>
                                  _confirmDelete(context, controller, post.id!)
                              : null,
                        );
                      },
                    ),
                  ),
      );
    });
  }

  void _showCreatePostDialog(
      BuildContext context, NewsfeedController controller) {
    controller.postController.clear();
    showDialog(
      context: context,
      builder: (_) => GetBuilder<NewsfeedController>(builder: (c) {
        return AlertDialog(
          title: Text(LocalStrings.createPost.tr),
          content: TextField(
            controller: c.postController,
            maxLines: 4,
            decoration:
                InputDecoration(hintText: LocalStrings.whatsOnYourMind.tr),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child: Text(LocalStrings.cancel.tr)),
            c.isSubmitLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: c.createPost,
                    child: Text(LocalStrings.post.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))),
          ],
        );
      }),
    );
  }

  void _showCommentsSheet(
      BuildContext context, NewsfeedController controller, NewsfeedPost post) {
    controller.loadComments(post.id!);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) =>
            GetBuilder<NewsfeedController>(builder: (c) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.space15),
                child: Text(LocalStrings.comments.tr,
                    style:
                        regularDefault.copyWith(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: (c.commentsModel.data?.isEmpty ?? true)
                    ? Center(child: Text(LocalStrings.noData.tr))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: c.commentsModel.data!.length,
                        itemBuilder: (context, i) {
                          final comment = c.commentsModel.data![i];
                          return ListTile(
                            title: Text(comment.content ?? '',
                                style: regularSmall),
                            subtitle: Text(comment.staffName ?? '',
                                style: regularSmall.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color)),
                            trailing: MyPermissions.canDeleteNewsfeed
                                ? IconButton(
                                    icon: Icon(Icons.delete_rounded,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    onPressed: () =>
                                        c.deleteComment(comment.id!, post.id!),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
              // Add comment
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: c.commentController,
                        decoration: InputDecoration(
                            hintText: LocalStrings.addComment.tr),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded,
                          color: Theme.of(context).primaryColor),
                      onPressed: () => c.addComment(post.id!),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, NewsfeedController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deletePost(id);
      },
      title: LocalStrings.deletePost.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard(
      {required this.post,
      required this.onLike,
      required this.onComments,
      this.onDelete});
  final NewsfeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          boxShadow: MyUtils.getCardShadow(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                    (post.staffName ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.staffName ?? '',
                        style: regularSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color)),
                    Text(post.dateAdded ?? '',
                        style: regularSmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            fontSize: 10)),
                  ],
                ),
              ),
              if (post.isPinned)
                Icon(Icons.push_pin_rounded,
                    size: 14, color: Theme.of(context).primaryColor),
              if (onDelete != null)
                IconButton(
                    icon: Icon(Icons.delete_rounded,
                        size: 16, color: Theme.of(context).colorScheme.error),
                    onPressed: onDelete),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.message ?? '',
              style: regularDefault.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color)),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                        post.likedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: post.likedByMe
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.red.shade300
                                : Colors.red.shade600)
                            : Theme.of(context).textTheme.bodySmall!.color),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}',
                        style: regularSmall.copyWith(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onComments,
                child: Row(
                  children: [
                    Icon(Icons.comment_rounded,
                        size: 18,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                    const SizedBox(width: 4),
                    Text('${post.commentsCount}',
                        style: regularSmall.copyWith(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

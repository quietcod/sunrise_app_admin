import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/helper/my_permissions.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/util.dart';
import 'package:flutex_admin/features/knowledge_base/controller/kb_controller.dart';
import 'package:flutex_admin/features/knowledge_base/model/kb_model.dart';
import 'package:flutex_admin/features/knowledge_base/repo/kb_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KbGroupsScreen extends StatefulWidget {
  const KbGroupsScreen({super.key});

  @override
  State<KbGroupsScreen> createState() => _KbGroupsScreenState();
}

class _KbGroupsScreenState extends State<KbGroupsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KbRepo(apiClient: Get.find()));
    final c = Get.put(KbController(kbRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KbController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.knowledgeBase.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canCreateKb)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showGroupDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.groupsModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.groupsModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final group = controller.groupsModel.data![i];
                      return _GroupCard(
                        group: group,
                        onTap: () => Get.toNamed(RouteHelper.kbArticlesScreen,
                            arguments: {
                              'groupId': group.id,
                              'groupName': group.name
                            }),
                        onEdit: () =>
                            _showGroupDialog(context, controller, group: group),
                        onDelete: () =>
                            _confirmDeleteGroup(context, controller, group.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showGroupDialog(BuildContext context, KbController controller,
      {KbGroup? group}) {
    if (group != null) {
      controller.nameController.text = group.name ?? '';
    } else {
      controller.clearForm();
    }
    showDialog(
      context: context,
      builder: (_) => GetBuilder<KbController>(builder: (c) {
        return AlertDialog(
          title: Text(group == null
              ? LocalStrings.addGroup.tr
              : LocalStrings.editGroup.tr),
          content: TextField(
            controller: c.nameController,
            decoration: InputDecoration(labelText: LocalStrings.name.tr),
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
                    onPressed: () =>
                        group == null ? c.addGroup() : c.updateGroup(group.id!),
                    child: Text(LocalStrings.submit.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))),
          ],
        );
      }),
    );
  }

  void _confirmDeleteGroup(
      BuildContext context, KbController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteGroup(id);
      },
      title: LocalStrings.deleteGroup.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard(
      {required this.group,
      required this.onTap,
      required this.onEdit,
      required this.onDelete});
  final KbGroup group;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space15, vertical: Dimensions.space10),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            boxShadow: MyUtils.getCardShadow(context)),
        child: Row(
          children: [
            Icon(Icons.folder_rounded,
                color: Theme.of(context).primaryColor, size: 22),
            const SizedBox(width: Dimensions.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name ?? '',
                      style: regularDefault.copyWith(
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color)),
                  Text('${group.articleCount ?? 0} ${LocalStrings.articles.tr}',
                      style: regularSmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color)),
                ],
              ),
            ),
            if (MyPermissions.canEditKb)
              IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  onPressed: onEdit),
            if (MyPermissions.canDeleteKb)
              IconButton(
                  icon: Icon(Icons.delete_rounded,
                      size: 18, color: Theme.of(context).colorScheme.error),
                  onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Articles screen
// ─────────────────────────────────────────────────────────────────────────────

class KbArticlesScreen extends StatefulWidget {
  const KbArticlesScreen({super.key});

  @override
  State<KbArticlesScreen> createState() => _KbArticlesScreenState();
}

class _KbArticlesScreenState extends State<KbArticlesScreen> {
  String? groupId;
  String? groupName;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KbRepo(apiClient: Get.find()));
    final c = Get.put(KbController(kbRepo: Get.find()));
    final args = Get.arguments as Map?;
    groupId = args?['groupId']?.toString();
    groupName = args?['groupName']?.toString();
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => c.loadArticles(groupId: groupId));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KbController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: groupName ?? LocalStrings.articles.tr,
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
          action: [
            if (MyPermissions.canCreateKb)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                color: Colors.white,
                onPressed: () => _showArticleDialog(context, controller),
              ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : (controller.articlesModel.data?.isEmpty ?? true)
                ? const NoDataWidget()
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.space15),
                    itemCount: controller.articlesModel.data!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Dimensions.space10),
                    itemBuilder: (context, i) {
                      final article = controller.articlesModel.data![i];
                      return _ArticleCard(
                        article: article,
                        onEdit: () => _showArticleDialog(context, controller,
                            article: article),
                        onDelete: () => _confirmDeleteArticle(
                            context, controller, article.id!),
                      );
                    },
                  ),
      );
    });
  }

  void _showArticleDialog(BuildContext context, KbController controller,
      {KbArticle? article}) {
    if (article != null) {
      controller.subjectController.text = article.subject ?? '';
      controller.descController.text = article.description ?? '';
      controller.selectedGroupId = article.groupId;
    } else {
      controller.clearForm();
      controller.selectedGroupId = groupId;
    }
    showDialog(
      context: context,
      builder: (_) => GetBuilder<KbController>(builder: (c) {
        return AlertDialog(
          title: Text(article == null
              ? LocalStrings.addArticle.tr
              : LocalStrings.editArticle.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: c.subjectController,
                  decoration:
                      InputDecoration(labelText: LocalStrings.subject.tr),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.descController,
                  maxLines: 4,
                  decoration:
                      InputDecoration(labelText: LocalStrings.description.tr),
                ),
              ],
            ),
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
                    onPressed: () => article == null
                        ? c.addArticle()
                        : c.updateArticle(article.id!),
                    child: Text(LocalStrings.submit.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))),
          ],
        );
      }),
    );
  }

  void _confirmDeleteArticle(
      BuildContext context, KbController controller, String id) {
    const WarningAlertDialog().warningAlertDialog(
      context,
      () {
        Get.back();
        controller.deleteArticle(id);
      },
      title: LocalStrings.deleteArticle.tr,
      subTitle: LocalStrings.areYouSureToDelete.tr,
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard(
      {required this.article, required this.onEdit, required this.onDelete});
  final KbArticle article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15, vertical: Dimensions.space10),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          boxShadow: MyUtils.getCardShadow(context)),
      child: Row(
        children: [
          Icon(
              article.isActive ? Icons.article_rounded : Icons.article_outlined,
              color: Theme.of(context).primaryColor,
              size: 22),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            child: Text(article.subject ?? '',
                style: regularDefault.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium!.color)),
          ),
          if (MyPermissions.canEditKb)
            IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit),
          if (MyPermissions.canDeleteKb)
            IconButton(
                icon: Icon(Icons.delete_rounded,
                    size: 18, color: Theme.of(context).colorScheme.error),
                onPressed: onDelete),
        ],
      ),
    );
  }
}

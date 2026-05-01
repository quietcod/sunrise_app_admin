import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/no_data.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/project/controller/project_controller.dart';
import 'package:flutex_admin/features/project/model/project_expenses_model.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectExpenses extends StatefulWidget {
  const ProjectExpenses({super.key, required this.id});
  final String id;

  @override
  State<ProjectExpenses> createState() => _ProjectExpensesState();
}

class _ProjectExpensesState extends State<ProjectExpenses> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProjectRepo(apiClient: Get.find()));
    final controller = Get.put(ProjectController(projectRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectGroup(widget.id, 'expenses');
    });
  }

  void _openAdd() {
    Get.toNamed(
      RouteHelper.addExpenseScreen,
      arguments: {'project_id': widget.id},
    )?.then((_) {
      Get.find<ProjectController>().loadProjectGroup(widget.id, 'expenses');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            tooltip: 'Add Expense',
            child: const Icon(Icons.add),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : controller.projectExpensesModel.data?.isNotEmpty ?? false
                  ? RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        controller.loadProjectGroup(widget.id, 'expenses');
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.space15),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.projectExpensesModel.data!.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Dimensions.space10),
                        itemBuilder: (context, index) {
                          final expense =
                              controller.projectExpensesModel.data![index];
                          return _ExpenseCard(expense: expense);
                        },
                      ),
                    )
                  : const Center(child: NoDataWidget()),
        );
      },
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});
  final ProjectExpense expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (expense.isBillable ? Colors.orange : Colors.grey)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: expense.isBillable ? Colors.orange : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name.isNotEmpty ? expense.name : expense.category,
                  style: regularDefault.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(expense.category,
                      style: regularSmall.copyWith(
                          color: ColorResources.contentTextColor,
                          fontSize: 11)),
                ],
                if (expense.date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(expense.date,
                      style: regularSmall.copyWith(
                          color: ColorResources.contentTextColor,
                          fontSize: 10)),
                ],
              ],
            ),
          ),
          Text(
            '${expense.currencySymbol}${expense.amount}',
            style: semiBoldDefault.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

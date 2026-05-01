import 'dart:ui';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/reports/controller/reports_controller.dart';
import 'package:flutex_admin/features/reports/model/reports_model.dart';
import 'package:flutex_admin/features/reports/repo/reports_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ReportsRepo(apiClient: Get.find()));
    final c = Get.put(ReportsController(reportsRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportsController>(builder: (controller) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final topPad = MediaQuery.of(context).padding.top + Dimensions.space5;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: _BlurOrb(
                  size: 200,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: isDark ? 0.18 : 0.25),
                ),
              ),
              Positioned(
                bottom: 160,
                right: -60,
                child: _BlurOrb(
                  size: 160,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: isDark ? 0.25 : 0.55),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(Dimensions.space15, topPad,
                        Dimensions.space15, Dimensions.space10),
                    child: _GlassHeader(
                      isDark: isDark,
                      title: LocalStrings.reports.tr,
                      trailing: DropdownButton<String>(
                        value: controller.selectedYear,
                        dropdownColor: Theme.of(context).cardColor,
                        underline: const SizedBox.shrink(),
                        style: regularSmall.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color),
                        icon: Icon(Icons.arrow_drop_down,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color),
                        items: List.generate(5, (i) {
                          final year = (DateTime.now().year - i).toString();
                          return DropdownMenuItem(
                              value: year, child: Text(year));
                        }),
                        onChanged: (v) {
                          if (v != null) controller.changeYear(v);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading
                        ? const CustomLoader()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SummaryGrid(controller: controller),
                                const SizedBox(height: Dimensions.space20),
                                _ChartCard(
                                  title: LocalStrings.salesByMonth.tr,
                                  data: controller.salesModel.data ?? [],
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _ChartCard(
                                  title: LocalStrings.paymentsReceived.tr,
                                  data: controller.paymentsModel.data ?? [],
                                  color: isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade600,
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _ChartCard(
                                  title: LocalStrings.expenses.tr,
                                  data: controller.expensesModel.data ?? [],
                                  color: isDark
                                      ? Colors.red.shade300
                                      : Colors.red.shade600,
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _ChartCard(
                                  title: LocalStrings.leads.tr,
                                  data: controller.leadsModel.data ?? [],
                                  color: isDark
                                      ? Colors.orange.shade300
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _ChartCard(
                                  title: 'Tax Summary',
                                  data: controller.taxSummaryModel.data ?? [],
                                  color: isDark
                                      ? Colors.purple.shade200
                                      : Colors.purple.shade600,
                                ),
                                const SizedBox(height: Dimensions.space15),
                                _ChartCard(
                                  title: 'By Payment Mode',
                                  data:
                                      controller.byPaymentModeModel.data ?? [],
                                  color: isDark
                                      ? Colors.teal.shade200
                                      : Colors.teal.shade600,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SumItem(LocalStrings.invoices.tr, controller.summaryModel.totalInvoices,
          Icons.receipt_rounded),
      _SumItem(
          LocalStrings.payments.tr,
          controller.summaryModel.totalPaymentsReceived,
          Icons.attach_money_rounded),
      _SumItem(LocalStrings.leads.tr, controller.summaryModel.totalLeads,
          Icons.person_add_rounded),
      _SumItem(LocalStrings.customers.tr,
          controller.summaryModel.totalCustomers, Icons.people_rounded),
      _SumItem(LocalStrings.projects.tr, controller.summaryModel.totalProjects,
          Icons.work_rounded),
      _SumItem(LocalStrings.tickets.tr, controller.summaryModel.totalTickets,
          Icons.confirmation_number_rounded),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.1),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .cardColor
                    .withValues(alpha: isDark ? 0.42 : 0.34),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: isDark ? 0.46 : 0.55),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon,
                      color: Theme.of(context).primaryColor, size: 22),
                  const SizedBox(height: 4),
                  Text(item.value,
                      style: boldLarge.copyWith(
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color)),
                  Text(item.label,
                      style: regularSmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SumItem {
  _SumItem(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard(
      {required this.title, required this.data, required this.color});
  final String title;
  final List<ChartEntry> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.space15),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .cardColor
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: isDark ? 0.46 : 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: regularDefault.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium!.color)),
              const SizedBox(height: 12),
              SfCartesianChart(
                primaryXAxis: CategoryAxis(
                    labelStyle: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).textTheme.bodySmall!.color)),
                primaryYAxis: NumericAxis(
                    labelStyle: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).textTheme.bodySmall!.color)),
                series: <CartesianSeries>[
                  ColumnSeries<ChartEntry, String>(
                    dataSource: data,
                    xValueMapper: (e, _) => e.label,
                    yValueMapper: (e, _) => e.value,
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
              ),
            ],
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
            color: Theme.of(context)
                .cardColor
                .withValues(alpha: isDark ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
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

import 'dart:convert';

import 'package:flutex_admin/features/reports/model/reports_model.dart';
import 'package:flutex_admin/features/reports/repo/reports_repo.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController {
  ReportsRepo reportsRepo;
  ReportsController({required this.reportsRepo});

  bool isLoading = true;
  String selectedYear = DateTime.now().year.toString();

  ReportsSummaryModel summaryModel = ReportsSummaryModel();
  ReportsChartModel salesModel = ReportsChartModel();
  ReportsChartModel paymentsModel = ReportsChartModel();
  ReportsChartModel expensesModel = ReportsChartModel();
  ReportsChartModel leadsModel = ReportsChartModel();
  ReportsChartModel taxSummaryModel = ReportsChartModel();
  ReportsChartModel byPaymentModeModel = ReportsChartModel();

  Future<void> loadAll() async {
    isLoading = true;
    update();
    final results = await Future.wait([
      reportsRepo.getSummary(selectedYear),
      reportsRepo.getSales(selectedYear),
      reportsRepo.getPayments(selectedYear),
      reportsRepo.getExpenses(selectedYear),
      reportsRepo.getLeads(selectedYear),
      reportsRepo.getTaxSummary(selectedYear),
      reportsRepo.getByPaymentMode(selectedYear),
    ]);
    if (results[0].status) {
      summaryModel =
          ReportsSummaryModel.fromJson(jsonDecode(results[0].responseJson));
    }
    if (results[1].status) {
      salesModel =
          ReportsChartModel.fromJson(jsonDecode(results[1].responseJson));
    }
    if (results[2].status) {
      paymentsModel =
          ReportsChartModel.fromJson(jsonDecode(results[2].responseJson));
    }
    if (results[3].status) {
      expensesModel =
          ReportsChartModel.fromJson(jsonDecode(results[3].responseJson));
    }
    if (results[4].status) {
      leadsModel =
          ReportsChartModel.fromJson(jsonDecode(results[4].responseJson));
    }
    if (results[5].status) {
      taxSummaryModel =
          ReportsChartModel.fromJson(jsonDecode(results[5].responseJson));
    }
    if (results[6].status) {
      byPaymentModeModel =
          ReportsChartModel.fromJson(jsonDecode(results[6].responseJson));
    }
    isLoading = false;
    update();
  }

  void changeYear(String year) {
    selectedYear = year;
    update();
    loadAll();
  }
}

class ReportsSummaryModel {
  ReportsSummaryModel.fromJson(dynamic json) {
    message = json['message'];
    final d = json['data'];
    if (d != null) {
      totalInvoices = d['total_invoices']?.toString() ?? '0';
      totalEstimates = d['total_estimates']?.toString() ?? '0';
      totalProposals = d['total_proposals']?.toString() ?? '0';
      totalProjects = d['total_projects']?.toString() ?? '0';
      totalTickets = d['total_tickets']?.toString() ?? '0';
      totalLeads = d['total_leads']?.toString() ?? '0';
      totalCustomers = d['total_customers']?.toString() ?? '0';
      totalExpenses = d['total_expenses']?.toString() ?? '0';
      totalPaymentsReceived = d['total_payments_received']?.toString() ?? '0';
    }
  }
  ReportsSummaryModel();
  String? message;
  String totalInvoices = '0';
  String totalEstimates = '0';
  String totalProposals = '0';
  String totalProjects = '0';
  String totalTickets = '0';
  String totalLeads = '0';
  String totalCustomers = '0';
  String totalExpenses = '0';
  String totalPaymentsReceived = '0';
}

class ReportsChartModel {
  ReportsChartModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      for (final item in json['data']) {
        data?.add(ChartEntry(
          label: item['label']?.toString() ?? '',
          value: double.tryParse(item['value']?.toString() ?? '0') ?? 0.0,
        ));
      }
    }
  }
  ReportsChartModel() : data = [];
  String? message;
  List<ChartEntry>? data;
}

class ChartEntry {
  ChartEntry({required this.label, required this.value});
  String label;
  double value;
}

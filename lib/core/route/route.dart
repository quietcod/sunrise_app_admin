import 'package:flutex_admin/features/announcement/view/add_announcement_screen.dart';
import 'package:flutex_admin/features/attendance/view/attendance_screen.dart';
import 'package:flutex_admin/features/attendance/view/attendance_records_screen.dart';
import 'package:flutex_admin/features/attendance/view/admin_attendance_screen.dart';
import 'package:flutex_admin/features/announcement/view/announcement_screen.dart';
import 'package:flutex_admin/features/announcement/view/update_announcement_screen.dart';
import 'package:flutex_admin/features/profile/view/change_password_screen.dart';
import 'package:flutex_admin/features/profile/view/edit_profile_screen.dart';
import 'package:flutex_admin/features/profile/view/my_timesheets_screen.dart';
import 'package:flutex_admin/features/profile/view/notification_settings_screen.dart';
import 'package:flutex_admin/features/auth/view/forget_password.dart';
import 'package:flutex_admin/features/calendar/view/calendar_screen.dart';
import 'package:flutex_admin/features/credit_note/view/add_credit_note_screen.dart';
import 'package:flutex_admin/features/credit_note/view/credit_note_details_screen.dart';
import 'package:flutex_admin/features/credit_note/view/credit_notes_screen.dart';
import 'package:flutex_admin/features/credit_note/view/update_credit_note_screen.dart';
import 'package:flutex_admin/features/estimate_request/view/estimate_requests_screen.dart';
import 'package:flutex_admin/features/expense/view/add_expense_screen.dart';
import 'package:flutex_admin/features/expense/view/expense_details_screen.dart';
import 'package:flutex_admin/features/expense/view/expense_screen.dart';
import 'package:flutex_admin/features/expense/view/update_expense_screen.dart';
import 'package:flutex_admin/features/gdpr/view/gdpr_screen.dart';
import 'package:flutex_admin/features/auth/view/login_screen.dart';
import 'package:flutex_admin/features/knowledge_base/view/kb_screen.dart';
import 'package:flutex_admin/features/contract/view/add_contract_screen.dart';
import 'package:flutex_admin/features/contract/view/contract_details_screen.dart';
import 'package:flutex_admin/features/contract/view/contracts_screen.dart';
import 'package:flutex_admin/features/contract/view/update_contract_screen.dart';
import 'package:flutex_admin/features/customer/view/add_contact_screen.dart';
import 'package:flutex_admin/features/customer/view/update_contact_screen.dart';
import 'package:flutex_admin/features/customer/view/add_customer_screen.dart';
import 'package:flutex_admin/features/customer/view/customers_screen.dart';
import 'package:flutex_admin/features/customer/view/customer_details_screen.dart';
import 'package:flutex_admin/features/customer/view/update_customer_screen.dart';
import 'package:flutex_admin/features/estimate/view/add_estimate_screen.dart';
import 'package:flutex_admin/features/estimate/view/estimate_details_screen.dart';
import 'package:flutex_admin/features/estimate/view/estimate_screen.dart';
import 'package:flutex_admin/features/estimate/view/update_estimate_screen.dart';
import 'package:flutex_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:flutex_admin/features/newsfeed/view/newsfeed_screen.dart';
import 'package:flutex_admin/features/onboarding/view/onboard_intro_screen.dart';
import 'package:flutex_admin/features/invoice/view/add_invoice_screen.dart';
import 'package:flutex_admin/features/invoice/view/invoice_details_screen.dart';
import 'package:flutex_admin/features/invoice/view/invoice_screen.dart';
import 'package:flutex_admin/features/invoice/view/update_invoice_screen.dart';
import 'package:flutex_admin/features/item/view/item_details_screen.dart';
import 'package:flutex_admin/features/item/view/item_screen.dart';
import 'package:flutex_admin/features/lead/view/add_lead_screen.dart';
import 'package:flutex_admin/features/lead/view/import_leads_screen.dart';
import 'package:flutex_admin/features/lead/view/lead_details_screen.dart';
import 'package:flutex_admin/features/lead/view/lead_screen.dart';
import 'package:flutex_admin/features/lead/view/lead_sources_screen.dart';
import 'package:flutex_admin/features/lead/view/lead_statuses_screen.dart';
import 'package:flutex_admin/features/lead/view/update_lead_screen.dart';
import 'package:flutex_admin/features/menu/view/menu_screen.dart';
import 'package:flutex_admin/features/payment/view/payment_details_screen.dart';
import 'package:flutex_admin/features/payment/view/payment_screen.dart';
import 'package:flutex_admin/features/notification/view/notification_screen.dart';
import 'package:flutex_admin/features/privacy/view/privacy_policy_screen.dart';
import 'package:flutex_admin/features/profile/view/profile_screen.dart';
import 'package:flutex_admin/features/reports/view/reports_screen.dart';
import 'package:flutex_admin/features/expense/view/expense_categories_screen.dart';
import 'package:flutex_admin/features/settings/view/invoice_number_settings_screen.dart';
import 'package:flutex_admin/features/settings/view/client_groups_roles_screen.dart';
import 'package:flutex_admin/features/settings/view/departments_screen.dart';
import 'package:flutex_admin/features/settings/view/payment_modes_screen.dart';
import 'package:flutex_admin/features/settings/view/settings_hub_screen.dart';
import 'package:flutex_admin/features/settings/view/taxes_screen.dart';
import 'package:flutex_admin/features/settings/view/contract_types_screen.dart';
import 'package:flutex_admin/features/staff/view/staff_screen.dart';
import 'package:flutex_admin/features/subscription/view/subscriptions_screen.dart';
import 'package:flutex_admin/features/todo/view/todo_screen.dart';
import 'package:flutex_admin/features/project/view/add_project_screen.dart';
import 'package:flutex_admin/features/project/view/project_details_screen.dart';
import 'package:flutex_admin/features/project/view/project_screen.dart';
import 'package:flutex_admin/features/project/view/update_project_screen.dart';
import 'package:flutex_admin/features/proposal/view/add_proposal_screen.dart';
import 'package:flutex_admin/features/proposal/view/proposal_details_screen.dart';
import 'package:flutex_admin/features/proposal/view/proposal_screen.dart';
import 'package:flutex_admin/features/proposal/view/update_proposal_screen.dart';
import 'package:flutex_admin/features/splash/view/splash_screen.dart';
import 'package:flutex_admin/features/task/view/add_task_screen.dart';
import 'package:flutex_admin/features/task/view/task_details_screen.dart';
import 'package:flutex_admin/features/task/view/task_screen.dart';
import 'package:flutex_admin/features/task/view/update_task_screen.dart';
import 'package:flutex_admin/features/ticket/view/add_ticket_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_details_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_screen.dart';
import 'package:flutex_admin/features/ticket/view/update_ticket_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_priorities_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_statuses_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_services_screen.dart';
import 'package:flutex_admin/features/ticket/view/ticket_spam_filters_screen.dart';
import 'package:flutex_admin/features/work_report/view/work_report_detail_screen.dart';
import 'package:flutex_admin/features/work_report/view/work_reports_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String splashScreen = "/splash_screen";
  static const String onboardScreen = '/onboard_screen';
  static const String loginScreen = "/login_screen";
  static const String forgotPasswordScreen = "/forgot_password_screen";

  static const String dashboardScreen = "/dashboard_screen";
  static const String customerScreen = "/customer_screen";
  static const String customerDetailsScreen = "/customer_details_screen";
  static const String addCustomerScreen = "/add_customer_screen";
  static const String updateCustomerScreen = "/update_customer_screen";
  static const String addContactScreen = "/add_contact_screen";
  static const String updateContactScreen = "/update_contact_screen";
  static const String projectScreen = "/project_screen";
  static const String projectDetailsScreen = "/project_details_screen";
  static const String addProjectScreen = "/add_project_screen";
  static const String updateProjectScreen = "/update_project_screen";
  static const String taskScreen = "/task_screen";
  static const String taskDetailsScreen = "/task_details_screen";
  static const String addTaskScreen = "/add_task_screen";
  static const String updateTaskScreen = "/update_task_screen";
  static const String invoiceScreen = "/invoice_screen";
  static const String invoiceDetailsScreen = "/invoice_details_screen";
  static const String addInvoiceScreen = "/add_invoice_screen";
  static const String updateInvoiceScreen = "/update_invoice_screen";
  static const String contractScreen = "/contract_screen";
  static const String contractDetailsScreen = "/contract_details_screen";
  static const String addContractScreen = "/add_contract_screen";
  static const String updateContractScreen = "/update_contract_screen";
  static const String ticketScreen = "/ticket_screen";
  static const String ticketDetailsScreen = "/ticket_details_screen";
  static const String addTicketScreen = "/add_ticket_screen";
  static const String updateTicketScreen = "/update_ticket_screen";
  static const String ticketPrioritiesScreen = "/ticket_priorities_screen";
  static const String ticketStatusesScreen = "/ticket_statuses_screen";
  static const String ticketServicesScreen = "/ticket_services_screen";
  static const String ticketSpamFiltersScreen = "/ticket_spam_filters_screen";
  static const String leadScreen = "/lead_screen";
  static const String leadDetailsScreen = "/lead_details_screen";
  static const String addLeadScreen = "/add_lead_screen";
  static const String updateLeadScreen = "/update_lead_screen";
  static const String leadSourcesScreen = "/lead_sources_screen";
  static const String leadStatusesScreen = "/lead_statuses_screen";
  static const String importLeadsScreen = "/import_leads_screen";
  static const String estimateScreen = "/estimate_screen";
  static const String estimateDetailsScreen = "/estimate_details_screen";
  static const String addEstimateScreen = "/add_estimate_screen";
  static const String updateEstimateScreen = "/update_estimate_screen";
  static const String proposalScreen = "/proposal_screen";
  static const String proposalDetailsScreen = "/proposal_details_screen";
  static const String addProposalScreen = "/add_proposal_screen";
  static const String updateProposalScreen = "/update_proposal_screen";
  static const String paymentScreen = "/payment_screen";
  static const String paymentDetailsScreen = "/payment_details_screen";
  static const String expenseScreen = "/expense_screen";
  static const String expenseDetailsScreen = "/expense_details_screen";
  static const String addExpenseScreen = "/add_expense_screen";
  static const String updateExpenseScreen = "/update_expense_screen";
  static const String itemScreen = "/item_screen";
  static const String itemDetailsScreen = "/item_details_screen";
  static const String settingsScreen = "/settings_screen";
  static const String profileScreen = "/profile_screen";
  static const String privacyScreen = "/privacy_screen";
  static const String notificationScreen = "/notification_screen";
  static const String creditNotesScreen = "/credit_notes_screen";
  static const String creditNoteDetailsScreen = "/credit_note_details_screen";
  static const String addCreditNoteScreen = "/add_credit_note_screen";
  static const String updateCreditNoteScreen = "/update_credit_note_screen";
  static const String todoScreen = "/todo_screen";
  static const String announcementScreen = "/announcement_screen";
  static const String addAnnouncementScreen = "/add_announcement_screen";
  static const String updateAnnouncementScreen = "/update_announcement_screen";
  static const String staffScreen = "/staff_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String changePasswordScreen = "/change_password_screen";

  // New module routes
  static const String expenseCategoriesScreen = "/expense_categories_screen";
  static const String invoiceNumberSettingsScreen =
      "/invoice_number_settings_screen";
  static const String contractTypesScreen = "/contract_types_screen";
  static const String settingsHubScreen = "/settings_hub_screen";
  static const String taxesScreen = "/taxes_screen";
  static const String paymentModesScreen = "/payment_modes_screen";
  static const String departmentsScreen = "/departments_screen";
  static const String clientGroupsScreen = "/client_groups_screen";
  static const String rolesScreen = "/roles_screen";
  static const String kbGroupsScreen = "/kb_groups_screen";
  static const String kbArticlesScreen = "/kb_articles_screen";
  static const String subscriptionsScreen = "/subscriptions_screen";
  static const String reportsScreen = "/reports_screen";
  static const String calendarScreen = "/calendar_screen";
  static const String newsfeedScreen = "/newsfeed_screen";
  static const String gdprScreen = "/gdpr_screen";
  static const String estimateRequestsScreen = "/estimate_requests_screen";
  static const String workReportsScreen = "/work_reports_screen";
  static const String workReportDetailScreen = "/work_report_detail_screen";
  static const String myTimesheetsScreen = "/my_timesheets_screen";
  static const String notificationSettingsScreen =
      "/notification_settings_screen";
  static const String attendanceScreen = "/attendance_screen";
  static const String attendanceRecordsScreen = "/attendance_records_screen";
  static const String adminAttendanceScreen = "/admin_attendance_screen";
  List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardScreen, page: () => const OnBoardIntroScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(
        name: forgotPasswordScreen, page: () => const ForgetPasswordScreen()),
    GetPage(name: dashboardScreen, page: () => const DashboardScreen()),
    GetPage(name: customerScreen, page: () => const CustomersScreen()),
    GetPage(
        name: customerDetailsScreen,
        page: () => CustomerDetailsScreen(id: Get.arguments)),
    GetPage(name: addCustomerScreen, page: () => const AddCustomerScreen()),
    GetPage(
        name: addContactScreen,
        page: () => AddContactScreen(id: Get.arguments)),
    GetPage(
        name: updateContactScreen,
        page: () => UpdateContactScreen(
            contact: Get.arguments['contact'],
            customerId: Get.arguments['customerId'])),
    GetPage(
        name: updateCustomerScreen,
        page: () => UpdateCustomerScreen(id: Get.arguments)),
    GetPage(name: projectScreen, page: () => const ProjectsScreen()),
    GetPage(
        name: projectDetailsScreen,
        page: () => ProjectDetailsScreen(id: Get.arguments)),
    GetPage(name: addProjectScreen, page: () => const AddProjectScreen()),
    GetPage(
        name: updateProjectScreen,
        page: () => UpdateProjectScreen(id: Get.arguments)),
    GetPage(name: taskScreen, page: () => const TaskScreen()),
    GetPage(
        name: taskDetailsScreen,
        page: () => TaskDetailsScreen(id: Get.arguments)),
    GetPage(name: addTaskScreen, page: () => const AddTaskScreen()),
    GetPage(
        name: updateTaskScreen,
        page: () => UpdateTaskScreen(id: Get.arguments)),
    GetPage(name: invoiceScreen, page: () => const InvoicesScreen()),
    GetPage(
        name: invoiceDetailsScreen,
        page: () => InvoiceDetailsScreen(id: Get.arguments)),
    GetPage(name: addInvoiceScreen, page: () => const AddInvoiceScreen()),
    GetPage(
        name: updateInvoiceScreen,
        page: () => UpdateInvoiceScreen(id: Get.arguments)),
    GetPage(name: contractScreen, page: () => const ContractsScreen()),
    GetPage(
        name: contractDetailsScreen,
        page: () => ContractDetailsScreen(id: Get.arguments)),
    GetPage(name: addContractScreen, page: () => const AddContractScreen()),
    GetPage(
        name: updateContractScreen,
        page: () => UpdateContractScreen(id: Get.arguments)),
    GetPage(name: ticketScreen, page: () => const TicketsScreen()),
    GetPage(
        name: ticketDetailsScreen,
        page: () => TicketDetailsScreen(id: Get.arguments)),
    GetPage(name: addTicketScreen, page: () => const AddTicketScreen()),
    GetPage(
        name: updateTicketScreen,
        page: () => UpdateTicketScreen(id: Get.arguments)),
    GetPage(
        name: ticketPrioritiesScreen,
        page: () => const TicketPrioritiesScreen()),
    GetPage(
        name: ticketStatusesScreen, page: () => const TicketStatusesScreen()),
    GetPage(
        name: ticketServicesScreen, page: () => const TicketServicesScreen()),
    GetPage(
        name: ticketSpamFiltersScreen,
        page: () => const TicketSpamFiltersScreen()),
    GetPage(name: leadScreen, page: () => const LeadScreen()),
    GetPage(
        name: leadDetailsScreen,
        page: () => LeadDetailsScreen(id: Get.arguments)),
    GetPage(name: addLeadScreen, page: () => const AddLeadScreen()),
    GetPage(
        name: updateLeadScreen,
        page: () => UpdateLeadScreen(id: Get.arguments)),
    GetPage(name: leadSourcesScreen, page: () => const LeadSourcesScreen()),
    GetPage(name: leadStatusesScreen, page: () => const LeadStatusesScreen()),
    GetPage(name: importLeadsScreen, page: () => const ImportLeadsScreen()),
    GetPage(name: estimateScreen, page: () => const EstimateScreen()),
    GetPage(
        name: estimateDetailsScreen,
        page: () => EstimateDetailsScreen(id: Get.arguments)),
    GetPage(name: addEstimateScreen, page: () => const AddEstimateScreen()),
    GetPage(
        name: updateEstimateScreen,
        page: () => UpdateEstimateScreen(id: Get.arguments)),
    GetPage(name: proposalScreen, page: () => const ProposalScreen()),
    GetPage(
        name: proposalDetailsScreen,
        page: () => ProposalDetailsScreen(id: Get.arguments)),
    GetPage(name: addProposalScreen, page: () => const AddProposalScreen()),
    GetPage(
        name: updateProposalScreen,
        page: () => UpdateProposalScreen(id: Get.arguments)),
    GetPage(name: paymentScreen, page: () => const PaymentScreen()),
    GetPage(
        name: paymentDetailsScreen,
        page: () => PaymentDetailsScreen(id: Get.arguments)),
    GetPage(name: expenseScreen, page: () => const ExpenseScreen()),
    GetPage(
        name: expenseDetailsScreen,
        page: () => ExpenseDetailsScreen(id: Get.arguments)),
    GetPage(name: addExpenseScreen, page: () => const AddExpenseScreen()),
    GetPage(name: updateExpenseScreen, page: () => const UpdateExpenseScreen()),
    GetPage(name: itemScreen, page: () => const ItemScreen()),
    GetPage(
        name: itemDetailsScreen,
        page: () => ItemDetailsScreen(id: Get.arguments)),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: settingsScreen, page: () => const MenuScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyPolicyScreen()),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),
    GetPage(name: creditNotesScreen, page: () => const CreditNotesScreen()),
    GetPage(
        name: creditNoteDetailsScreen,
        page: () => CreditNoteDetailsScreen(id: Get.arguments)),
    GetPage(name: addCreditNoteScreen, page: () => const AddCreditNoteScreen()),
    GetPage(
        name: updateCreditNoteScreen,
        page: () => UpdateCreditNoteScreen(id: Get.arguments)),
    GetPage(name: todoScreen, page: () => const TodoScreen()),
    GetPage(name: announcementScreen, page: () => const AnnouncementScreen()),
    GetPage(
        name: addAnnouncementScreen, page: () => const AddAnnouncementScreen()),
    GetPage(
        name: updateAnnouncementScreen,
        page: () => UpdateAnnouncementScreen(announcement: Get.arguments)),
    GetPage(name: staffScreen, page: () => const StaffScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(
        name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    // New module pages
    GetPage(
        name: expenseCategoriesScreen,
        page: () => const ExpenseCategoriesScreen()),
    GetPage(
        name: invoiceNumberSettingsScreen,
        page: () => const InvoiceNumberSettingsScreen()),
    GetPage(name: contractTypesScreen, page: () => const ContractTypesScreen()),
    GetPage(name: settingsHubScreen, page: () => const SettingsHubScreen()),
    GetPage(name: taxesScreen, page: () => const TaxesScreen()),
    GetPage(name: paymentModesScreen, page: () => const PaymentModesScreen()),
    GetPage(name: departmentsScreen, page: () => const DepartmentsScreen()),
    GetPage(name: clientGroupsScreen, page: () => const ClientGroupsScreen()),
    GetPage(name: rolesScreen, page: () => const RolesScreen()),
    GetPage(name: kbGroupsScreen, page: () => const KbGroupsScreen()),
    GetPage(name: kbArticlesScreen, page: () => const KbArticlesScreen()),
    GetPage(name: subscriptionsScreen, page: () => const SubscriptionsScreen()),
    GetPage(name: reportsScreen, page: () => const ReportsScreen()),
    GetPage(name: calendarScreen, page: () => const CalendarScreen()),
    GetPage(name: newsfeedScreen, page: () => const NewsfeedScreen()),
    GetPage(name: gdprScreen, page: () => const GdprScreen()),
    GetPage(
        name: estimateRequestsScreen,
        page: () => const EstimateRequestsScreen()),
    GetPage(name: workReportsScreen, page: () => const WorkReportsScreen()),
    GetPage(
        name: workReportDetailScreen,
        page: () {
          final args = Get.arguments;
          final id =
              (args is Map && args['id'] != null) ? args['id'].toString() : '';
          final reply = (args is Map && args['reply'] == true);
          return WorkReportDetailScreen(reportId: id, autoFocusReply: reply);
        }),
    GetPage(name: myTimesheetsScreen, page: () => const MyTimesheetsScreen()),
    GetPage(
        name: notificationSettingsScreen,
        page: () => const NotificationSettingsScreen()),
    GetPage(name: attendanceScreen, page: () => const AttendanceScreen()),
    GetPage(
        name: attendanceRecordsScreen,
        page: () => const AttendanceRecordsScreen()),
    GetPage(
        name: adminAttendanceScreen, page: () => const AdminAttendanceScreen()),
  ];
}

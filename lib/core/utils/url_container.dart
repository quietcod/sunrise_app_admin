class UrlContainer {
  static const String domainUrl = 'https://admin.thesunrisecomputers.com/';
  static const String baseUrl =
      'https://admin.thesunrisecomputers.com/flutex_admin_api/';

  static const String downloadUrl = '$domainUrl/download/file';
  static const String uploadPath = 'uploads';
  static const String ticketAttachmentUrl =
      '$domainUrl/download/preview_image?path=$uploadPath/ticket_attachments/';

  static RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // Authentication
  static const String loginUrl = 'auth/login';
  static const String logoutUrl = 'auth/logout';
  static const String forgotPasswordUrl = 'auth/forgot-password';
  static const String fcmTokenUrl = 'auth/fcm-token';

  // Pages
  static const String overviewUrl = 'overview';
  static const String dashboardUrl = 'dashboard';
  static const String profileUrl = 'profile';
  static const String profileTimesheetsUrl = 'profile/timesheets';
  static const String customersUrl = 'customers';
  static const String customerNotesUrl = 'customers/notes';
  static const String customerNoteDeleteUrl = 'customers/note';
  static const String customerCreditNotesUrl = 'customers/credit_notes';
  static const String customerActivitiesUrl = 'customers/activities';
  static const String customerInvoicesUrl = 'customers/invoices';
  static const String customerTicketsUrl = 'customers/tickets';
  static const String customerSubscriptionsUrl = 'customers/subscriptions';
  static const String customerContactStatusUrl = 'customers/contact_status';
  static const String customerContactImageDeleteUrl = 'customers/contact_image';
  static const String customerContactFileAccessUrl =
      'customers/contact_file_access';
  static const String customerStatementUrl = 'customers/statement';
  static const String customerGroupAssignUrl = 'customers/assign_group';
  static const String customerAttachmentsUrl = 'customers/attachments';
  static const String customerAttachmentUrl = 'customers/attachment';
  static const String customerAdminsUrl = 'customers/admins';
  static const String customerGdprConsentsUrl = 'customers/gdpr_consents';
  static const String contactsUrl = 'contacts';
  static const String projectsUrl = 'projects';
  static const String projectMilestoneUrl = 'projects/milestone';
  static const String projectNotesUrl = 'projects/notes';
  static const String projectNoteUrl = 'projects/note';
  static const String projectDiscussionUrl = 'projects/discussion';
  static const String projectDiscussionCommentUrl =
      'projects/discussion_comment';
  static const String projectCopyUrl = 'projects/copy';
  static const String projectStatusUrl = 'projects/status';
  static const String projectActivityUrl = 'projects/activity';
  static const String projectTimersStopUrl = 'projects/timers_stop';
  static const String projectDiscussionAttachmentUrl =
      'projects/discussion_attachment';
  static const String projectTaskMilestoneUrl = 'projects/task_milestone';
  static const String projectDiscussionsWithAttachmentsUrl =
      'projects/discussions_with_attachments';
  static const String projectFileUrl = 'projects/file';
  static const String invoicesUrl = 'invoices';
  static const String invoiceCopyUrl = 'invoices/copy';
  static const String invoiceAttachmentsUrl = 'invoices/attachments';
  static const String invoiceAttachmentDeleteUrl = 'invoices/attachment';
  static const String invoiceOverdueNoticeUrl = 'invoices/send_overdue_notice';
  static const String invoiceToggleRemindersUrl = 'invoices/toggle_reminders';
  static const String invoiceApplyCreditUrl = 'invoices/apply_credit';
  static const String invoiceAvailableCreditsUrl = 'invoices/available_credits';
  static const String invoiceMergeUrl = 'invoices/merge';
  static const String contractsUrl = 'contracts';
  static const String estimatesUrl = 'estimates';
  static const String estimateCopyUrl = 'estimates/copy';
  static const String estimateExpiryReminderUrl =
      'estimates/send_expiry_reminder';
  static const String estimateAttachmentsUrl = 'estimates/attachments';
  static const String estimateAttachmentDeleteUrl = 'estimates/attachment';
  static const String estimateClearSignatureUrl = 'estimates/clear_signature';
  static const String estimateAdminNoteUrl = 'estimates/admin_note';
  static const String proposalsUrl = 'proposals';
  static const String proposalCopyUrl = 'proposals/copy';
  static const String proposalExpiryReminderUrl =
      'proposals/send_expiry_reminder';
  static const String proposalCommentsUrl = 'proposals/comments';
  static const String proposalCommentDeleteUrl = 'proposals/comment';
  static const String proposalAttachmentsUrl = 'proposals/attachments';
  static const String proposalAttachmentDeleteUrl = 'proposals/attachment';
  static const String proposalClearSignatureUrl = 'proposals/clear_signature';
  static const String ticketsUrl = 'tickets';
  static const String ticketCloseRequestOtpUrl = 'tickets/send_otp';
  static const String ticketCloseVerifyOtpUrl = 'tickets/verify_otp';
  static const String ticketCloseResendOtpUrl = 'tickets/resend_otp';
  static const String ticketCloseWithoutOtpUrl = 'tickets/close_no_otp';
  static const String ticketSendOtpToNumberUrl = 'tickets/send_otp_alternate';
  // Ticket management (admin CRUD)
  static const String ticketPrioritiesAdminUrl = 'tickets/priorities';
  static const String ticketPriorityAdminUrl = 'tickets/priority';
  static const String ticketStatusesAdminUrl = 'tickets/ticket_statuses';
  static const String ticketStatusAdminUrl = 'tickets/ticket_status';
  static const String ticketServicesAdminUrl = 'tickets/services';
  static const String ticketServiceAdminUrl = 'tickets/service';
  static const String ticketSpamFiltersAdminUrl = 'tickets/spam_filters';
  static const String ticketSpamFilterAdminUrl = 'tickets/spam_filter';
  static const String ticketBulkUrl = 'tickets/bulk';
  static const String leadsUrl = 'leads';
  static const String tasksUrl = 'tasks';
  static const String paymentsUrl = 'payments';
  static const String expensesUrl = 'expenses';
  static const String itemsUrl = 'items';
  static const String miscellaneousUrl = 'miscellaneous';
  static const String privacyPolicyUrl = 'policy-pages';

  // New modules
  static const String notificationsUrl = 'notifications';
  static const String markNotificationReadUrl = 'notifications/mark_read';
  static const String markAllNotificationsReadUrl =
      'notifications/mark_all_read';
  static const String creditNotesUrl = 'credit_notes';
  static const String todosUrl = 'todos';
  static const String announcementsUrl = 'announcements';
  static const String staffUrl = 'staff';
  static const String changePasswordUrl = 'profile/change_password';

  // Download URLs
  static const String leadAttachmentUrl = '$downloadUrl/lead_attachment';
  static const String salesAttachmentUrl = '$downloadUrl/sales_attachment';
  // Send by email
  static const String emailInvoiceUrl = 'email/invoice';
  static const String emailEstimateUrl = 'email/estimate';
  static const String emailProposalUrl = 'email/proposal';
  static const String emailContractUrl = 'email/contract';
  static const String emailPaymentUrl = 'email/payment';
  static const String emailCreditNoteUrl = 'email/creditnote';
  // Task checklist
  static const String taskChecklistUrl = 'task_checklist';
  static const String taskChecklistOrderUrl = 'tasks/checklist_order';
  // Task team
  static const String taskAssigneesUrl = 'task_team/assignees';
  static const String taskFollowersUrl = 'task_team/followers';
  // Task extras
  static const String taskAttachmentDeleteUrl = 'tasks/attachment';
  static const String taskTimerUrl = 'tasks/timer';
  static const String taskTimesheetsUrl = 'tasks/timesheets';
  static const String taskTimelogUrl = 'tasks/timelog';
  static const String taskCopyUrl = 'tasks/copy';
  static const String taskMilestonesUrl = 'tasks/milestones';
  static const String taskChecklistAssignUrl = 'tasks/checklist_assign';
  static const String taskRemindersUrl = 'tasks/reminders';
  static const String taskReminderUrl = 'tasks/reminder';
  // Predefined replies
  static const String predefinedRepliesUrl = 'predefined_replies';
  // Contract actions
  static const String contractSignUrl = 'contract_actions/sign';
  static const String contractCopyUrl = 'contract_actions/copy';
  static const String contractNotesUrl = 'contracts/notes';
  static const String contractNoteDeleteUrl = 'contracts/note';
  static const String contractCommentsUrl = 'contracts/comments';
  static const String contractCommentDeleteUrl = 'contracts/comment';
  static const String contractAttachmentsUrl = 'contracts/attachments';
  static const String contractAttachmentDeleteUrl = 'contracts/attachment';
  static const String contractClearSignatureUrl = 'contracts/clear_signature';
  static const String contractRenewUrl = 'contracts/renew';
  static const String contractTypesUrl = 'settings/contract_types';
  // Lead notes
  static const String leadNotesUrl = 'leads/notes';
  // Lead activity log
  static const String leadActivityUrl = 'leads/activity';
  // Lead reminders
  static const String leadRemindersUrl = 'leads/reminders';
  static const String leadReminderUrl = 'leads/reminder';
  // Lead sources admin CRUD
  static const String leadSourcesAdminUrl = 'leads/sources';
  static const String leadSourceAdminUrl = 'leads/source';
  // Lead statuses admin CRUD
  static const String leadStatusesAdminUrl = 'leads/lead_statuses';
  static const String leadStatusAdminUrl = 'leads/lead_status';
  // PDF web URLs (opened in browser)
  static const String pdfPaymentWebUrl =
      '${domainUrl}admin/invoices/payment_pdf/';
  static const String emailPaymentReceiptUrl = 'payments/email_receipt';
  static const String pdfInvoiceWebUrl = '${domainUrl}admin/invoices/pdf/';
  static const String pdfEstimateWebUrl = '${domainUrl}admin/estimates/pdf/';
  static const String pdfProposalWebUrl = '${domainUrl}admin/proposals/pdf/';
  static const String pdfContractWebUrl = '${domainUrl}admin/contracts/pdf/';
  static const String pdfCreditNoteWebUrl =
      '${domainUrl}admin/credit_notes/pdf/';
  static const String pdfExpenseWebUrl = '${domainUrl}admin/expenses/pdf/';
  static const String expenseConvertToInvoiceUrl =
      'expenses/convert_to_invoice';

  // ── New module URLs ────────────────────────────────────────────────────────

  // Settings management
  static const String settingsUrl = 'settings';
  static const String settingsTaxesUrl = 'settings/taxes';
  static const String settingsPaymentModesUrl = 'settings/payment_modes';
  static const String settingsDepartmentsUrl = 'settings/departments';
  static const String settingsClientGroupsUrl = 'settings/client_groups';
  static const String settingsRolesUrl = 'settings/roles';
  static const String settingsInvoiceNumberUrl = 'settings/invoice_number';

  // Knowledge Base
  static const String kbGroupsUrl = 'knowledge_base/groups';
  static const String kbArticlesUrl = 'knowledge_base/articles';
  static const String kbArticlesSearchUrl = 'knowledge_base/articles_search';

  // Subscriptions
  static const String subscriptionsUrl = 'subscriptions';
  static const String subscriptionCancelUrl = 'subscriptions/cancel';
  static const String subscriptionsSearchUrl = 'subscriptions/search';

  // Reports
  static const String reportsSalesUrl = 'reports/sales';
  static const String reportsPaymentsUrl = 'reports/payments';
  static const String reportsExpensesUrl = 'reports/expenses';
  static const String reportsLeadsUrl = 'reports/leads';
  static const String reportsSummaryUrl = 'reports/summary';
  static const String reportsTaxSummaryUrl = 'reports/tax_summary';
  static const String reportsByPaymentModeUrl = 'reports/by_payment_mode';

  // Calendar
  static const String calendarEventsUrl = 'calendar/events';
  static const String calendarUpcomingUrl = 'calendar/upcoming';

  // Newsfeed
  static const String newsfeedPostsUrl = 'newsfeed/posts';
  static const String newsfeedLikeUrl = 'newsfeed/like';
  static const String newsfeedCommentsUrl = 'newsfeed/comments';
  static const String newsfeedPinUrl = 'newsfeed/pin';
  static const String newsfeedUnpinUrl = 'newsfeed/unpin';

  // GDPR
  static const String gdprPurposesUrl = 'gdpr/purposes';
  static const String gdprRemovalRequestsUrl = 'gdpr/removal_requests';
  static const String gdprConsentsUrl = 'gdpr/consents';

  // Estimate Requests
  static const String estimateRequestsUrl = 'estimate_requests/requests';
  static const String estimateRequestStatusUrl = 'estimate_requests/status';
  static const String estimateRequestAssignUrl = 'estimate_requests/assign';
  static const String estimateRequestConvertUrl = 'estimate_requests/convert';

  // Staff Work Reports
  static const String workReportsUrl = 'work_reports/reports';
  static const String workReportRepliesUrl = 'work_reports/replies';

  // Attendance & Location Tracking
  static const String attendanceTodayUrl = 'attendance/today';
  static const String attendanceCheckinUrl = 'attendance/checkin';
  static const String attendanceCheckoutUrl = 'attendance/checkout';
  static const String attendanceHistoryUrl = 'attendance/history';
  static const String attendanceLocationUrl = 'attendance/location';
  static const String attendanceLocationHistoryUrl =
      'attendance/location_history';
  static const String attendanceRecordsUrl = 'attendance/records';
  static const String attendanceLocationRecordsUrl =
      'attendance/location_records';
  static const String attendanceReportUrl = 'attendance/report';

  // ── Generic cross-cutting (reminders, activity, custom_fields, files) ─────
  static const String genericRemindersUrl = 'generic/reminders';
  static const String genericReminderUrl = 'generic/reminder';
  static const String genericCustomFieldsUrl = 'generic/custom_fields';
  static const String genericActivityUrl = 'generic/activity';
  static const String genericAttachmentsUrl = 'generic/attachments';
  static const String genericAttachmentUrl = 'generic/attachment';
}

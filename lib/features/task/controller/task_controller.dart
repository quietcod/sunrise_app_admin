import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart'
    as formatter;
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/contract/model/contract_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutex_admin/features/task/model/task_create_model.dart';
import 'package:flutex_admin/features/task/model/task_details_model.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutex_admin/features/task/repo/task_repo.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/ticket/model/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  TaskRepo taskRepo;
  TaskController({required this.taskRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  bool hasPermissionError = false;
  bool isPublic = false;
  bool billable = false;
  TasksModel tasksModel = TasksModel();
  TaskDetailsModel taskDetailsModel = TaskDetailsModel();
  CustomersModel customersModel = CustomersModel();
  ProjectsModel projectsModel = ProjectsModel();
  InvoicesModel invoicesModel = InvoicesModel();
  ProposalsModel proposalsModel = ProposalsModel();
  EstimatesModel estimatesModel = EstimatesModel();
  ContractsModel contractsModel = ContractsModel();
  LeadsModel leadsModel = LeadsModel();
  TicketsModel ticketsModel = TicketsModel();

  final Map<String, String> taskPriority = {
    '1': LocalStrings.priorityLow.tr,
    '2': LocalStrings.priorityMedium.tr,
    '3': LocalStrings.priorityHigh.tr,
    '4': LocalStrings.priorityUrgent.tr,
  };

  final Map<String, String> taskRelated = {
    'lead': LocalStrings.lead.tr,
    'customer': LocalStrings.customer.tr,
    'invoice': LocalStrings.invoice.tr,
    'project': LocalStrings.project.tr,
    'estimate': LocalStrings.estimate.tr,
    'contract': LocalStrings.contract.tr,
    'ticket': LocalStrings.ticket.tr,
    //'expense': LocalStrings.expense.tr,
    'proposal': LocalStrings.proposal.tr,
  };

  final Map<String, String> repeatEvery = {
    '1': LocalStrings.week.tr,
    '2': LocalStrings.twoWeeks.tr,
    '3': LocalStrings.oneMonth.tr,
    '4': LocalStrings.twoMonths.tr,
    '5': LocalStrings.threeMonths.tr,
    '6': LocalStrings.sixMonths.tr,
    '7': LocalStrings.oneYear.tr,
    '8': LocalStrings.custom.tr,
  };

  final Map<String, String> repeatType = {
    'day': LocalStrings.days.tr,
    'week': LocalStrings.weeks.tr,
    'month': LocalStrings.months.tr,
    'year': LocalStrings.years.tr,
  };

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    await loadTasks();
    isLoading = false;
    update();
  }

  Future<void> loadTasks() async {
    ResponseModel responseModel = await taskRepo.getAllTasks();

    // Fallback: try own-tasks endpoint if global view is forbidden
    if (!responseModel.status && responseModel.isForbidden) {
      final staffId = taskRepo.apiClient.sharedPreferences
          .getString(SharedPreferenceHelper.userIdKey);
      responseModel = await taskRepo.getOwnTasksFallback(staffId: staffId);
    }

    if (responseModel.status) {
      hasPermissionError = false;
      tasksModel = TasksModel.fromJson(jsonDecode(responseModel.responseJson));
    } else if (responseModel.isForbidden) {
      hasPermissionError = true;
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadTaskDetails(taskId) async {
    ResponseModel responseModel = await taskRepo.getTaskDetails(taskId);
    if (responseModel.status) {
      taskDetailsModel =
          TaskDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isLoading = false;
    update();
  }

  void changeIsPublic() {
    isPublic = !isPublic;
    update();
  }

  void changeBillable() {
    billable = !billable;
    update();
  }

  Future<CustomersModel> loadCustomers() async {
    ResponseModel responseModel = await taskRepo.getAllCustomers();
    return customersModel =
        CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<ProjectsModel> loadProjects() async {
    ResponseModel responseModel = await taskRepo.getAllProjects();
    return projectsModel =
        ProjectsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<InvoicesModel> loadInvoices() async {
    ResponseModel responseModel = await taskRepo.getAllInvoices();
    return invoicesModel =
        InvoicesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<LeadsModel> loadLeads() async {
    ResponseModel responseModel = await taskRepo.getAllLeads();
    return leadsModel =
        LeadsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<ContractsModel> loadContracts() async {
    ResponseModel responseModel = await taskRepo.getAllContracts();
    return contractsModel =
        ContractsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<EstimatesModel> loadEstimates() async {
    ResponseModel responseModel = await taskRepo.getAllEstimates();
    return estimatesModel =
        EstimatesModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<ProposalsModel> loadProposals() async {
    ResponseModel responseModel = await taskRepo.getAllProposals();
    return proposalsModel =
        ProposalsModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<void> loadTaskUpdateData(taskId) async {
    ResponseModel responseModel = await taskRepo.getTaskDetails(taskId);
    if (responseModel.status) {
      taskDetailsModel =
          TaskDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      subjectController.text = taskDetailsModel.data?.name ?? '';
      rateController.text = taskDetailsModel.data?.hourlyRate ?? '';
      milestoneController.text = taskDetailsModel.data?.milestone ?? '';
      startDateController.text = taskDetailsModel.data?.startDate ?? '';
      dueDateController.text = taskDetailsModel.data?.dueDate ?? '';
      taskPriorityController.text = taskDetailsModel.data?.priority ?? '';
      taskRelatedController.text = taskDetailsModel.data?.relType ?? '';
      relationIdController.text = taskDetailsModel.data?.relId ?? '';
      descriptionController.text = formatter.Converter.parseHtmlString(
          taskDetailsModel.data?.description ?? '');
      if ((taskDetailsModel.data?.relType ?? '') == 'project' &&
          (taskDetailsModel.data?.relId ?? '').isNotEmpty) {
        loadProjectMilestones(taskDetailsModel.data!.relId!);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  TextEditingController subjectController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController taskPriorityController = TextEditingController();
  TextEditingController repeatEveryController = TextEditingController();
  TextEditingController repeatEveryCustomController = TextEditingController();
  TextEditingController repeatTypeCustomController = TextEditingController();
  TextEditingController taskRelatedController = TextEditingController();
  TextEditingController relationIdController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode subjectFocusNode = FocusNode();
  FocusNode rateFocusNode = FocusNode();
  FocusNode startDateFocusNode = FocusNode();
  FocusNode dueDateFocusNode = FocusNode();
  FocusNode taskPriorityFocusNode = FocusNode();
  FocusNode taskRelatedFocusNode = FocusNode();
  FocusNode relationIdFocusNode = FocusNode();
  FocusNode repeatEveryFocusNode = FocusNode();
  FocusNode repeatEveryCustomFocusNode = FocusNode();
  FocusNode repeatTypeCustomFocusNode = FocusNode();
  FocusNode tagsFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  Future<void> submitTask({String? taskId, bool isUpdate = false}) async {
    String subject = subjectController.text.toString();
    String rate = rateController.text.toString();
    String startDate = startDateController.text.toString();
    String dueDate = dueDateController.text.toString();
    String priority = taskPriorityController.text.toString();
    String repeat = repeatEveryController.text.toString();
    String related = taskRelatedController.text.toString();
    String relId = relationIdController.text.toString();
    String tags = tagsController.text.toString();
    String description = descriptionController.text.toString();

    if (subject.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterSubject.tr]);
      return;
    }
    if (startDate.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterStartDate.tr]);
      return;
    }

    isSubmitLoading = true;
    update();

    TaskCreateModel taskModel = TaskCreateModel(
      subject: subject,
      isPublic: isPublic ? 'on' : '',
      billable: billable ? 'on' : '',
      hourlyRate: rate,
      milestone: milestoneController.text,
      startDate: startDate,
      dueDate: dueDate,
      priority: priority,
      repeatEvery: repeat,
      relType: related,
      relId: relId,
      tags: tags,
      description: description,
    );

    ResponseModel responseModel = await taskRepo.createTask(taskModel,
        taskId: taskId, isUpdate: isUpdate);
    if (responseModel.status) {
      Get.back();
      if (isUpdate) await loadTaskDetails(taskId);
      clearData();
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Delete Task
  Future<void> deleteTask(taskId) async {
    ResponseModel responseModel = await taskRepo.deleteTask(taskId);

    isSubmitLoading = true;
    update();

    if (responseModel.status) {
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [(responseModel.message.tr)]);
    }

    isSubmitLoading = false;
    update();
  }

  Future<void> changeTaskStatus(String taskId, String status) async {
    final response = await taskRepo.changeTaskStatus(taskId, status);
    if (response.status) {
      await loadTaskDetails(taskId);
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  Future<void> changeTaskPriority(String taskId, String priority) async {
    final response = await taskRepo.changeTaskPriority(taskId, priority);
    if (response.status) {
      await loadTaskDetails(taskId);
      CustomSnackBar.success(successList: [response.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [response.message.tr]);
    }
  }

  // Search Tasks
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchTask() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await taskRepo.searchTask(keysearch);
    if (responseModel.status) {
      tasksModel = TasksModel.fromJson(jsonDecode(responseModel.responseJson));
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

  void clearData() {
    isLoading = false;
    isSubmitLoading = false;
    isPublic = false;
    billable = false;
    subjectController.text = '';
    rateController.text = '';
    startDateController.text = '';
    dueDateController.text = '';
    taskPriorityController.text = '';
    taskRelatedController.text = '';
    relationIdController.text = '';
    tagsController.text = '';
    descriptionController.text = '';
    repeatTypeCustomController.text = '';
    repeatEveryCustomController.text = '';
    repeatEveryController.text = '';
    milestoneController.text = '';
    projectMilestones = [];
  }

  // ── Task checklist ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> checklistItems = [];
  bool isChecklistLoading = false;

  Future<void> loadChecklist(String taskId) async {
    isChecklistLoading = true;
    update();
    final response = await taskRepo.getChecklist(taskId);
    isChecklistLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final data = decoded['data'];
      if (data is List) {
        checklistItems = data
            .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else {
        checklistItems = [];
      }
    } else {
      checklistItems = [];
    }
    update();
  }

  Future<void> addChecklistItem(String taskId, String description) async {
    if (description.trim().isEmpty) return;
    final response =
        await taskRepo.addChecklistItem(taskId, description.trim());
    if (response.status) {
      await loadChecklist(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> deleteChecklistItem(String taskId, String itemId) async {
    final response = await taskRepo.deleteChecklistItem(itemId);
    if (response.status) {
      await loadChecklist(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> toggleChecklistItem(
      String taskId, String itemId, bool finished) async {
    final response = await taskRepo.markChecklistItemDone(itemId, finished);
    if (response.status) {
      await loadChecklist(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> updateChecklistItem(
      String taskId, String itemId, String description) async {
    if (description.trim().isEmpty) return;
    final response =
        await taskRepo.updateChecklistItem(itemId, description.trim());
    if (response.status) {
      await loadChecklist(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> reorderChecklist(
      String taskId, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    // Adjust newIndex for ReorderableListView behaviour
    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = checklistItems.removeAt(oldIndex);
    checklistItems.insert(adjustedNew, item);
    update();
    // Persist new order: send each item its new 1-based list_order
    for (int i = 0; i < checklistItems.length; i++) {
      final id = checklistItems[i]['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await taskRepo.reorderChecklistItem(id, i + 1);
      }
    }
  }

  // ── Task assignees & followers ─────────────────────────────────────────────
  List<Map<String, dynamic>> taskAssignees = [];
  List<Map<String, dynamic>> taskFollowers = [];
  bool isTeamLoading = false;
  List<StaffMember> allStaffList = [];

  Future<void> loadTaskTeam(String taskId) async {
    isTeamLoading = true;
    update();
    final assigneeRes = await taskRepo.getTaskAssignees(taskId);
    final followerRes = await taskRepo.getTaskFollowers(taskId);
    isTeamLoading = false;
    if (assigneeRes.status) {
      final decoded = jsonDecode(assigneeRes.responseJson);
      final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
      taskAssignees = raw is List
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      taskAssignees = [];
    }
    if (followerRes.status) {
      final decoded = jsonDecode(followerRes.responseJson);
      final raw = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
      taskFollowers = raw is List
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      taskFollowers = [];
    }
    update();
  }

  Future<void> addAssignee(String taskId, String staffId) async {
    final response = await taskRepo.addTaskAssignee(taskId, staffId);
    if (response.status) {
      await loadTaskTeam(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> removeAssignee(String taskId, String staffId) async {
    final response = await taskRepo.removeTaskAssignee(taskId, staffId);
    if (response.status) {
      await loadTaskTeam(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> addFollower(String taskId, String staffId) async {
    final response = await taskRepo.addTaskFollower(taskId, staffId);
    if (response.status) {
      await loadTaskTeam(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> removeFollower(String taskId, String staffId) async {
    final response = await taskRepo.removeTaskFollower(taskId, staffId);
    if (response.status) {
      await loadTaskTeam(taskId);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<List<StaffMember>> loadAllStaff() async {
    if (allStaffList.isNotEmpty) return allStaffList;
    final response = await taskRepo.apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.staffUrl}',
      Method.getMethod,
      null,
      passHeader: true,
    );
    if (response.status) {
      final model = StaffListModel.fromJson(jsonDecode(response.responseJson));
      allStaffList = model.data ?? [];
    }
    return allStaffList;
  }

  // ── Delete attachment ─────────────────────────────────────────────────────
  Future<void> deleteTaskAttachment(String taskId, String attachmentId) async {
    final response = await taskRepo.deleteTaskAttachment(taskId, attachmentId);
    if (response.status) {
      await loadTaskDetails(taskId);
      CustomSnackBar.success(successList: ['Attachment deleted']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ??
            'Failed to delete attachment'
      ]);
    }
    update();
  }

  // ── Upload attachment ─────────────────────────────────────────────────────
  bool isAttachmentUploading = false;
  Future<void> uploadTaskAttachment(String taskId) async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;
    isAttachmentUploading = true;
    update();
    final response = await taskRepo.uploadTaskAttachment(taskId, filePath);
    isAttachmentUploading = false;
    if (response.status) {
      CustomSnackBar.success(successList: ['Attachment uploaded']);
      await loadTaskDetails(taskId);
    } else {
      CustomSnackBar.error(errorList: [
        response.message.isEmpty ? 'Failed to upload' : response.message,
      ]);
    }
    update();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────
  bool isTimerRunning = false;
  bool isTimerLoading = false;

  Future<void> checkTimer(String taskId) async {
    final response = await taskRepo.getActiveTimer(taskId);
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      isTimerRunning = decoded['active'] == true;
    }
    update();
  }

  Future<void> startTimer(String taskId) async {
    isTimerLoading = true;
    update();
    final response = await taskRepo.startTimer(taskId);
    isTimerLoading = false;
    if (response.status) {
      isTimerRunning = true;
      CustomSnackBar.success(successList: ['Timer started']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to start timer'
      ]);
    }
    update();
  }

  Future<void> stopTimer(String taskId) async {
    isTimerLoading = true;
    update();
    final response = await taskRepo.stopTimer(taskId);
    isTimerLoading = false;
    if (response.status) {
      isTimerRunning = false;
      CustomSnackBar.success(successList: ['Timer stopped']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to stop timer'
      ]);
    }
    update();
  }

  // ── Timesheets ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> taskTimesheetsList = [];
  bool isTimesheetsLoading = false;

  Future<void> loadTaskTimesheets(String taskId) async {
    isTimesheetsLoading = true;
    update();
    final response = await taskRepo.getTaskTimesheets(taskId);
    isTimesheetsLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map ? (decoded['data'] ?? []) : decoded;
      taskTimesheetsList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      taskTimesheetsList = [];
    }
    update();
  }

  // ── Copy task ─────────────────────────────────────────────────────────────
  Future<void> copyTask(String taskId) async {
    isSubmitLoading = true;
    update();
    final response = await taskRepo.copyTask(taskId);
    isSubmitLoading = false;
    if (response.status) {
      await initialData();
      CustomSnackBar.success(successList: ['Task copied successfully']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to copy task'
      ]);
    }
    update();
  }

  // ── Milestones ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> projectMilestones = [];
  bool isMilestonesLoading = false;
  TextEditingController milestoneController = TextEditingController();

  Future<void> loadProjectMilestones(String projectId) async {
    if (projectId.isEmpty) return;
    isMilestonesLoading = true;
    update();
    final response = await taskRepo.getProjectMilestones(projectId);
    isMilestonesLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map ? (decoded['data'] ?? []) : decoded;
      projectMilestones = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      projectMilestones = [];
    }
    update();
  }

  // ── Manual time log ───────────────────────────────────────────────────────
  Future<void> addTimeLog(
      String taskId, String startTime, String endTime) async {
    final response = await taskRepo.addTimeLog(taskId, startTime, endTime);
    if (response.status) {
      await loadTaskTimesheets(taskId);
      CustomSnackBar.success(successList: ['Time log added']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to add time log'
      ]);
    }
    update();
  }

  Future<void> deleteTimeLog(String taskId, String entryId) async {
    final response = await taskRepo.deleteTimeLog(entryId);
    if (response.status) {
      await loadTaskTimesheets(taskId);
      CustomSnackBar.success(successList: ['Time log deleted']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ??
            'Failed to delete time log'
      ]);
    }
    update();
  }

  // ── Assign checklist item to staff ────────────────────────────────────────
  Future<void> assignChecklistItem(
      String taskId, String itemId, String? staffId) async {
    final response = await taskRepo.assignChecklistItem(itemId, staffId);
    if (response.status) {
      await loadChecklist(taskId);
      CustomSnackBar.success(successList: [
        staffId != null && staffId.isNotEmpty
            ? 'Assigned to staff'
            : 'Unassigned'
      ]);
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  // ── Task reminders ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> taskRemindersList = [];
  bool isRemindersLoading = false;

  Future<void> loadTaskReminders(String taskId) async {
    isRemindersLoading = true;
    update();
    final response = await taskRepo.getTaskReminders(taskId);
    isRemindersLoading = false;
    if (response.status) {
      final decoded = jsonDecode(response.responseJson);
      final raw = decoded is Map ? (decoded['data'] ?? []) : decoded;
      taskRemindersList = (raw is List)
          ? raw
              .whereType<Map>()
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } else {
      taskRemindersList = [];
    }
    update();
  }

  Future<void> addTaskReminder(String taskId, String date, String description,
      String notifyStaffId) async {
    final response = await taskRepo.addTaskReminder(
        taskId, date, description, notifyStaffId);
    if (response.status) {
      await loadTaskReminders(taskId);
      CustomSnackBar.success(successList: ['Reminder added']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ?? 'Failed to add reminder'
      ]);
    }
    update();
  }

  Future<void> deleteTaskReminder(String taskId, String reminderId) async {
    final response = await taskRepo.deleteTaskReminder(reminderId);
    if (response.status) {
      await loadTaskReminders(taskId);
      CustomSnackBar.success(successList: ['Reminder deleted']);
    } else {
      CustomSnackBar.error(errorList: [
        jsonDecode(response.responseJson)['message'] ??
            'Failed to delete reminder'
      ]);
    }
    update();
  }
}

import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/task/model/task_create_model.dart';

class TaskRepo {
  ApiClient apiClient;
  TaskRepo({required this.apiClient});

  Future<ResponseModel> getAllTasks() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnTasksFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/my_tasks",
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/my",
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/own",
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/assigned",
      "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/staff_tasks",
      "${UrlContainer.baseUrl}staff/tasks",
      "${UrlContainer.baseUrl}my/tasks",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?user_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?userid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?member_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?assigned=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/tasks",
      if (hasStaffId) "${UrlContainer.baseUrl}users/$encodedStaffId/tasks",
    ];

    ResponseModel lastResponse = ResponseModel(false, 'Task access denied', '');

    for (final url in candidates) {
      final response = await apiClient.request(url, Method.getMethod, null,
          passHeader: true);
      if (response.status) {
        return response;
      }
      lastResponse = response;
    }

    return lastResponse;
  }

  Future<ResponseModel> getTaskDetails(taskId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/id/$taskId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllCustomers() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllProjects() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllInvoices() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllContracts() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllEstimates() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getAllProposals() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> createTask(TaskCreateModel taskModel,
      {String? taskId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}";

    Map<String, dynamic> params = {
      "name": taskModel.subject,
      "startdate": taskModel.startDate,
      "is_public": taskModel.isPublic,
      "billable": taskModel.billable,
      "hourly_rate": taskModel.hourlyRate,
      "milestone": taskModel.milestone,
      "duedate": taskModel.dueDate,
      "priority": taskModel.priority,
      "repeat_every": '',
      "rel_type": taskModel.relType,
      "rel_id": taskModel.relId,
      "tags": taskModel.tags,
      "description": taskModel.description,
    };

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$taskId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> changeTaskStatus(String taskId, String status) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/id/$taskId/status/$status';
    return apiClient.request(url, Method.postMethod, null, passHeader: true);
  }

  Future<ResponseModel> changeTaskPriority(
      String taskId, String priority) async {
    final url = '${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/id/$taskId';
    return apiClient.request(url, Method.putMethod, {'priority': priority},
        passHeader: true);
  }

  Future<ResponseModel> deleteTask(taskId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/id/$taskId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchTask(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  // ── Task checklist ────────────────────────────────────────────────────────
  Future<ResponseModel> getChecklist(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistUrl}/$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addChecklistItem(
      String taskId, String description) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistUrl}/$taskId',
      Method.postMethod,
      {'description': description},
      passHeader: true,
    );
  }

  Future<ResponseModel> updateChecklistItem(
      String itemId, String description) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistUrl}/item/$itemId',
      Method.putMethod,
      {'description': description},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteChecklistItem(String itemId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistUrl}/item/$itemId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> markChecklistItemDone(
      String itemId, bool finished) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistUrl}/done/$itemId',
      Method.postMethod,
      {'finished': finished ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> reorderChecklistItem(
      String itemId, int listOrder) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistOrderUrl}',
      Method.putMethod,
      {'item_id': itemId, 'list_order': listOrder.toString()},
      passHeader: true,
    );
  }

  // ── Task assignees & followers ────────────────────────────────────────────
  Future<ResponseModel> getTaskAssignees(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskAssigneesUrl}/$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addTaskAssignee(String taskId, String staffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskAssigneesUrl}/$taskId',
      Method.postMethod,
      {'staffid': staffId},
      passHeader: true,
    );
  }

  Future<ResponseModel> removeTaskAssignee(
      String taskId, String staffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskAssigneesUrl}/$taskId',
      Method.deleteMethod,
      {'staffid': staffId},
      passHeader: true,
    );
  }

  Future<ResponseModel> getTaskFollowers(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskFollowersUrl}/$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addTaskFollower(String taskId, String staffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskFollowersUrl}/$taskId',
      Method.postMethod,
      {'staffid': staffId},
      passHeader: true,
    );
  }

  Future<ResponseModel> removeTaskFollower(
      String taskId, String staffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskFollowersUrl}/$taskId',
      Method.deleteMethod,
      {'staffid': staffId},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteTaskAttachment(
      String taskId, String attachmentId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskAttachmentDeleteUrl}?id=$taskId&attachment_id=$attachmentId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> uploadTaskAttachment(
      String taskId, String filePath) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.taskAttachmentDeleteUrl}?id=$taskId';
    return apiClient.multipartRequest(url, filePath, {}, passHeader: true);
  }

  Future<ResponseModel> getActiveTimer(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimerUrl}?id=$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> startTimer(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimerUrl}?id=$taskId',
      Method.postMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> stopTimer(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimerUrl}?id=$taskId',
      Method.putMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> getTaskTimesheets(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimesheetsUrl}?id=$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> copyTask(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskCopyUrl}?id=$taskId',
      Method.postMethod,
      null,
      passHeader: true,
    );
  }

  // ── Milestones for a project ──────────────────────────────────────────────
  Future<ResponseModel> getProjectMilestones(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskMilestonesUrl}?project_id=$projectId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  // ── Manual time log ───────────────────────────────────────────────────────
  Future<ResponseModel> addTimeLog(
      String taskId, String startTime, String endTime) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimelogUrl}?id=$taskId',
      Method.postMethod,
      {'start_time': startTime, 'end_time': endTime},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteTimeLog(String entryId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskTimelogUrl}?entry_id=$entryId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  // ── Assign checklist item to staff ────────────────────────────────────────
  Future<ResponseModel> assignChecklistItem(
      String itemId, String? staffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskChecklistAssignUrl}?item_id=$itemId',
      Method.putMethod,
      {'staffid': staffId ?? ''},
      passHeader: true,
    );
  }

  // ── Task reminders ────────────────────────────────────────────────────────
  Future<ResponseModel> getTaskReminders(String taskId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskRemindersUrl}?id=$taskId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addTaskReminder(String taskId, String date,
      String description, String notifyStaffId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskReminderUrl}?id=$taskId',
      Method.postMethod,
      {
        'date': date,
        'description': description,
        'notify_staff': notifyStaffId,
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteTaskReminder(String reminderId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.taskReminderUrl}?reminder_id=$reminderId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }
}

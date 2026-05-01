import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/project/model/project_post_model.dart';

class ProjectRepo {
  ApiClient apiClient;
  ProjectRepo({required this.apiClient});

  Future<ResponseModel> getAllProjects() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getOwnProjectsFallback({String? staffId}) async {
    final encodedStaffId = Uri.encodeComponent(staffId ?? '');
    final hasStaffId = (staffId ?? '').trim().isNotEmpty;
    final candidates = <String>[
      "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/mine",
      "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/my",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}?staffid=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}?staff_id=$encodedStaffId",
      if (hasStaffId)
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/staff/$encodedStaffId",
      if (hasStaffId) "${UrlContainer.baseUrl}staff/$encodedStaffId/projects",
    ];

    ResponseModel lastResponse =
        ResponseModel(false, 'Project access denied', '');
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

  Future<ResponseModel> getProjectDetails(projectId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/id/$projectId";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getProjectGroup(projectId, group) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/id/$projectId/group/$group";
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

  Future<ResponseModel> createProject(ProjectPostModel projectModel,
      {String? projectId, bool isUpdate = false}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}";

    Map<String, dynamic> params = {
      "name": projectModel.name,
      "clientid": projectModel.clientId,
      "billing_type": projectModel.billingType,
      "start_date": projectModel.startDate,
      "status": projectModel.status,
      "progress_from_tasks": projectModel.progressFromTasks,
      "project_cost": projectModel.projectCost,
      "progress": projectModel.progress,
      "project_rate_per_hour": projectModel.projectRatePerHour,
      "estimated_hours": projectModel.estimatedHours,
      "project_members": projectModel.projectMembers,
      "deadline": projectModel.deadline,
      "tags": projectModel.tags,
      "description": projectModel.description,
    };

    // Strip empty/null optional fields to avoid 500 on update — Perfex's
    // projects_model->update treats empty `project_members` as an array and
    // crashes; empty deadline/tags/estimated_hours overwrite valid values.
    const alwaysSendKeys = {
      'name',
      'clientid',
      'billing_type',
      'start_date',
      'status',
      'progress_from_tasks',
      'progress',
      'description',
    };
    params.removeWhere((k, v) =>
        !alwaysSendKeys.contains(k) &&
        (v == null || (v is String && v.trim().isEmpty)));

    ResponseModel responseModel = await apiClient.request(
        isUpdate ? '$url/id/$projectId' : url,
        isUpdate ? Method.putMethod : Method.postMethod,
        params,
        passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> deleteProject(projectId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/id/$projectId";
    ResponseModel responseModel = await apiClient
        .request(url, Method.deleteMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> searchProject(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/search/$keysearch";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> addProjectMember(
      String projectId, String staffId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/id/$projectId/member';
    return apiClient.request(url, Method.postMethod, {'staffid': staffId},
        passHeader: true);
  }

  Future<ResponseModel> removeProjectMember(
      String projectId, String staffId) async {
    final url =
        '${UrlContainer.baseUrl}${UrlContainer.projectsUrl}/id/$projectId/member/$staffId';
    return apiClient.request(url, Method.deleteMethod, null, passHeader: true);
  }

  // ── Milestones ──────────────────────────────────────────────────────────────

  Future<ResponseModel> addMilestone(String projectId, String name,
      {String? description, String? color, String? dueDate}) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectMilestoneUrl}',
      Method.postMethod,
      {
        'project_id': projectId,
        'name': name,
        'description': description ?? '',
        'color': color ?? '#6c757d',
        'due_date': dueDate ?? '',
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> editMilestone(String milestoneId, String name,
      {String? description, String? color, String? dueDate}) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectMilestoneUrl}?milestone_id=$milestoneId',
      Method.putMethod,
      {
        'name': name,
        'description': description ?? '',
        'color': color ?? '',
        'due_date': dueDate ?? '',
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteMilestone(String milestoneId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectMilestoneUrl}?milestone_id=$milestoneId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  // ── Project Notes ───────────────────────────────────────────────────────────

  Future<ResponseModel> getProjectNotes(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectNotesUrl}?project_id=$projectId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addProjectNote(String projectId, String content) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectNoteUrl}',
      Method.postMethod,
      {'project_id': projectId, 'content': content},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteProjectNote(String noteId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectNoteUrl}?note_id=$noteId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  // ── Discussions ─────────────────────────────────────────────────────────────

  Future<ResponseModel> addDiscussion(String projectId, String subject,
      String content, bool visibleToClient) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionUrl}',
      Method.postMethod,
      {
        'project_id': projectId,
        'subject': subject,
        'content': content,
        'show_to_customer': visibleToClient ? '1' : '0',
      },
      passHeader: true,
    );
  }

  Future<ResponseModel> updateDiscussionVisibility(
      String discussionId, bool visibleToClient) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionUrl}?discussion_id=$discussionId',
      Method.putMethod,
      {'show_to_customer': visibleToClient ? '1' : '0'},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteDiscussion(String discussionId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionUrl}?discussion_id=$discussionId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> addDiscussionComment(
      String discussionId, String content) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionCommentUrl}',
      Method.postMethod,
      {'discussion_id': discussionId, 'content': content},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteDiscussionComment(String commentId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionCommentUrl}?comment_id=$commentId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  // ── Copy & Status ───────────────────────────────────────────────────────────

  Future<ResponseModel> copyProject(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectCopyUrl}',
      Method.postMethod,
      {'project_id': projectId},
      passHeader: true,
    );
  }

  Future<ResponseModel> updateProjectStatus(
      String projectId, String status) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectStatusUrl}?project_id=$projectId&status=$status',
      Method.putMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> getProjectActivity(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectActivityUrl}?project_id=$projectId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> massStopTimers(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectTimersStopUrl}',
      Method.postMethod,
      {'project_id': projectId},
      passHeader: true,
    );
  }

  Future<ResponseModel> uploadDiscussionAttachment(
      String discussionId, String filePath) async {
    return apiClient.multipartRequest(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionAttachmentUrl}?discussion_id=$discussionId',
      filePath,
      {},
      passHeader: true,
    );
  }

  Future<ResponseModel> uploadProjectFile(
      String projectId, String filePath) async {
    return apiClient.multipartRequest(
      '${UrlContainer.baseUrl}${UrlContainer.projectFileUrl}?project_id=$projectId',
      filePath,
      {'project_id': projectId},
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteProjectFile(String fileId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectFileUrl}?file_id=$fileId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> deleteDiscussionAttachment(String attachmentId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionAttachmentUrl}?attachment_id=$attachmentId',
      Method.deleteMethod,
      null,
      passHeader: true,
    );
  }

  Future<ResponseModel> updateTaskMilestone(
      String taskId, String? milestoneId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectTaskMilestoneUrl}',
      Method.putMethod,
      {'task_id': taskId, 'milestone_id': milestoneId ?? ''},
      passHeader: true,
    );
  }

  Future<ResponseModel> getDiscussionsWithAttachments(String projectId) async {
    return apiClient.request(
      '${UrlContainer.baseUrl}${UrlContainer.projectDiscussionsWithAttachmentsUrl}?project_id=$projectId',
      Method.getMethod,
      null,
      passHeader: true,
    );
  }
}

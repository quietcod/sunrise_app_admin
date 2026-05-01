import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/project/model/project_details_model.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutex_admin/features/project/model/project_post_model.dart';
import 'package:flutex_admin/features/project/model/milestones_model.dart';
import 'package:flutex_admin/features/project/model/timesheet_model.dart';
import 'package:flutex_admin/features/project/model/project_files_model.dart';
import 'package:flutex_admin/features/project/model/project_expenses_model.dart';
import 'package:flutex_admin/features/project/repo/project_repo.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/task/model/tasks_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class ProjectController extends GetxController {
  ProjectRepo projectRepo;
  ProjectController({required this.projectRepo});

  bool isLoading = true;
  bool submitLoading = false;

  bool projectOverviewEnable = true;
  bool projectTasksEnable = true;
  bool projectInvoicesEnable = true;
  bool projectEstimatesEnable = true;
  bool projectProposalsEnable = true;
  bool projectDiscussionsEnable = true;
  bool projectTimesheetsEnable = true;
  bool projectMilestonesEnable = true;
  bool projectFilesEnable = true;
  bool projectExpensesEnable = true;
  //bool projectGantt = false;
  //bool projectTickets = false;
  //bool projectContracts = false;
  //bool projectSubscriptions = false;
  //bool projectCreditNotes = false;
  //bool projectNotes = false;
  //bool projectActivity = false;

  bool createTaskEnable = true;
  bool editTaskEnable = true;
  ProjectsModel projectsModel = ProjectsModel();
  ProjectDetailsModel projectDetailsModel = ProjectDetailsModel();
  TasksModel tasksModel = TasksModel();
  InvoicesModel invoicesModel = InvoicesModel();
  EstimatesModel estimatesModel = EstimatesModel();
  ProposalsModel proposalsModel = ProposalsModel();
  CustomersModel customersModel = CustomersModel();
  TimesheetsModel timesheetsModel = TimesheetsModel();
  MilestonesModel milestonesModel = MilestonesModel();
  ProjectFilesModel projectFilesModel = ProjectFilesModel();
  ProjectExpensesModel projectExpensesModel = ProjectExpensesModel();

  final Map<String, String> billingType = {
    '1': LocalStrings.fixedRate.tr,
    '2': LocalStrings.projectHours.tr,
    '3': LocalStrings.taskHours.tr,
  };

  final Map<String, String> projectStatus = {
    '1': LocalStrings.notStarted.tr,
    '2': LocalStrings.inProgress.tr,
    '3': LocalStrings.onHold.tr,
    '4': LocalStrings.finished.tr,
    '5': LocalStrings.cancelled.tr,
  };

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();

    _loadPinnedProjects();
    await loadProjects();
    isLoading = false;
    update();
  }

  // ── Pinned Projects (local-only persistence) ───────────────────────────────
  static const String _pinnedKey = 'pinned_project_ids';
  Set<String> pinnedProjectIds = <String>{};

  void _loadPinnedProjects() {
    final ids =
        projectRepo.apiClient.sharedPreferences.getStringList(_pinnedKey) ??
            const <String>[];
    pinnedProjectIds = ids.toSet();
  }

  bool isProjectPinned(String? projectId) {
    if (projectId == null) return false;
    return pinnedProjectIds.contains(projectId);
  }

  Future<void> togglePinProject(String projectId) async {
    if (pinnedProjectIds.contains(projectId)) {
      pinnedProjectIds.remove(projectId);
      CustomSnackBar.success(successList: ['Project unpinned']);
    } else {
      pinnedProjectIds.add(projectId);
      CustomSnackBar.success(successList: ['Project pinned to top']);
    }
    await projectRepo.apiClient.sharedPreferences
        .setStringList(_pinnedKey, pinnedProjectIds.toList());
    _applyPinnedSort();
    update();
  }

  void _applyPinnedSort() {
    final list = projectsModel.data ?? [];
    list.sort((a, b) {
      final aPinned = pinnedProjectIds.contains(a.id) ? 0 : 1;
      final bPinned = pinnedProjectIds.contains(b.id) ? 0 : 1;
      return aPinned.compareTo(bPinned);
    });
  }

  // ── Export Project Data ────────────────────────────────────────────────────
  Future<void> exportProjectData(String projectId) async {
    try {
      // Pull all the relevant groups so we have a complete snapshot.
      await Future.wait([
        loadProjectDetails(projectId),
        loadProjectGroup(projectId, 'tasks'),
        loadProjectGroup(projectId, 'milestones'),
        loadProjectGroup(projectId, 'invoices'),
        loadProjectGroup(projectId, 'estimates'),
        loadProjectGroup(projectId, 'proposals'),
        loadProjectGroup(projectId, 'expenses'),
        loadProjectGroup(projectId, 'timesheets'),
        loadProjectGroup(projectId, 'files'),
      ]);

      final data = {
        'export_version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'project': projectDetailsModel.data?.toJson(),
        'tasks': (tasksModel.data ?? []).map((t) => t.toJson()).toList(),
        'milestones': (milestonesModel.data ?? [])
            .map((m) => {
                  'id': m.id,
                  'name': m.name,
                  'due_date': m.dueDate,
                  'description': m.description,
                  'color': m.color,
                  'milestone_order': m.milestoneOrder,
                })
            .toList(),
        'invoices': (invoicesModel.data ?? []).map((i) => i.toJson()).toList(),
        'estimates':
            (estimatesModel.data ?? []).map((e) => e.toJson()).toList(),
        'proposals':
            (proposalsModel.data ?? []).map((p) => p.toJson()).toList(),
        'expenses_count': (projectExpensesModel.data ?? []).length,
        'timesheets_count': (timesheetsModel.data ?? []).length,
        'files_count': (projectFilesModel.data ?? []).length,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/project_${projectId}_export_$ts.json');
      await file.writeAsString(jsonString);

      await Clipboard.setData(ClipboardData(text: jsonString));
      CustomSnackBar.success(successList: [
        'Project exported. JSON copied to clipboard.\nFile: ${file.path}'
      ]);
    } catch (e) {
      CustomSnackBar.error(errorList: ['Export failed: $e']);
    }
  }

  bool isAccessDenied = false;

  Future<void> loadProjects() async {
    ResponseModel responseModel = await projectRepo.getAllProjects();
    if (responseModel.status) {
      isAccessDenied = false;
      projectsModel =
          ProjectsModel.fromJson(jsonDecode(responseModel.responseJson));
      _allProjects = List.from(projectsModel.data ?? []);
      selectedStatus = null;
      _applyPinnedSort();
    } else if (responseModel.isForbidden) {
      // Staff with "view own" permission — try fallback endpoints.
      // The flutex_admin_api may not expose a filtered endpoint, so if all
      // fallbacks also fail with 403/404 we stay on the screen with an empty
      // list instead of navigating away.
      final staffId = projectRepo.apiClient.sharedPreferences
              .getString(SharedPreferenceHelper.userIdKey) ??
          '';
      final fallback =
          await projectRepo.getOwnProjectsFallback(staffId: staffId);
      if (fallback.status) {
        isAccessDenied = false;
        projectsModel =
            ProjectsModel.fromJson(jsonDecode(fallback.responseJson));
        _allProjects = List.from(projectsModel.data ?? []);
        selectedStatus = null;
        _applyPinnedSort();
      } else {
        // No working endpoint found — show empty list on screen.
        isAccessDenied = true;
        projectsModel = ProjectsModel();
        _allProjects = [];
      }
    } else {
      isAccessDenied = false;
      projectsModel = ProjectsModel();
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<void> loadProjectDetails(projectId) async {
    try {
      ResponseModel responseModel =
          await projectRepo.getProjectDetails(projectId);
      if (responseModel.status) {
        try {
          projectDetailsModel = ProjectDetailsModel.fromJson(
              jsonDecode(responseModel.responseJson));
        } catch (e) {
          CustomSnackBar.error(
              errorList: ['Failed to parse project details: $e']);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Failed to load project: $e']);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadProjectGroup(projectId, group) async {
    try {
      ResponseModel responseModel =
          await projectRepo.getProjectGroup(projectId, group);
      if (responseModel.status && responseModel.responseJson.isNotEmpty) {
        try {
          _assignGroupModel(group, responseModel.responseJson);
        } catch (e) {
          CustomSnackBar.error(errorList: ['Failed to parse $group: $e']);
        }
      } else if (!responseModel.status) {
        CustomSnackBar.error(errorList: [responseModel.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Failed to load $group: $e']);
    } finally {
      isLoading = false;
      update();
    }
  }

  void _assignGroupModel(String group, String responseJson) {
    switch (group) {
      case 'tasks':
        tasksModel = TasksModel.fromJson(jsonDecode(responseJson));
        break;
      case 'invoices':
        invoicesModel = InvoicesModel.fromJson(jsonDecode(responseJson));
        break;
      case 'estimates':
        estimatesModel = EstimatesModel.fromJson(jsonDecode(responseJson));
        break;
      case 'proposals':
        proposalsModel = ProposalsModel.fromJson(jsonDecode(responseJson));
        break;
      case 'discussions':
        projectDetailsModel =
            ProjectDetailsModel.fromJson(jsonDecode(responseJson));
        break;
      case 'timesheets':
        timesheetsModel = TimesheetsModel.fromJson(jsonDecode(responseJson));
        break;
      case 'milestones':
        milestonesModel = MilestonesModel.fromJson(jsonDecode(responseJson));
        break;
      case 'files':
        projectFilesModel =
            ProjectFilesModel.fromJson(jsonDecode(responseJson));
        break;
      case 'expenses':
        projectExpensesModel =
            ProjectExpensesModel.fromJson(jsonDecode(responseJson));
        break;
    }
  }

  Future<CustomersModel> loadCustomers() async {
    ResponseModel responseModel = await projectRepo.getAllCustomers();
    return customersModel =
        CustomersModel.fromJson(jsonDecode(responseModel.responseJson));
  }

  Future<void> loadProjectUpdateData(projectId) async {
    ResponseModel responseModel =
        await projectRepo.getProjectDetails(projectId);
    if (responseModel.status) {
      projectDetailsModel =
          ProjectDetailsModel.fromJson(jsonDecode(responseModel.responseJson));
      nameController.text = projectDetailsModel.data?.name ?? '';
      clientController.text = projectDetailsModel.data?.clientId ?? '';
      billingTypeController.text = projectDetailsModel.data?.billingType ?? '';
      startDateController.text = projectDetailsModel.data?.startDate ?? '';
      statusController.text = projectDetailsModel.data?.status ?? '';
      progressFromTasksController.text =
          projectDetailsModel.data?.progressFromTasks ?? '';
      projectCostController.text = projectDetailsModel.data?.projectCost ?? '';
      progressController.text = projectDetailsModel.data?.progress ?? '';
      projectRatePerHourController.text =
          projectDetailsModel.data?.projectRatePerHour ?? '';
      estimatedHoursController.text =
          projectDetailsModel.data?.estimatedHours ?? '';
      deadlineController.text = projectDetailsModel.data?.deadline ?? '';
      descriptionController.text = projectDetailsModel.data?.description ?? '';
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController billingTypeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController progressFromTasksController = TextEditingController();
  TextEditingController projectCostController = TextEditingController();
  TextEditingController progressController = TextEditingController();
  TextEditingController projectRatePerHourController = TextEditingController();
  TextEditingController estimatedHoursController = TextEditingController();
  TextEditingController projectMembersController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode clientIdFocusNode = FocusNode();
  FocusNode billingTypeFocusNode = FocusNode();
  FocusNode startDateFocusNode = FocusNode();
  FocusNode statusFocusNode = FocusNode();
  FocusNode progressFromTasksFocusNode = FocusNode();
  FocusNode projectCostFocusNode = FocusNode();
  FocusNode progressFocusNode = FocusNode();
  FocusNode projectRatePerHourFocusNode = FocusNode();
  FocusNode estimatedHoursFocusNode = FocusNode();
  FocusNode projectMembersFocusNode = FocusNode();
  FocusNode deadlineFocusNode = FocusNode();
  FocusNode tagsFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  Future<void> submitProject({String? projectId, bool isUpdate = false}) async {
    String name = nameController.text.toString();
    String clientId = clientController.text.toString();
    String billingType = billingTypeController.text.toString();
    String startDate = startDateController.text.toString();
    String status = statusController.text.toString();
    String progressFromTasks = progressFromTasksController.text.toString();
    String projectCost = projectCostController.text.toString();
    String progress = progressController.text.toString();
    String projectRatePerHour = projectRatePerHourController.text.toString();
    String estimatedHours = estimatedHoursController.text.toString();
    String projectMembers = projectMembersController.text.toString();
    String deadline = deadlineController.text.toString();
    String tags = tagsController.text.toString();
    String description = descriptionController.text.toString();

    if (name.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterSubject.tr]);
      return;
    }
    if (billingType.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.billingType.tr]);
      return;
    }
    if (clientId.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.customer.tr]);
      return;
    }

    submitLoading = true;
    update();

    ProjectPostModel projectModel = ProjectPostModel(
      name: name,
      clientId: clientId,
      billingType: billingType,
      startDate: startDate,
      status: status,
      progressFromTasks: progressFromTasks,
      projectCost: projectCost,
      progress: progress,
      projectRatePerHour: projectRatePerHour,
      estimatedHours: estimatedHours,
      projectMembers: projectMembers,
      deadline: deadline,
      tags: tags,
      description: description,
    );

    ResponseModel responseModel = await projectRepo.createProject(projectModel,
        projectId: projectId, isUpdate: isUpdate);
    if (responseModel.status) {
      Get.back();
      if (isUpdate) await loadProjectDetails(projectId);
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
      return;
    }

    submitLoading = false;
    update();
  }

  // Delete Project
  Future<void> deleteProject(projectId) async {
    ResponseModel responseModel = await projectRepo.deleteProject(projectId);

    submitLoading = true;
    update();

    if (responseModel.status) {
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [(responseModel.message.tr)]);
    }

    submitLoading = false;
    update();
  }

  // Search Projects
  List<Project> _allProjects = [];
  String? selectedStatus;

  void filterByStatus(String? statusLabel) {
    selectedStatus = statusLabel;
    final List<Project> filtered;
    if (statusLabel == null) {
      filtered = _allProjects;
    } else {
      // DataField.status is a label like "Not Started"; Project.status is "1"
      const labelToCode = {
        'Not Started': '1',
        'In Progress': '2',
        'On Hold': '3',
        'Finished': '4',
        'Cancelled': '5',
      };
      final code = labelToCode[statusLabel];
      filtered = code == null
          ? _allProjects
          : _allProjects.where((p) => p.status == code).toList();
    }
    projectsModel = ProjectsModel(
      status: projectsModel.status,
      message: projectsModel.message,
      overview: projectsModel.overview,
      data: filtered,
    );
    update();
  }

  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchProject() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await projectRepo.searchProject(keysearch);
    if (responseModel.status) {
      projectsModel =
          ProjectsModel.fromJson(jsonDecode(responseModel.responseJson));
      _allProjects = List.from(projectsModel.data ?? []);
      selectedStatus = null;
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
    submitLoading = false;
    nameController.text = '';
    clientController.text = '';
    billingTypeController.text = '';
    startDateController.text = '';
    statusController.text = '';
    progressFromTasksController.text = '';
    projectCostController.text = '';
    progressController.text = '';
    projectRatePerHourController.text = '';
    estimatedHoursController.text = '';
    projectMembersController.text = '';
    deadlineController.text = '';
    tagsController.text = '';
    descriptionController.text = '';
  }

  // ── Project members ────────────────────────────────────────────────────────
  List<StaffMember> allStaffCache = [];

  Future<List<StaffMember>> loadAllStaff() async {
    if (allStaffCache.isNotEmpty) return allStaffCache;
    final url = '${UrlContainer.baseUrl}${UrlContainer.staffUrl}';
    final res =
        await projectRepo.apiClient.request(url, 'GET', null, passHeader: true);
    if (res.status) {
      try {
        final model = StaffListModel.fromJson(jsonDecode(res.responseJson));
        allStaffCache = model.data ?? [];
      } catch (_) {
        allStaffCache = [];
      }
    }
    return allStaffCache;
  }

  Future<void> addProjectMember(
      String projectId, String staffId, VoidCallback onDone) async {
    final res = await projectRepo.addProjectMember(projectId, staffId);
    if (res.status) {
      await loadProjectDetails(projectId);
      onDone();
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> removeProjectMember(String projectId, String staffId) async {
    final res = await projectRepo.removeProjectMember(projectId, staffId);
    if (res.status) {
      await loadProjectDetails(projectId);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  // ── Milestones CRUD ─────────────────────────────────────────────────────────

  Future<void> addMilestone(String projectId, String name,
      {String? description, String? color, String? dueDate}) async {
    final res = await projectRepo.addMilestone(projectId, name,
        description: description, color: color, dueDate: dueDate);
    if (res.status) {
      await loadProjectGroup(projectId, 'milestones');
      CustomSnackBar.success(successList: ['Milestone added']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> editMilestone(String projectId, String milestoneId, String name,
      {String? description, String? color, String? dueDate}) async {
    final res = await projectRepo.editMilestone(milestoneId, name,
        description: description, color: color, dueDate: dueDate);
    if (res.status) {
      await loadProjectGroup(projectId, 'milestones');
      CustomSnackBar.success(successList: ['Milestone updated']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> deleteMilestone(String projectId, String milestoneId) async {
    final res = await projectRepo.deleteMilestone(milestoneId);
    if (res.status) {
      await loadProjectGroup(projectId, 'milestones');
      CustomSnackBar.success(successList: ['Milestone deleted']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  // ── Project Notes ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> projectNotesList = [];
  bool isNotesLoading = false;

  Future<void> loadProjectNotes(String projectId) async {
    isNotesLoading = true;
    update();
    final res = await projectRepo.getProjectNotes(projectId);
    if (res.status) {
      try {
        final decoded = jsonDecode(res.responseJson);
        final raw = decoded['data'];
        projectNotesList = raw is List
            ? raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
      } catch (_) {
        projectNotesList = [];
      }
    } else {
      projectNotesList = [];
    }
    isNotesLoading = false;
    update();
  }

  Future<void> addProjectNote(String projectId, String content) async {
    final res = await projectRepo.addProjectNote(projectId, content);
    if (res.status) {
      await loadProjectNotes(projectId);
      CustomSnackBar.success(successList: ['Note added']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> deleteProjectNote(String projectId, String noteId) async {
    final res = await projectRepo.deleteProjectNote(noteId);
    if (res.status) {
      await loadProjectNotes(projectId);
      CustomSnackBar.success(successList: ['Note deleted']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  // ── Discussions ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> projectDiscussionsList = [];
  bool isDiscussionsLoading = false;

  // ── Activity log ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> projectActivityList = [];
  bool isActivityLoading = false;

  List<Map<String, dynamic>> _extractDiscussions(String responseJson) {
    bool isDiscussionObject(Map<String, dynamic> value) {
      return value.containsKey('id') ||
          value.containsKey('subject') ||
          value.containsKey('description') ||
          value.containsKey('datecreated');
    }

    List<Map<String, dynamic>> fromDynamic(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      if (raw is Map<String, dynamic>) {
        if (isDiscussionObject(raw)) {
          return [Map<String, dynamic>.from(raw)];
        }

        final nested = raw['data'] ?? raw['discussions'] ?? raw['results'];
        if (nested != null) {
          return fromDynamic(nested);
        }

        return raw.values
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    }

    try {
      final decoded = jsonDecode(responseJson);
      return fromDynamic(decoded);
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _mergeDiscussions(
      List<Map<String, dynamic>> primary,
      List<Map<String, dynamic>> secondary) {
    final merged = <String, Map<String, dynamic>>{};

    void upsert(Map<String, dynamic> item, int index) {
      final key = item['id']?.toString() ??
          '${item['subject']?.toString() ?? 'discussion'}_$index';
      if (!merged.containsKey(key)) {
        merged[key] = Map<String, dynamic>.from(item);
        return;
      }

      final existing = merged[key]!;
      final next = {...existing, ...item};

      if ((existing['comments'] is List &&
              (existing['comments'] as List).isNotEmpty) &&
          (item['comments'] is! List || (item['comments'] as List).isEmpty)) {
        next['comments'] = existing['comments'];
      }

      if ((existing['attachments'] is List &&
              (existing['attachments'] as List).isNotEmpty) &&
          (item['attachments'] is! List ||
              (item['attachments'] as List).isEmpty)) {
        next['attachments'] = existing['attachments'];
      }

      merged[key] = next;
    }

    for (var i = 0; i < primary.length; i++) {
      upsert(primary[i], i);
    }
    for (var i = 0; i < secondary.length; i++) {
      upsert(secondary[i], i + primary.length);
    }

    return merged.values.toList();
  }

  Future<void> loadDiscussions(String projectId) async {
    isDiscussionsLoading = true;
    update();

    final resWithAttachments =
        await projectRepo.getDiscussionsWithAttachments(projectId);
    final resGroup =
        await projectRepo.getProjectGroup(projectId, 'discussions');

    if (kDebugMode) {
      debugPrint(
          '==DISC== withAttachments status=${resWithAttachments.status} body=${resWithAttachments.responseJson}');
      debugPrint(
          '==DISC== group       status=${resGroup.status}          body=${resGroup.responseJson}');
    }

    final listWithAttachments =
        _extractDiscussions(resWithAttachments.responseJson);
    final listFromGroup = _extractDiscussions(resGroup.responseJson);

    if (kDebugMode) {
      debugPrint(
          '==DISC== extracted withAttachments=${listWithAttachments.length} group=${listFromGroup.length}');
    }

    if (listWithAttachments.isNotEmpty || listFromGroup.isNotEmpty) {
      // Group discussions often carry comments while the dedicated endpoint
      // carries attachments, so merge both views.
      projectDiscussionsList =
          _mergeDiscussions(listFromGroup, listWithAttachments);
    } else {
      projectDiscussionsList = [];
    }

    isDiscussionsLoading = false;
    update();
  }

  Future<void> addDiscussion(String projectId, String subject, String content,
      bool visibleToClient) async {
    if (kDebugMode) {
      debugPrint(
          '==DISC== POST discussion projectId=$projectId subject=$subject visibleToClient=$visibleToClient');
    }
    final res = await projectRepo.addDiscussion(
        projectId, subject, content, visibleToClient);
    if (kDebugMode) {
      debugPrint(
          '==DISC== POST response status=${res.status} body=${res.responseJson}');
    }
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Discussion added']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> toggleDiscussionVisibility(
      String projectId, String discussionId, bool visibleToClient) async {
    final res = await projectRepo.updateDiscussionVisibility(
        discussionId, visibleToClient);
    if (res.status) {
      await loadDiscussions(projectId);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> deleteDiscussion(String projectId, String discussionId) async {
    final res = await projectRepo.deleteDiscussion(discussionId);
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Discussion deleted']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> addDiscussionComment(
      String projectId, String discussionId, String content) async {
    final res = await projectRepo.addDiscussionComment(discussionId, content);
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Comment added']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  Future<void> deleteDiscussionComment(
      String projectId, String commentId) async {
    final res = await projectRepo.deleteDiscussionComment(commentId);
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Comment deleted']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
  }

  // ── Copy & Status ───────────────────────────────────────────────────────────

  Future<void> copyProject(String projectId) async {
    submitLoading = true;
    update();
    final res = await projectRepo.copyProject(projectId);
    if (res.status) {
      await initialData();
      CustomSnackBar.success(successList: ['Project copied successfully']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }

  Future<void> updateProjectStatus(String projectId, String status) async {
    submitLoading = true;
    update();
    final res = await projectRepo.updateProjectStatus(projectId, status);
    if (res.status) {
      await loadProjectDetails(projectId);
      CustomSnackBar.success(successList: ['Status updated']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }

  // ── Activity log ─────────────────────────────────────────────────────────────

  Future<void> loadProjectActivity(String projectId) async {
    isActivityLoading = true;
    update();
    final res = await projectRepo.getProjectActivity(projectId);
    if (res.status) {
      try {
        final decoded = jsonDecode(res.responseJson);
        final raw =
            decoded is List ? decoded : (decoded['data'] as List? ?? []);
        projectActivityList = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } catch (_) {
        projectActivityList = [];
      }
    } else {
      projectActivityList = [];
    }
    isActivityLoading = false;
    update();
  }

  // ── Mass stop timers ──────────────────────────────────────────────────────────

  Future<void> massStopTimers(String projectId) async {
    submitLoading = true;
    update();
    final res = await projectRepo.massStopTimers(projectId);
    if (res.status) {
      CustomSnackBar.success(successList: ['All timers stopped']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }

  // ── Discussion attachments ────────────────────────────────────────────────────

  Future<void> uploadDiscussionAttachment(
      String projectId, String discussionId) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'png',
        'jpg',
        'jpeg',
        'gif',
        'zip',
        'txt'
      ],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;

    submitLoading = true;
    update();
    final res =
        await projectRepo.uploadDiscussionAttachment(discussionId, filePath);
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Attachment uploaded']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }

  Future<void> deleteDiscussionAttachment(
      String projectId, String attachmentId) async {
    submitLoading = true;
    update();
    final res = await projectRepo.deleteDiscussionAttachment(attachmentId);
    if (res.status) {
      await loadDiscussions(projectId);
      CustomSnackBar.success(successList: ['Attachment deleted']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }

  // ── Project files upload ─────────────────────────────────────────────────────

  Future<void> uploadProjectFile(String projectId) async {
    final result = await FilePicker.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;

    submitLoading = true;
    update();
    final res = await projectRepo.uploadProjectFile(projectId, filePath);
    if (res.status) {
      await loadProjectGroup(projectId, 'files');
      CustomSnackBar.success(successList: ['File uploaded']);
    } else {
      CustomSnackBar.error(errorList: [
        res.message.isEmpty ? 'Failed to upload file' : res.message,
      ]);
    }
    submitLoading = false;
    update();
  }

  Future<void> deleteProjectFile(String projectId, String fileId) async {
    submitLoading = true;
    update();
    final res = await projectRepo.deleteProjectFile(fileId);
    if (res.status) {
      await loadProjectGroup(projectId, 'files');
      CustomSnackBar.success(successList: ['File deleted']);
    } else {
      CustomSnackBar.error(errorList: [
        res.message.isEmpty ? 'Failed to delete file' : res.message,
      ]);
    }
    submitLoading = false;
    update();
  }

  // ── Task milestone update ─────────────────────────────────────────────────────

  Future<void> updateTaskMilestone(
      String projectId, String taskId, String? milestoneId) async {
    submitLoading = true;
    update();
    final res = await projectRepo.updateTaskMilestone(taskId, milestoneId);
    if (res.status) {
      await loadProjectGroup(projectId, 'milestones');
      await loadProjectGroup(projectId, 'tasks');
      CustomSnackBar.success(successList: ['Task updated']);
    } else {
      CustomSnackBar.error(errorList: [res.message]);
    }
    submitLoading = false;
    update();
  }
}

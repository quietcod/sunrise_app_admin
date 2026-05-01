import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

/// Generic backend client for cross-cutting features (reminders, activity log,
/// custom fields, attachments) that work for any rel_type/rel_id.
class GenericExtrasRepo {
  final ApiClient apiClient;
  GenericExtrasRepo({required this.apiClient});

  String _b() => UrlContainer.baseUrl;

  // ── Reminders ──────────────────────────────────────────────────────────
  Future<ResponseModel> getReminders(String relType, String relId) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericRemindersUrl}?rel_type=$relType&rel_id=$relId',
        Method.getMethod,
        null,
        passHeader: true,
      );

  Future<ResponseModel> addReminder({
    required String relType,
    required String relId,
    required String date,
    String description = '',
    String? notifyStaff,
  }) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericReminderUrl}?rel_type=$relType&rel_id=$relId',
        Method.postMethod,
        {
          'date': date,
          'description': description,
          if (notifyStaff != null && notifyStaff.isNotEmpty)
            'notify_staff': notifyStaff,
        },
        passHeader: true,
      );

  Future<ResponseModel> deleteReminder(String reminderId) => apiClient.request(
        '${_b()}${UrlContainer.genericReminderUrl}?id=$reminderId',
        Method.deleteMethod,
        null,
        passHeader: true,
      );

  // ── Activity log ───────────────────────────────────────────────────────
  Future<ResponseModel> getActivity(String relType, String relId) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericActivityUrl}?rel_type=$relType&rel_id=$relId',
        Method.getMethod,
        null,
        passHeader: true,
      );

  // ── Custom fields ──────────────────────────────────────────────────────
  Future<ResponseModel> getCustomFields(String relType, String relId) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericCustomFieldsUrl}?rel_type=$relType&rel_id=$relId',
        Method.getMethod,
        null,
        passHeader: true,
      );

  Future<ResponseModel> saveCustomFields({
    required String relType,
    required String relId,
    required Map<String, String> values, // fieldId -> value
  }) {
    final params = <String, dynamic>{};
    values.forEach((fid, val) => params['values[$fid]'] = val);
    return apiClient.request(
      '${_b()}${UrlContainer.genericCustomFieldsUrl}?rel_type=$relType&rel_id=$relId',
      Method.postMethod,
      params,
      passHeader: true,
    );
  }

  // ── Attachments ────────────────────────────────────────────────────────
  Future<ResponseModel> getAttachments(String relType, String relId) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericAttachmentsUrl}?rel_type=$relType&rel_id=$relId',
        Method.getMethod,
        null,
        passHeader: true,
      );

  Future<ResponseModel> uploadAttachment({
    required String relType,
    required String relId,
    required String filePath,
  }) =>
      apiClient.multipartRequest(
        '${_b()}${UrlContainer.genericAttachmentsUrl}?rel_type=$relType&rel_id=$relId',
        filePath,
        const {},
        passHeader: true,
      );

  Future<ResponseModel> deleteAttachment(String attachmentId) =>
      apiClient.request(
        '${_b()}${UrlContainer.genericAttachmentUrl}?id=$attachmentId',
        Method.deleteMethod,
        null,
        passHeader: true,
      );
}

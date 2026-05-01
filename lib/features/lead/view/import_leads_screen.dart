import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImportLeadsScreen extends StatefulWidget {
  const ImportLeadsScreen({super.key});

  @override
  State<ImportLeadsScreen> createState() => _ImportLeadsScreenState();
}

class _ImportLeadsScreenState extends State<ImportLeadsScreen> {
  static const _supportedFields = <String>[
    'name',
    'email',
    'phonenumber',
    'company',
    'title',
    'website',
    'address',
    'city',
    'state',
    'country',
    'lead_value',
    'description',
    'tags',
    'default_language',
    'source',
    'status',
    'assigned',
  ];

  String? _fileName;
  List<List<String>> _rows = [];
  Map<String, int> _columnMap = {};
  String _defaultStatusId = '';
  String _defaultSourceId = '';
  bool _loadingMeta = true;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<LeadController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        controller.loadLeadStatusesAdmin(),
        controller.loadLeadSourcesAdmin(),
      ]);
      if (!mounted) return;
      setState(() {
        if (controller.leadStatusesAdminList.isNotEmpty) {
          _defaultStatusId =
              controller.leadStatusesAdminList.first['id']?.toString() ?? '';
        }
        if (controller.leadSourcesAdminList.isNotEmpty) {
          _defaultSourceId =
              controller.leadSourcesAdminList.first['id']?.toString() ?? '';
        }
        _loadingMeta = false;
      });
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    String text;
    if (file.bytes != null) {
      try {
        text = utf8.decode(file.bytes!);
      } catch (_) {
        text = String.fromCharCodes(file.bytes!);
      }
    } else {
      CustomSnackBar.error(errorList: ['Could not read file content']);
      return;
    }
    final controller = Get.find<LeadController>();
    final rows = controller.parseCsv(text);
    if (rows.isEmpty) {
      CustomSnackBar.error(errorList: ['CSV file is empty']);
      return;
    }
    final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
    final auto = <String, int>{};
    for (final field in _supportedFields) {
      final aliases = _aliasesFor(field);
      for (final alias in aliases) {
        final idx = header.indexOf(alias);
        if (idx != -1) {
          auto[field] = idx;
          break;
        }
      }
    }
    setState(() {
      _fileName = file.name;
      _rows = rows;
      _columnMap = auto;
    });
  }

  List<String> _aliasesFor(String field) {
    switch (field) {
      case 'phonenumber':
        return ['phonenumber', 'phone', 'phone_number', 'mobile'];
      case 'lead_value':
        return ['lead_value', 'value'];
      case 'default_language':
        return ['default_language', 'language'];
      default:
        return [field];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Leads (CSV)')),
      body: GetBuilder<LeadController>(builder: (controller) {
        if (_loadingMeta) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.leadStatusesAdminList.isEmpty ||
            controller.leadSourcesAdminList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(Dimensions.space20),
            child: Center(
              child: Text(
                'You need at least one Lead Source and one Lead Status configured before importing.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isImporting ? null : _pickFile,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(_fileName == null
                    ? 'Choose CSV File'
                    : 'Selected: $_fileName'),
              ),
              const SizedBox(height: Dimensions.space12),
              Text(
                'CSV must include a header row. Recognized columns: ${_supportedFields.join(", ")}.',
                style: regularSmall,
              ),
              if (_rows.isNotEmpty) ...[
                const SizedBox(height: Dimensions.space20),
                Text('${_rows.length - 1} data rows detected',
                    style: semiBoldDefault),
                const SizedBox(height: Dimensions.space12),
                Text('Defaults (used when row has empty value)',
                    style: semiBoldDefault),
                const SizedBox(height: Dimensions.space8),
                _buildDefaultDropdown(
                  label: 'Default Status',
                  value: _defaultStatusId,
                  items: controller.leadStatusesAdminList,
                  onChanged: (v) => setState(() => _defaultStatusId = v ?? ''),
                ),
                const SizedBox(height: Dimensions.space10),
                _buildDefaultDropdown(
                  label: 'Default Source',
                  value: _defaultSourceId,
                  items: controller.leadSourcesAdminList,
                  onChanged: (v) => setState(() => _defaultSourceId = v ?? ''),
                ),
                const SizedBox(height: Dimensions.space20),
                Text('Column Mapping', style: semiBoldDefault),
                const SizedBox(height: Dimensions.space8),
                ..._supportedFields.map((field) => _buildColumnDropdown(field)),
                const SizedBox(height: Dimensions.space20),
                if (controller.isImporting) ...[
                  LinearProgressIndicator(
                    value: controller.importTotal == 0
                        ? null
                        : controller.importDone / controller.importTotal,
                  ),
                  const SizedBox(height: Dimensions.space8),
                  Text(
                    'Importing ${controller.importDone} / ${controller.importTotal} '
                    '(${controller.importFailed} failed)',
                    textAlign: TextAlign.center,
                  ),
                ] else
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_columnMap['name'] == null) {
                        CustomSnackBar.error(
                            errorList: ['You must map a column to "name".']);
                        return;
                      }
                      await controller.importLeadsFromCsv(
                        rows: _rows,
                        columnMap: _columnMap,
                        defaultStatusId: _defaultStatusId,
                        defaultSourceId: _defaultSourceId,
                      );
                      if (mounted) Get.back();
                    },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Start Import'),
                  ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultDropdown({
    required String label,
    required String value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e['id']?.toString() ?? '',
                child: Text(e['name']?.toString() ?? ''),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildColumnDropdown(String field) {
    final header = _rows.first.map((h) => h.trim()).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(field + (field == 'name' ? ' *' : '')),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              initialValue: _columnMap[field],
              isDense: true,
              decoration: const InputDecoration(
                  hintText: '— Not mapped —', isDense: true),
              items: [
                const DropdownMenuItem<int>(
                    value: -1, child: Text('— Not mapped —')),
                for (var i = 0; i < header.length; i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(header[i],
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
              ],
              onChanged: (v) => setState(() {
                if (v == null || v < 0) {
                  _columnMap.remove(field);
                } else {
                  _columnMap[field] = v;
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}

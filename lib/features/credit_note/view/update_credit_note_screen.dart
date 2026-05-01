import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/credit_note/controller/credit_note_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateCreditNoteScreen extends StatefulWidget {
  const UpdateCreditNoteScreen({super.key, required this.id});
  final String id;

  @override
  State<UpdateCreditNoteScreen> createState() => _UpdateCreditNoteScreenState();
}

class _UpdateCreditNoteScreenState extends State<UpdateCreditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _date = '';
  String _expiry = '';
  final _refController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CreditNoteController>();
      final note = controller.selectedCreditNote;
      if (note != null) {
        setState(() {
          _date = note.date ?? '';
          _expiry = note.expirydate ?? '';
          _refController.text = note.referenceNo ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocalStrings.updateCreditNote.tr),
      body: GetBuilder<CreditNoteController>(builder: (controller) {
        if (controller.isLoading) return const CustomLoader();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: Dimensions.space15,
              children: [
                TextFormField(
                  initialValue: _date,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _date = DateConverter.formatDate(picked));
                    }
                  },
                  decoration: InputDecoration(
                    labelText: LocalStrings.date.tr,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                TextFormField(
                  initialValue: _expiry,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_expiry) ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(
                          () => _expiry = DateConverter.formatDate(picked));
                    }
                  },
                  decoration: InputDecoration(
                    labelText: LocalStrings.expiryDate.tr,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                TextFormField(
                  controller: _refController,
                  decoration: InputDecoration(
                    labelText: LocalStrings.referenceNo.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                controller.isSubmitting
                    ? const RoundedLoadingBtn()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorResources.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            final data = {
                              if (_date.isNotEmpty) 'date': _date,
                              if (_expiry.isNotEmpty) 'expirydate': _expiry,
                              if (_refController.text.isNotEmpty)
                                'reference_no': _refController.text,
                            };
                            final ok = await controller.updateCreditNote(
                                widget.id, data);
                            if (ok) Get.back();
                          },
                          child: Text(
                            LocalStrings.updateCreditNote.tr,
                            style:
                                semiBoldDefault.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

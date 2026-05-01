import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/custom_date_form_field.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/credit_note/controller/credit_note_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCreditNoteScreen extends StatefulWidget {
  const AddCreditNoteScreen({super.key});

  @override
  State<AddCreditNoteScreen> createState() => _AddCreditNoteScreenState();
}

class _AddCreditNoteScreenState extends State<AddCreditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  String? _selectedClientId;
  String? _selectedCurrencyId;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateConverter.formatDate(DateTime.now());
    Get.find<CreditNoteController>().loadFormData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocalStrings.addCreditNote.tr),
      body: GetBuilder<CreditNoteController>(builder: (controller) {
        if (controller.isLoading) return const CustomLoader();

        final customers = controller.customers;
        final currencies = controller.currencies;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: Dimensions.space15,
              children: [
                // Client selector
                DropdownButtonFormField<String>(
                  initialValue: _selectedClientId,
                  decoration: InputDecoration(
                    labelText: LocalStrings.client.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  hint: Text(LocalStrings.selectClient.tr),
                  items: customers.map<DropdownMenuItem<String>>((c) {
                    return DropdownMenuItem<String>(
                      value:
                          c['userid']?.toString() ?? c['id']?.toString() ?? '',
                      child: Text(c['company']?.toString() ?? '',
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedClientId = v),
                  validator: (v) =>
                      v == null ? LocalStrings.pleaseSelectClient.tr : null,
                ),
                // Date
                CustomDateFormField(
                  labelText: LocalStrings.date.tr,
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      setState(() {
                        _dateController.text = DateConverter.formatDate(value);
                      });
                    }
                  },
                ),
                // Currency selector
                if (currencies.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCurrencyId,
                    decoration: InputDecoration(
                      labelText: LocalStrings.currency.tr,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: Text(LocalStrings.selectCurrency.tr),
                    items: currencies.map<DropdownMenuItem<String>>((c) {
                      return DropdownMenuItem<String>(
                        value: c['id']?.toString() ?? '',
                        child:
                            Text('${c['name'] ?? ''} (${c['symbol'] ?? ''})'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCurrencyId = v),
                  ),
                // Submit
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
                            if (_selectedClientId == null) return;
                            final data = {
                              'clientid': _selectedClientId,
                              'date': _dateController.text,
                              if (_selectedCurrencyId != null)
                                'currency': _selectedCurrencyId,
                            };
                            final ok = await controller.addCreditNote(data);
                            if (ok) Get.back();
                          },
                          child: Text(
                            LocalStrings.addCreditNote.tr,
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

import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/settings/controller/settings_controller.dart';
import 'package:flutex_admin/features/settings/repo/settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceNumberSettingsScreen extends StatefulWidget {
  const InvoiceNumberSettingsScreen({super.key});

  @override
  State<InvoiceNumberSettingsScreen> createState() =>
      _InvoiceNumberSettingsScreenState();
}

class _InvoiceNumberSettingsScreenState
    extends State<InvoiceNumberSettingsScreen> {
  late TextEditingController _prefixCtrl;
  late TextEditingController _nextNumberCtrl;

  @override
  void initState() {
    super.initState();
    _prefixCtrl = TextEditingController();
    _nextNumberCtrl = TextEditingController();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SettingsRepo(apiClient: Get.find()));
    final c = Get.put(SettingsController(settingsRepo: Get.find()));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await c.loadInvoiceNumberSettings();
      _prefixCtrl.text =
          c.invoiceNumberSettings['invoices_prefix']?.toString() ?? '';
      _nextNumberCtrl.text =
          c.invoiceNumberSettings['next_invoice_id']?.toString() ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _prefixCtrl.dispose();
    _nextNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<SettingsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Invoice Number Settings',
          bgColor: Theme.of(context).appBarTheme.backgroundColor!,
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: const EdgeInsets.all(Dimensions.space15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prefix', style: semiBoldDefault),
                    const SizedBox(height: Dimensions.space8),
                    TextField(
                      controller: _prefixCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. INV-',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                    Text('Next Invoice Number', style: semiBoldDefault),
                    const SizedBox(height: Dimensions.space8),
                    TextField(
                      controller: _nextNumberCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 1',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space8),
                    // Preview
                    GetBuilder<SettingsController>(builder: (ctrl) {
                      final prefix = _prefixCtrl.text;
                      final next = int.tryParse(_nextNumberCtrl.text) ?? 1;
                      final numberFormat = ctrl
                              .invoiceNumberSettings['invoice_number_format']
                              ?.toString() ??
                          '1';
                      final formatted = numberFormat == '1'
                          ? '$next'
                          : next.toString().padLeft(5, '0');
                      return Text(
                        'Preview: $prefix$formatted',
                        style: regularDefault.copyWith(
                            color: ColorResources.blueGreyColor),
                      );
                    }),
                    const SizedBox(height: Dimensions.space20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitLoading
                            ? null
                            : () => controller.saveInvoiceNumberSettings({
                                  'invoices_prefix': _prefixCtrl.text,
                                  'next_invoice_id': _nextNumberCtrl.text,
                                }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isSubmitLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

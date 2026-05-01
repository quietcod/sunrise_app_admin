import 'package:async/async.dart';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/custom_date_form_field.dart';
import 'package:flutex_admin/common/components/custom_drop_down_button_with_text_field.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/common/models/currencies_model.dart';
import 'package:flutex_admin/common/models/taxes_model.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/features/expense/controller/expense_controller.dart';
import 'package:flutex_admin/features/expense/model/expense_category_model.dart';
import 'package:flutex_admin/features/project/model/project_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateExpenseScreen extends StatefulWidget {
  const UpdateExpenseScreen({super.key});

  @override
  State<UpdateExpenseScreen> createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  late String expenseId;

  final AsyncMemoizer<ExpenseCategoriesModel> _categoryMemoizer =
      AsyncMemoizer();
  final AsyncMemoizer<CustomersModel> _customersMemoizer = AsyncMemoizer();
  final AsyncMemoizer<ProjectsModel> _projectsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<CurrenciesModel> _currenciesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<TaxesModel> _taxesMemoizer = AsyncMemoizer();

  @override
  void initState() {
    expenseId = Get.arguments.toString();
    final controller = Get.find<ExpenseController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadExpenseUpdateData(expenseId);
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.find<ExpenseController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocalStrings.editExpense.tr,
      ),
      body: GetBuilder<ExpenseController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const CustomLoader();
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.space15, horizontal: Dimensions.space10),
              child: Column(
                spacing: Dimensions.space15,
                children: [
                  // Expense Name
                  CustomTextField(
                    labelText: LocalStrings.expenseName.tr,
                    hintText: LocalStrings.expenseName.tr,
                    controller: controller.expenseNameController,
                    focusNode: controller.expenseNameFocusNode,
                    nextFocus: controller.amountFocusNode,
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocalStrings.enterExpenseName.tr;
                      }
                      return null;
                    },
                    onChanged: (_) {},
                  ),

                  // Amount
                  CustomTextField(
                    labelText: LocalStrings.expenseAmount.tr,
                    hintText: '0.00',
                    controller: controller.amountController,
                    focusNode: controller.amountFocusNode,
                    nextFocus: controller.referenceNoFocusNode,
                    textInputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocalStrings.enterExpenseAmount.tr;
                      }
                      return null;
                    },
                    onChanged: (_) {},
                  ),

                  // Date
                  CustomDateFormField(
                    initialValue: controller.dateController.text.isNotEmpty
                        ? DateTime.tryParse(
                            controller.dateController.text.trim())
                        : null,
                    labelText: LocalStrings.expenseDate.tr,
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        controller.dateController.text =
                            DateConverter.formatDate(value);
                      }
                    },
                  ),

                  // Category
                  FutureBuilder<ExpenseCategoriesModel>(
                    future:
                        _categoryMemoizer.runOnce(controller.loadCategories),
                    builder: (context, snap) {
                      if (snap.data?.status ?? false) {
                        return CustomDropDownTextField(
                          hintText: LocalStrings.selectExpenseCategory.tr,
                          dropDownColor: Theme.of(context).cardColor,
                          selectedValue:
                              controller.categoryController.text.isNotEmpty
                                  ? controller.categoryController.text
                                  : null,
                          onChanged: (value) {
                            controller.categoryController.text = value;
                          },
                          items: controller.categoriesModel.data!.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(
                                cat.name ?? '',
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else if (snap.data?.status == false) {
                        return CustomDropDownWithTextField(
                          selectedValue: LocalStrings.noCategoryFound.tr,
                          list: [LocalStrings.noCategoryFound.tr],
                        );
                      } else {
                        return const CustomLoader(isFullScreen: false);
                      }
                    },
                  ),

                  // Currency
                  FutureBuilder<CurrenciesModel>(
                    future:
                        _currenciesMemoizer.runOnce(controller.loadCurrencies),
                    builder: (context, snap) {
                      if (snap.data?.status ?? false) {
                        return CustomDropDownTextField(
                          hintText: LocalStrings.selectCurrency.tr,
                          dropDownColor: Theme.of(context).cardColor,
                          selectedValue:
                              controller.currencyController.text.isNotEmpty
                                  ? controller.currencyController.text
                                  : null,
                          onChanged: (value) {
                            controller.currencyController.text = value;
                          },
                          items: controller.currenciesModel.data!.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.name ?? ''} (${c.symbol ?? ''})',
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else if (snap.data?.status == false) {
                        return CustomDropDownWithTextField(
                          selectedValue: LocalStrings.noCurrencyFound.tr,
                          list: [LocalStrings.noCurrencyFound.tr],
                        );
                      } else {
                        return const CustomLoader(isFullScreen: false);
                      }
                    },
                  ),

                  // Customer (optional)
                  FutureBuilder<CustomersModel>(
                    future:
                        _customersMemoizer.runOnce(controller.loadCustomers),
                    builder: (context, snap) {
                      if (snap.data?.status ?? false) {
                        final items = <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'None',
                              style: regularDefault.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                          ...controller.customersModel.data!.map((c) {
                            return DropdownMenuItem<String?>(
                              value: c.userId,
                              child: Text(
                                c.company ?? '',
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            );
                          }),
                        ];
                        return CustomDropDownTextField(
                          hintText: LocalStrings.selectClient.tr,
                          dropDownColor: Theme.of(context).cardColor,
                          selectedValue:
                              controller.clientController.text.isNotEmpty
                                  ? controller.clientController.text
                                  : null,
                          onChanged: (value) {
                            controller.clientController.text = value ?? '';
                          },
                          items: items,
                        );
                      } else if (snap.data?.status == false) {
                        return const SizedBox.shrink();
                      } else {
                        return const CustomLoader(isFullScreen: false);
                      }
                    },
                  ),

                  // Project (optional)
                  FutureBuilder<ProjectsModel>(
                    future: _projectsMemoizer.runOnce(controller.loadProjects),
                    builder: (context, snap) {
                      if (snap.data?.status ?? false) {
                        final items = <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'None',
                              style: regularDefault.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                          ...controller.projectsModel.data!.map((p) {
                            return DropdownMenuItem<String?>(
                              value: p.id,
                              child: Text(
                                p.name ?? '',
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            );
                          }),
                        ];
                        return CustomDropDownTextField(
                          hintText: LocalStrings.selectProject.tr,
                          dropDownColor: Theme.of(context).cardColor,
                          selectedValue:
                              controller.projectController.text.isNotEmpty
                                  ? controller.projectController.text
                                  : null,
                          onChanged: (value) {
                            controller.projectController.text = value ?? '';
                          },
                          items: items,
                        );
                      } else if (snap.data?.status == false) {
                        return const SizedBox.shrink();
                      } else {
                        return const CustomLoader(isFullScreen: false);
                      }
                    },
                  ),

                  // Tax
                  FutureBuilder<TaxesModel>(
                    future: _taxesMemoizer.runOnce(controller.loadTaxes),
                    builder: (context, snap) {
                      if (snap.data?.status ?? false) {
                        final items = <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'None',
                              style: regularDefault.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                          ...controller.taxesModel.data!.map((t) {
                            return DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(
                                '${t.name ?? ''} (${t.taxRate ?? ''}%)',
                                style: regularDefault.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              ),
                            );
                          }),
                        ];
                        return CustomDropDownTextField(
                          hintText: 'Tax (optional)',
                          dropDownColor: Theme.of(context).cardColor,
                          selectedValue:
                              controller.taxController.text.isNotEmpty
                                  ? controller.taxController.text
                                  : null,
                          onChanged: (value) {
                            controller.taxController.text = value ?? '';
                          },
                          items: items,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Reference No
                  CustomTextField(
                    labelText: LocalStrings.expenseReferenceNo.tr,
                    hintText: LocalStrings.expenseReferenceNo.tr,
                    controller: controller.referenceNoController,
                    focusNode: controller.referenceNoFocusNode,
                    nextFocus: controller.noteFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (_) {},
                  ),

                  // Note
                  CustomTextField(
                    labelText: LocalStrings.note.tr,
                    hintText: LocalStrings.note.tr,
                    controller: controller.noteController,
                    focusNode: controller.noteFocusNode,
                    textInputType: TextInputType.multiline,
                    maxLines: 4,
                    onChanged: (_) {},
                  ),

                  // Billable toggle
                  _BillableToggle(controller: controller),

                  // Submit button
                  controller.isSubmitLoading
                      ? const RoundedLoadingBtn()
                      : RoundedButton(
                          text: LocalStrings.updateExpense.tr,
                          press: () => controller.submitExpense(
                            expenseId: expenseId,
                            isUpdate: true,
                          ),
                          color: ColorResources.colorOrange,
                        ),

                  const SizedBox(height: Dimensions.space10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BillableToggle extends StatelessWidget {
  const _BillableToggle({required this.controller});
  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LocalStrings.billable.tr,
              style: regularDefault.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch(
            value: controller.billable,
            activeThumbColor: ColorResources.colorOrange,
            onChanged: (val) {
              controller.billable = val;
              controller.update();
            },
          ),
        ],
      ),
    );
  }
}

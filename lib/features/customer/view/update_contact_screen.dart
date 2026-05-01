import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateContactScreen extends StatefulWidget {
  const UpdateContactScreen({
    super.key,
    required this.contact,
    required this.customerId,
  });

  final Contact contact;
  final String customerId;

  @override
  State<UpdateContactScreen> createState() => _UpdateContactScreenState();
}

class _UpdateContactScreenState extends State<UpdateContactScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CustomerController>().loadContactForUpdate(widget.contact);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocalStrings.updateContact.tr),
      body: GetBuilder<CustomerController>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.space15,
                horizontal: Dimensions.space10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Info ──────────────────────────────────────
                  _SectionHeader(title: LocalStrings.contactDetails.tr),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText: LocalStrings.firstName.tr,
                    controller: controller.firstNameController,
                    focusNode: controller.firstNameFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.lastNameFocusNode,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText: LocalStrings.lastName.tr,
                    controller: controller.lastNameController,
                    focusNode: controller.lastNameFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.emailFocusNode,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText: LocalStrings.email.tr,
                    controller: controller.emailController,
                    focusNode: controller.emailFocusNode,
                    textInputType: TextInputType.emailAddress,
                    nextFocus: controller.titleFocusNode,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText: LocalStrings.title.tr,
                    controller: controller.titleController,
                    focusNode: controller.titleFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.phoneFocusNode,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText: LocalStrings.phone.tr,
                    controller: controller.phoneController,
                    focusNode: controller.phoneFocusNode,
                    textInputType: TextInputType.phone,
                    nextFocus: controller.passwordFocusNode,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Dimensions.space10),
                  CustomTextField(
                    labelText:
                        '${LocalStrings.password.tr} (${LocalStrings.optional.tr})',
                    controller: controller.passwordController,
                    focusNode: controller.passwordFocusNode,
                    textInputType: TextInputType.visiblePassword,
                    isShowSuffixIcon: true,
                    isPassword: true,
                    onChanged: (_) {},
                  ),

                  // ── Status ──────────────────────────────────────────
                  const SizedBox(height: Dimensions.space20),
                  _SectionHeader(title: LocalStrings.status.tr),
                  SwitchListTile(
                    title: Text(LocalStrings.primaryContact.tr),
                    value: controller.contactIsPrimary,
                    onChanged: (val) {
                      controller.contactIsPrimary = val;
                      controller.update();
                    },
                  ),
                  SwitchListTile(
                    title: Text(LocalStrings.active.tr),
                    value: controller.contactIsActive,
                    onChanged: (val) {
                      controller.contactIsActive = val;
                      controller.update();
                    },
                  ),

                  // ── Email Notifications ─────────────────────────────
                  const SizedBox(height: Dimensions.space10),
                  _SectionHeader(title: LocalStrings.notification.tr),
                  _EmailToggle(
                    label: LocalStrings.invoices.tr,
                    value: controller.contactInvoiceEmails,
                    onChanged: (val) {
                      controller.contactInvoiceEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: LocalStrings.estimates.tr,
                    value: controller.contactEstimateEmails,
                    onChanged: (val) {
                      controller.contactEstimateEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: LocalStrings.creditNote.tr,
                    value: controller.contactCreditNoteEmails,
                    onChanged: (val) {
                      controller.contactCreditNoteEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: LocalStrings.contracts.tr,
                    value: controller.contactContractEmails,
                    onChanged: (val) {
                      controller.contactContractEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: '${LocalStrings.task.tr}s',
                    value: controller.contactTaskEmails,
                    onChanged: (val) {
                      controller.contactTaskEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: LocalStrings.projects.tr,
                    value: controller.contactProjectEmails,
                    onChanged: (val) {
                      controller.contactProjectEmails = val;
                      controller.update();
                    },
                  ),
                  _EmailToggle(
                    label: LocalStrings.tickets.tr,
                    value: controller.contactTicketEmails,
                    onChanged: (val) {
                      controller.contactTicketEmails = val;
                      controller.update();
                    },
                  ),

                  // ── Portal Permissions ──────────────────────────────
                  const SizedBox(height: Dimensions.space10),
                  const _SectionHeader(title: 'Portal Permissions'),
                  _PermissionCheckbox(
                    permId: 1,
                    label: LocalStrings.invoices.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),
                  _PermissionCheckbox(
                    permId: 2,
                    label: LocalStrings.estimates.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),
                  _PermissionCheckbox(
                    permId: 3,
                    label: LocalStrings.contracts.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),
                  _PermissionCheckbox(
                    permId: 4,
                    label: LocalStrings.proposals.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),
                  _PermissionCheckbox(
                    permId: 5,
                    label: LocalStrings.support.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),
                  _PermissionCheckbox(
                    permId: 6,
                    label: LocalStrings.projects.tr,
                    selected: controller.contactPermissions,
                    onChanged: (id, val) {
                      if (val) {
                        controller.contactPermissions.add(id);
                      } else {
                        controller.contactPermissions.remove(id);
                      }
                      controller.update();
                    },
                  ),

                  // ── Submit ──────────────────────────────────────────
                  const SizedBox(height: Dimensions.space25),
                  controller.isSubmitLoading
                      ? const RoundedLoadingBtn()
                      : RoundedButton(
                          text: LocalStrings.update.tr,
                          press: () {
                            controller.updateContact(
                              widget.contact.id!,
                              widget.customerId,
                            );
                          },
                        ),
                  const SizedBox(height: Dimensions.space25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Private Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.space5, horizontal: Dimensions.space5),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _EmailToggle extends StatelessWidget {
  const _EmailToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }
}

class _PermissionCheckbox extends StatelessWidget {
  const _PermissionCheckbox({
    required this.permId,
    required this.label,
    required this.selected,
    required this.onChanged,
  });
  final int permId;
  final String label;
  final List<int> selected;
  final void Function(int id, bool val) onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: selected.contains(permId),
      onChanged: (val) => onChanged(permId, val ?? false),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

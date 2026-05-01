import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/customer/controller/customer_controller.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.index,
    required this.contactModel,
    required this.customerId,
  });
  final int index;
  final ContactsModel contactModel;
  final String customerId;

  @override
  Widget build(BuildContext context) {
    final contact = contactModel.data![index];
    final bool isActive = contact.active == '1';
    final bool fileAccess = contact.fileAccess == '1';
    final contactId = contact.id ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          color: Theme.of(context).cardColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space15, vertical: Dimensions.space10),
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: ColorResources.blueGreyColor,
                    radius: 32,
                    child: CircleImageWidget(
                      imagePath: contact.profileImage ?? '',
                      isAsset: false,
                      isProfile: true,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  if (contact.profileImage != null &&
                      contact.profileImage!.isNotEmpty &&
                      !contact.profileImage!.contains('no_profile'))
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _confirmDeleteImage(context, contactId),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text('${contact.firstName} ${contact.lastName}',
                        overflow: TextOverflow.ellipsis,
                        style: regularDefault.copyWith(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.grey)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (isActive ? Colors.green : Colors.grey)
                              .withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                contact.email ?? '',
                style: regularSmall.copyWith(color: ColorResources.blueColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      fileAccess
                          ? Icons.folder_shared
                          : Icons.folder_off_outlined,
                      size: 20,
                      color: fileAccess ? Colors.blueAccent : Colors.grey,
                    ),
                    tooltip:
                        fileAccess ? 'Revoke file access' : 'Grant file access',
                    onPressed: () => Get.find<CustomerController>()
                        .toggleContactFileAccess(
                            contactId, fileAccess, customerId),
                  ),
                  IconButton(
                    icon: Icon(
                      isActive
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      size: 22,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    tooltip: isActive ? 'Deactivate' : 'Activate',
                    onPressed: () =>
                        _confirmToggleStatus(context, contactId, isActive),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () {
                      Get.toNamed(
                        RouteHelper.updateContactScreen,
                        arguments: {
                          'contact': contact,
                          'customerId': customerId,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmToggleStatus(
      BuildContext context, String contactId, bool currentlyActive) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(currentlyActive ? 'Deactivate Contact' : 'Activate Contact'),
        content: Text(currentlyActive
            ? 'Deactivate this contact? They will lose portal access.'
            : 'Activate this contact?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<CustomerController>()
                  .toggleContactStatus(contactId, currentlyActive, customerId);
            },
            child: Text(currentlyActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteImage(BuildContext context, String contactId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Profile Image'),
        content: const Text('Remove this contact\'s profile image?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<CustomerController>()
                  .deleteContactImage(contactId, customerId);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

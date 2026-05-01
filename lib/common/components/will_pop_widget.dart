import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/dialog/exit_dialog.dart';

class WillPopWidget extends StatelessWidget {
  final Widget child;
  final String nextRoute;

  const WillPopWidget({super.key, required this.child, this.nextRoute = ''});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, dynamic result) async {
          if (didPop) return;
          if (nextRoute.isEmpty) {
            showExitDialog(context);
          } else {
            Get.offAndToNamed(nextRoute);
          }
        },
        child: child);
  }
}

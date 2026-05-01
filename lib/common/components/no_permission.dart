import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoPermissionWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoPermissionWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 64,
                color: Theme.of(context).hintColor.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text(
              LocalStrings.noPermission.tr,
              textAlign: TextAlign.center,
              style: regularMediumLarge.copyWith(
                  color: Theme.of(context).hintColor),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(LocalStrings.retry.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';

class CustomBottomSheet {
  final Widget child;
  bool isNeedMargin;
  final VoidCallback? voidCallback;
  CustomBottomSheet(
      {required this.child, this.isNeedMargin = false, this.voidCallback});

  void customBottomSheet(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = isNeedMargin
        ? BorderRadius.circular(15)
        : const BorderRadius.vertical(top: Radius.circular(20));
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext ctx) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: AnimatedPadding(
                padding: MediaQuery.of(ctx).viewInsets,
                duration: const Duration(milliseconds: 50),
                curve: Curves.decelerate,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      margin: isNeedMargin
                          ? const EdgeInsets.only(
                              left: 15, right: 15, bottom: 15)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.space15,
                          vertical: Dimensions.space12),
                      width: MediaQuery.of(ctx).size.width,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.82)
                            : Colors.white.withValues(alpha: 0.90),
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFDDDDDD),
                          width: 0.8,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            )).then((value) => voidCallback);
  }
}

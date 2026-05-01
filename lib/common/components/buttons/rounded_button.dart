import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';

const Color _kOrangeBtn = ColorResources.colorOrange;
const Color _kOrangeBtnDark = Color(0xffFF6B00);

class RoundedButton extends StatelessWidget {
  final bool isColorChange;
  final String text;
  final VoidCallback press;
  final Color color;
  final Color? textColor;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;
  final bool isOutlined;
  final Widget? child;

  const RoundedButton({
    super.key,
    this.isColorChange = false,
    this.width = 1,
    this.child,
    this.cornerRadius = 30,
    required this.text,
    required this.press,
    this.isOutlined = false,
    this.horizontalPadding = 24,
    this.verticalPadding = 16,
    this.color = _kOrangeBtn,
    this.textColor = ColorResources.colorWhite,
  });

  bool get _isOrange =>
      color == _kOrangeBtn || color == ColorResources.colorOrange;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final borderRadius = BorderRadius.circular(cornerRadius);

    if (isOutlined) {
      return SizedBox(
        width: size.width * width,
        child: OutlinedButton(
          onPressed: press,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
          ),
          child: child ??
              Text(text.tr,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SizedBox(
      width: size.width * width,
      height: verticalPadding * 2 + 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: _isOrange
              ? const LinearGradient(colors: [_kOrangeBtn, _kOrangeBtnDark])
              : null,
          color: _isOrange
              ? null
              : (isColorChange
                  ? color
                  : ColorResources.getPrimaryButtonColor()),
          boxShadow: _isOrange
              ? [
                  BoxShadow(
                    color: _kOrangeBtn.withValues(alpha: 0.38),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: press,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
          ),
          child: child ??
              Text(
                text.tr,
                style: regularDefault.copyWith(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ),
      ),
    );
  }
}

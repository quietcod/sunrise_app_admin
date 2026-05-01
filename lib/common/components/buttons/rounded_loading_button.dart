import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';

const Color _kOrangeLoading = ColorResources.colorOrange;
const Color _kOrangeDarkLoading = Color(0xffFF6B00);

class RoundedLoadingBtn extends StatelessWidget {
  final Color? textColor;
  final Color? color;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;

  const RoundedLoadingBtn({
    super.key,
    this.width = 1,
    this.cornerRadius = 30,
    this.horizontalPadding = 24,
    this.verticalPadding = 16,
    this.textColor = ColorResources.colorWhite,
    this.color = _kOrangeLoading,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final borderRadius = BorderRadius.circular(cornerRadius);
    final bool isOrange =
        color == _kOrangeLoading || color == ColorResources.colorOrange;
    return SizedBox(
      width: size.width * width,
      height: verticalPadding * 2 + 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isOrange
              ? const LinearGradient(
                  colors: [_kOrangeLoading, _kOrangeDarkLoading])
              : null,
          color: isOrange ? null : color,
          boxShadow: isOrange
              ? [
                  BoxShadow(
                    color: _kOrangeLoading.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding - 3),
          ),
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: textColor, strokeWidth: 2.5)),
        ),
      ),
    );
  }
}

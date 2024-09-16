import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoCardWidget extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;

  const CupertinoCardWidget({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderOnForeground: false,
      child: Container(
        padding:  padding ?? const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color ?? CupertinoColors.white, // Màu nền trắng hoặc gần trắng
          borderRadius: BorderRadius.circular(borderRadius ?? 12.0), // Bo tròn viền mềm mại theo HIG
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.1), // Bóng mờ nhẹ
                  spreadRadius: 0,
                  blurRadius: 10, // Độ mờ bóng
                  offset: const Offset(0, 5), // Độ lệch bóng (theo chiều dọc 5px)
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}

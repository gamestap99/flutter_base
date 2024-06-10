import 'package:flutter/material.dart';

import '../constants/color.dart';
import 'loading/loading_animation_widget.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.padding,
    this.width,
    this.shape,
    this.backgroundColor,
    this.textColor,
    this.overlayColor,
    this.textStyle,
    this.loading = false,
    this.primary = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final OutlinedBorder? shape;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? overlayColor;
  final bool loading;
  final bool primary;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
                padding: WidgetStateProperty.all(padding),
                maximumSize: WidgetStateProperty.all(const Size(double.maxFinite, 52)),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return CColor.textDark3;
                  }
                  return backgroundColor ?? (primary ? CColor.primary : CColor.neutral2);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return CColor.white;
                  }
                  return textColor ?? CColor.white;
                }),
                textStyle: WidgetStateProperty.all(textStyle),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.pressed) ? (overlayColor ?? CColor.darker) : null;
                }),
                side: primary
                    ? null
                    : WidgetStateProperty.all(const BorderSide(
                        color: CColor.neutral6,
                        width: 1,
                      )),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
            child: child,
          ),
        ),
        if (loading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white54,
              ),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: CColor.secondary,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }

  factory CustomButton.small({
    Key? key,
    VoidCallback? onPressed,
    required String label,
    double? width,
    Color? backgroundColor,
    Color? textColor,
    bool primary = true,
  }) {
    return CustomButton(
      width: width,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      primary: primary,
      textColor: textColor,
      backgroundColor: backgroundColor,
      // width: width,
      child: Text(label),
    );
  }

  factory CustomButton.large({
    Key? key,
    VoidCallback? onPressed,
    required String label,
    double? width,
  }) {
    return CustomButton(
      width: width,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Text(label),
    );
  }

  factory CustomButton.fullWidth({
    Key? key,
    VoidCallback? onPressed,
    required String label,
    bool loading = false,
    OutlinedBorder? shape,
  }) {
    return CustomButton(
      loading: loading,
      width: double.infinity,
      onPressed: onPressed,
      shape: shape,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Text(label),
    );
  }

  factory CustomButton.iconSmall({
    Key? key,
    VoidCallback? onPressed,
    required Widget icon,
    Widget? label,
    double? width,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? textColor,
    bool primary = true,
  }) {
    return CustomButton(
      primary: primary,
      textColor: textColor,
      backgroundColor: backgroundColor,
      width: width,
      onPressed: onPressed,
      shape: shape ?? (label == null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)) : null),
      padding: padding ?? (label == null ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
      child: (label == null)
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 4),
                Flexible(child: label),
              ],
            ),
    );
  }

  factory CustomButton.iconLarge({
    Key? key,
    VoidCallback? onPressed,
    required Widget icon,
    Widget? label,
    double? width,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomButton(
      width: width,
      onPressed: onPressed,
      shape: shape ?? (label == null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)) : null),
      padding: padding ?? (label == null ? const EdgeInsets.all(8) : const EdgeInsets.symmetric(vertical: 10, horizontal: 24)),
      child: (label == null)
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 10),
                Flexible(child: label),
              ],
            ),
    );
  }

  factory CustomButton.iconFullWidth({
    Key? key,
    VoidCallback? onPressed,
    required Widget icon,
    Widget? label,
    double? width,
    bool loading = false,
    OutlinedBorder? shape,
  }) {
    return CustomButton(
      width: width,
      loading: loading,
      onPressed: onPressed,
      shape: label == null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)) : null,
      padding: label == null ? const EdgeInsets.all(10) : const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          if (label != null) const SizedBox(width: 10),
          if (label != null) Flexible(child: label),
        ],
      ),
    );
  }
}

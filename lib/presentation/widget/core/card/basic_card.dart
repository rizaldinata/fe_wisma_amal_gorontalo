import 'package:flutter/material.dart';

class BasicCard extends StatelessWidget {
  const BasicCard({
    super.key,
    this.child,
    this.padding,
    this.height,
    this.width,
    this.color,
    this.borderRadius,
  });
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: borderRadius ?? BorderRadius.circular(15.0),
      ),
      child: child,
    );
  }
}

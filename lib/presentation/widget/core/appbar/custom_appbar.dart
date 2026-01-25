import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.icon,
    required this.title,
    this.action,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    this.appBarHeight = 80,
  });
  final Widget icon;
  final String title;
  final Widget? action;
  final void Function()? onPressed;
  final EdgeInsetsGeometry padding;
  final double appBarHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomIconButton(
            icon: icon,
            onPressed:
                onPressed ??
                () {
                  Navigator.pop(context);
                },
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          action ?? const SizedBox.shrink(), // Placeholder for alignment
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

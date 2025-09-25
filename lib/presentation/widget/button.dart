import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicButton extends StatelessWidget {
  const BasicButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.leadIcon = const SizedBox.shrink(),
    this.trailIcon = const SizedBox.shrink(),
  });
  final String label;
  final void Function()? onPressed;
  final TextStyle style;
  final Widget leadIcon;
  final Widget trailIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: onPressed,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadIcon,
          SizedBox(width: 8),
          Text(label, style: style),
          SizedBox(width: 8),
          trailIcon,
        ],
      ),
    );
  }
}

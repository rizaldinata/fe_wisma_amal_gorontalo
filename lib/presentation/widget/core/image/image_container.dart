import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }
}

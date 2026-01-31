import 'package:flutter/material.dart';

class ImageNetwork extends StatelessWidget {
  const ImageNetwork({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl ?? '',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          color: const Color.fromRGBO(224, 224, 224, 1),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}

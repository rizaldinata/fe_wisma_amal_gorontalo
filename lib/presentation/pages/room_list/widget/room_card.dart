import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/wrapper/wrapper_tap_wrapper.dart';

class RoomCard extends StatelessWidget {
  final String imageUrl;
  final RoomStatusEnum availability;
  final String title;
  final String description;
  final String price;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const RoomCard({
    super.key,
    required this.imageUrl,
    required this.availability,
    required this.title,
    required this.description,
    required this.price,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print('Building RoomCard for $title with imageUrl: $imageUrl');
    return HoverTapWrapper(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withAlpha(70),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
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
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomChip(
                      label: availability.displayName,
                      color: availability.getColor,
                    ),

                    const SizedBox(height: 12),

                    Text(title, style: Theme.of(context).textTheme.titleMedium),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FittedBox(
                      child: Text(
                        price,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

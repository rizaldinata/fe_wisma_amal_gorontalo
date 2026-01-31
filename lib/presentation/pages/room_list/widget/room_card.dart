import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/image/image_network.dart';
import 'package:frontend/presentation/widget/core/wrapper/wrapper_tap_wrapper.dart';

class RoomCard extends StatelessWidget {
  final String? imageUrl;
  final RoomStatusEnum availability;
  final String title;
  final String description;
  final String price;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final String? roomNumber;
  final void Function() onDelete;

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
    this.roomNumber,
    required this.onDelete,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: ImageNetwork(imageUrl: imageUrl),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CustomIconButton(
                    backgroundColor: Colors.red.shade600.withAlpha(100),
                    hoverColor: Colors.red.shade600,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    onPressed: () {
                      onDelete.call();
                    },
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomChip(
                          label: availability.displayName,
                          color: availability.getColor,
                        ),
                        if (roomNumber != null && roomNumber!.isNotEmpty) ...[
                          SizedBox(width: 20),
                          Text(
                            'No. $roomNumber',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
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

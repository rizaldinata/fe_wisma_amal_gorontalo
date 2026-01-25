import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

enum CarouselType { normal, preview }

enum ImageSourceType { network, asset, file, memory }

class CarouselImage {
  final ImageSourceType type;
  final String? path;
  final Uint8List? bytes;
  final BoxFit fit;

  const CarouselImage.network(String url, {this.fit = BoxFit.cover})
    : type = ImageSourceType.network,
      path = url,
      bytes = null;

  const CarouselImage.asset(String assetPath, {this.fit = BoxFit.cover})
    : type = ImageSourceType.asset,
      path = assetPath,
      bytes = null;

  CarouselImage.file(File file, {this.fit = BoxFit.cover})
    : type = ImageSourceType.file,
      path = file.path,
      bytes = null;

  const CarouselImage.memory(Uint8List data, {this.fit = BoxFit.cover})
    : type = ImageSourceType.memory,
      path = null,
      bytes = data;
}

Widget buildCarouselImage(CarouselImage image) {
  switch (image.type) {
    case ImageSourceType.network:
      return Image.network(image.path!, fit: image.fit);

    case ImageSourceType.asset:
      return Image.asset(image.path!, fit: image.fit);

    case ImageSourceType.file:
      return Image.file(File(image.path!), fit: image.fit);

    case ImageSourceType.memory:
      return Image.memory(image.bytes!, fit: image.fit);
  }
}

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 500,
    this.maxWidth = 900,
    this.type = CarouselType.preview,
    this.equalHeight = false,
    this.onDelete,
    this.showDeleteButton = false,
  });

  final List<CarouselImage> images;
  final double height;
  final double maxWidth;
  final CarouselType type;
  final bool equalHeight;
  final bool showDeleteButton;
  final void Function(int index)? onDelete;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _controller;
  int _current = 0;
  double _viewportFraction = 0.7;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: widget.type == CarouselType.preview
          ? _viewportFraction
          : 1.0,
      initialPage: _current,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.type == CarouselType.preview) {
          double targetWidth = widget.height * 1.4;

          double maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

          double fraction = targetWidth / maxWidth;
          fraction = fraction.clamp(0.2, 0.95);

          if ((fraction - _viewportFraction).abs() > 0.05) {
            _viewportFraction = fraction;
            final oldController = _controller;
            _controller = PageController(
              viewportFraction: _viewportFraction,
              initialPage: _current,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              oldController.dispose();
              if (mounted) setState(() {});
            });
          }
        }

        return SizedBox(
          height: widget.height,
          width: constraints.maxWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _controller,
                padEnds: false,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) {
                  final isActive = index == _current;

                  return AnimatedScale(
                    scale: widget.equalHeight ? 1.0 : (isActive ? 1.0 : 0.90),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: buildCarouselImage(widget.images[index]),
                          ),
                          if (widget.showDeleteButton &&
                              widget.onDelete != null)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Transform.scale(
                                scale: 0.8,
                                child: CustomIconButton(
                                  backgroundColor: Colors.red.withAlpha(70),
                                  hoverColor: Colors.red.withAlpha(150),
                                  boxShadow: [],
                                  borderColor: Colors.red,
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => widget.onDelete!(index),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // LEFT
              Positioned(
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 36),
                    onPressed: () => _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
              ),

              // RIGHT
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 36),
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

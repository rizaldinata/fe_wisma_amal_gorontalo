import 'package:flutter/material.dart';

enum CarouselType { normal, preview }

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double maxWidth;
  final CarouselType type;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 260,
    this.maxWidth = 900,
    this.type = CarouselType.preview,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: widget.type == CarouselType.preview ? 0.7 : 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.height,
        width: widget.maxWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _controller,
              padEnds: false,

              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                final isActive = index == _current;

                return Center(
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: AnimatedScale(
                      scale: isActive ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 250),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // LEFT
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 36),
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),

            // RIGHT
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, size: 36),
                onPressed: () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

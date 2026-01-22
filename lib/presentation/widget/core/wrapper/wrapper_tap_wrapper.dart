import 'package:flutter/material.dart';

class HoverTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double hoverScale;
  final MouseCursor cursor;
  final BorderRadius? borderRadius;

  const HoverTapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.hoverScale = 1.03,
    this.cursor = SystemMouseCursors.click,
    this.borderRadius,
  });

  @override
  State<HoverTapWrapper> createState() => _HoverTapWrapperState();
}

class _HoverTapWrapperState extends State<HoverTapWrapper> {
  bool _hovered = false;

  void _onEnter(_) => setState(() => _hovered = true);
  void _onExit(_) => setState(() => _hovered = false);

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: widget.duration,
      transform: _hovered
          ? (Matrix4.identity()..scale(widget.hoverScale))
          : Matrix4.identity(),
      curve: Curves.easeOut,
      child: widget.child,
    );

    return MouseRegion(
      cursor: widget.cursor,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: widget.borderRadius != null
            ? ClipRRect(
                borderRadius: widget.borderRadius!,
                child: child,
              )
            : child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum HoverEffectType { scale, color, combine }

class HoverTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  final HoverEffectType effect;

  // scale
  final double hoverScale;

  // color
  final Color? hoverColor;
  final Color? normalColor;

  final Duration duration;
  final MouseCursor cursor;
  final BorderRadius? borderRadius;

  const HoverTapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.effect = HoverEffectType.scale,
    this.hoverScale = 1.03,
    this.hoverColor,
    this.normalColor,
    this.duration = const Duration(milliseconds: 150),
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
    assert(
      widget.effect != HoverEffectType.color &&
              widget.effect != HoverEffectType.combine ||
          widget.hoverColor != null,
      'hoverColor must be provided for color or combine effect',
    );

    final scale = (_hovered && widget.effect != HoverEffectType.color)
        ? widget.hoverScale
        : 1.0;

    final bgColor =
        (_hovered &&
            (widget.effect == HoverEffectType.color ||
                widget.effect == HoverEffectType.combine))
        ? widget.hoverColor
        : widget.normalColor;

    Widget result = AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(scale),
      color: bgColor,
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
            ? ClipRRect(borderRadius: widget.borderRadius!, child: result)
            : result,
      ),
    );
  }
}

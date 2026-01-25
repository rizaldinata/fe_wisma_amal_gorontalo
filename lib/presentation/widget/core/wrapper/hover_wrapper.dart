import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum HoverEffectType { scale, color, combine }

class HoverTapWrapper extends StatefulWidget {
  const HoverTapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.effect = HoverEffectType.combine,

    // scale
    this.hoverScale = 1.03,
    this.pressedScale = 0.97,

    // color
    this.normalColor,
    this.hoverColor,

    // decoration
    this.borderRadius,
    this.border,
    this.boxShadow,

    // behavior
    this.duration = const Duration(milliseconds: 140),
    this.cursor = SystemMouseCursors.click,
    this.enableHover = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  final HoverEffectType effect;

  // scale
  final double hoverScale;
  final double pressedScale;

  // color
  final Color? normalColor;
  final Color? hoverColor;

  // decoration
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  // behavior
  final Duration duration;
  final MouseCursor cursor;
  final bool enableHover;

  @override
  State<HoverTapWrapper> createState() => _HoverTapWrapperState();
}

class _HoverTapWrapperState extends State<HoverTapWrapper> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _onEnter(PointerEnterEvent _) {
    if (!_enabled || !widget.enableHover) return;
    setState(() => _hovered = true);
  }

  void _onExit(PointerExitEvent _) {
    if (!_enabled || !widget.enableHover) return;
    setState(() {
      _hovered = false;
      _pressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.effect == HoverEffectType.scale || widget.hoverColor != null,
      'hoverColor must be provided for color or combine effect',
    );

    // ---- SCALE ----
    double scale = 1.0;

    if (_pressed) {
      scale = widget.pressedScale;
    } else if (_hovered && widget.effect != HoverEffectType.color) {
      scale = widget.hoverScale;
    }

    // ---- COLOR ----
    final Color? backgroundColor =
        (_hovered &&
            (widget.effect == HoverEffectType.color ||
                widget.effect == HoverEffectType.combine))
        ? widget.hoverColor
        : widget.normalColor;

    Widget content = AnimatedScale(
      scale: scale,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: widget.borderRadius,
          border: widget.border,
          boxShadow: widget.boxShadow,
        ),
        child: widget.child,
      ),
    );

    return MouseRegion(
      cursor: _enabled ? widget.cursor : MouseCursor.defer,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: content,
      ),
    );
  }
}

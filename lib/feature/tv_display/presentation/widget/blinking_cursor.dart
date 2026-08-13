import 'package:flutter/material.dart';

/// Animated Blinking Cursor for Typewriter and Terminal text displays.
class BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;
  final double width;

  const BlinkingCursor({
    super.key,
    required this.color,
    required this.height,
    required this.width,
  });

  @override
  State<BlinkingCursor> createState() => BlinkingCursorState();
}

class BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.4 + _anim.value * 0.6),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6 * _anim.value),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

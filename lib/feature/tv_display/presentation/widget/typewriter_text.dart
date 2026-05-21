import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    required this.textAlign,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with TickerProviderStateMixin {
  late AnimationController _typeCtrl;
  late Animation<int> _typeAnim;
  late AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    final ms = (widget.text.length * 40).clamp(500, 2000);
    _typeCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: ms));
    _typeAnim = StepTween(begin: 0, end: widget.text.length).animate(_typeCtrl);
    _cursorCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..repeat(reverse: true);
    _typeCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _typeCtrl.dispose();
      _cursorCtrl.dispose();
      _initAnimations();
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_typeAnim, _cursorCtrl]),
      builder: (context, child) {
        final visibleString = widget.text.substring(0, _typeAnim.value);
        final showCursor = _typeAnim.isCompleted ? _cursorCtrl.value > 0.5 : true;
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: visibleString),
              TextSpan(
                text: '█',
                style: TextStyle(
                  color: showCursor ? widget.style.color : Colors.transparent,
                ),
              ),
            ],
          ),
          textAlign: widget.textAlign,
          style: widget.style,
        );
      },
    );
  }
}

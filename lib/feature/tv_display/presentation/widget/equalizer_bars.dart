import 'dart:math';
import 'package:flutter/material.dart';

/// Reusable Equalizer Bars for HUD and overlay elements in TV Signage.
class EqualizerBars extends StatefulWidget {
  final double scale;
  final Color color;

  const EqualizerBars({
    super.key,
    required this.scale,
    required this.color,
  });

  @override
  State<EqualizerBars> createState() => EqualizerBarsState();
}

class EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<double> _phases;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
    _phases = List.generate(5, (_) => _random.nextDouble() * 6.28);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16 * widget.scale,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (i) {
          final norm = (0.3 + (sin(_ctrl.value * 6.28 + _phases[i]) + 1) * 0.35)
              .clamp(0.3, 1.0);
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 1.5 * widget.scale),
            width: 3 * widget.scale,
            height: 16 * widget.scale * norm,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}

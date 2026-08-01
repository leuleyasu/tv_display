import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Reusable Floating Particle Effect for TV Idle screens, shoutouts, and now playing overlays.
class FloatingParticles extends StatefulWidget {
  final int seed;
  final Color accent;

  const FloatingParticles({
    super.key,
    required this.seed,
    required this.accent,
  });

  @override
  State<FloatingParticles> createState() => FloatingParticlesState();
}

class FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  static const double baseFontSize = 64;

  static const _musicIcons = <String>[
    '♪',
    '♫',
    '♬',
    '♩',
    '♭',
    '♯',
    '🥰',
    '😎',
  ];

  late AnimationController _ctrl;
  late List<_Particle> _particles;
  late Random _random;
  final Map<String, TextPainter> _iconPainters = {};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _respawn();
  }

  @override
  void didUpdateWidget(covariant FloatingParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accent != widget.accent) _respawn();
  }

  TextPainter _getIconPainter(String icon, Color color) {
    final key = '$icon-${color.toARGB32()}';
    return _iconPainters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: icon,
          style: TextStyle(
            fontSize: baseFontSize,
            color: color,
            fontFamily: 'serif',
            height: 1.5,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(),
    );
  }

  void _respawn() {
    _random = Random(widget.seed);
    final palette = <Color>[
      widget.accent,
      const Color(0xFFFF5C9E),
      const Color(0xFFFBBF24),
      const Color(0xFF22D3EE),
      const Color(0xFFA78BFA),
      Colors.white,
    ];
    _particles = List.generate(24, (_) {
      final icon = _musicIcons[_random.nextInt(_musicIcons.length)];
      final color = palette[_random.nextInt(palette.length)];
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.025 + _random.nextDouble() * 0.05,
        size: _pickSize(_random),
        sway: 0.01 + _random.nextDouble() * 0.02,
        phase: _random.nextDouble() * 6.28,
        rotation: (_random.nextDouble() - 0.5) * 1.0,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
        opacity: 0.3 + _random.nextDouble() * 0.45,
        color: color,
        textPainter: _getIconPainter(icon, color),
      );
    });
  }

  double _pickSize(Random rng) {
    final r = rng.nextDouble();
    if (r < 0.50) return 12.0 + rng.nextDouble() * 8.0;
    if (r < 0.85) return 22.0 + rng.nextDouble() * 10.0;
    return 36.0 + rng.nextDouble() * 8.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    for (final tp in _iconPainters.values) {
      tp.dispose();
    }
    _iconPainters.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double sway;
  final double phase;
  final double rotation;
  final double rotationSpeed;
  final double opacity;
  final Color color;
  final TextPainter textPainter;

  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.sway,
    required this.phase,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.color,
    required this.textPainter,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      double y = p.y - progress * p.speed;
      y = y - y.floor();
      final x = p.x + sin(progress * 6.28 + p.phase) * p.sway;
      final double edgeFade =
          (y < 0.05 ? y / 0.05 : (y > 0.95 ? (1 - y) / 0.05 : 1.0))
              .clamp(0.0, 1.0);
      final paintAlpha = (p.opacity * edgeFade).clamp(0.0, 1.0);
      if (paintAlpha <= 0) continue;

      final cx = x * size.width;
      final cy = y * size.height;
      final double scale = p.size / FloatingParticlesState.baseFontSize;
      final double rot = p.rotation + progress * p.rotationSpeed * 6.28;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.scale(scale);

      canvas.saveLayer(
        Rect.fromLTWH(
          -p.textPainter.width / 2,
          -p.textPainter.height / 2,
          p.textPainter.width,
          p.textPainter.height,
        ),
        Paint()
          ..colorFilter = ColorFilter.mode(
            Colors.white.withValues(alpha: paintAlpha),
            BlendMode.modulate,
          ),
      );
      canvas.translate(-p.textPainter.width / 2, -p.textPainter.height / 2);
      p.textPainter.paint(canvas, Offset.zero);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}

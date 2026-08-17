import 'dart:math';
import 'package:flutter/material.dart';

/// Reusable Floating Particle Effect for TV Idle screens, shoutouts, and now playing overlays.
class FloatingParticles extends StatefulWidget {
  final int seed;
  final Color accent;
  final String businessType;

  const FloatingParticles({
    super.key,
    required this.seed,
    required this.accent,
    this.businessType = 'nightclub',
  });

  @override
  State<FloatingParticles> createState() => FloatingParticlesState();
}

class FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_ParticleData> _particles;
  late Random _random;

  static List<String> _getIconsForBusinessType(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return const [
          '🍽️',
          '☕️',
          'ኢንጄራ',
          '🥂',
          'ምግብ ቤት',
          '🥩',
          '🍕',
          '🥗',
          'ቡና',
          'ሻይ',
          '🍣',
          '🥘',
          '🥞',
        ];
      case 'cafe':
        return const [
          '☕',
          '🥐',
          '🍩',
          '🍵',
          '🧁',
          '📖',
          '🍰',
          '🍪',
          '🧇',
          '🧋',
          '🥞',
          '🥨',
          '🫖',
        ];
      case 'gym':
        return const [
          '⚡',
          '💪',
          '🔥',
          '🏋️',
          '🏃',
          '🏆',
          '💥',
          '🥇',
          '🥊',
          '🚴',
          '👟',
          '🏊',
          '🎯',
          '💯',
          '🥤',
        ];
      case 'lounge':
        return const [
          '🍸',
          '🎷',
          '🍷',
          '✨',
          '🍹',
          '🌙',
          '🥂',
          '🎶',
          '🍾',
          '🥃',
          '💫',
          '💎',
          '🍇',
          '🍒',
          '🕯️',
        ];
      case 'nightclub':
      default:
        return const [
          '♪',
          '♫',
          '♬',
          '♩',
          '🪩',
          '🔥',
          '✨',
          '😎',
          '🎉',
          '💃',
          '🕺',
          '🔊',
          '🍾',
          '👑',
          '🥳',
          '🎆',
        ];
    }
  }

  static List<Color> _getPaletteForBusinessType(
      String type, Color primaryAccent) {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return [
          primaryAccent,
          const Color(0xFFFBBF24),
          const Color(0xFFD97706),
          const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7),
          Colors.white,
        ];
      case 'cafe':
        return [
          primaryAccent,
          const Color(0xFFD97706),
          const Color(0xFFF59E0B),
          const Color(0xFFB45309),
          Colors.white,
        ];
      case 'gym':
        return [
          primaryAccent,
          const Color(0xFF22C55E),
          const Color(0xFF3B82F6),
          const Color(0xFFFACC15),
          Colors.white,
        ];
      case 'lounge':
        return [
          primaryAccent,
          const Color(0xFFA855F7),
          const Color(0xFFEC4899),
          const Color(0xFF38BDF8),
          Colors.white,
        ];
      case 'nightclub':
      default:
        return [
          primaryAccent,
          const Color(0xFFFF5C9E),
          const Color(0xFFFBBF24),
          const Color(0xFF22D3EE),
          const Color(0xFFA78BFA),
          Colors.white,
        ];
    }
  }

  static bool _isColoredEmoji(String str) {
    if (str.isEmpty) return false;
    final runes = str.runes.toList();
    if (runes.isEmpty) return false;
    final first = runes.first;
    // Music symbols: ♪ (9834), ♫ (9835), ♬ (9836), ♩ (9833)
    if (first == 0x266A ||
        first == 0x266B ||
        first == 0x266C ||
        first == 0x2669) {
      return false;
    }
    return true;
  }

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
    if (oldWidget.accent != widget.accent ||
        oldWidget.businessType != widget.businessType) {
      _respawn();
    }
  }

  void _respawn() {
    _random = Random(widget.seed);
    final icons = _getIconsForBusinessType(widget.businessType);
    final palette =
        _getPaletteForBusinessType(widget.businessType, widget.accent);

    _particles = List.generate(28, (_) {
      final icon = icons[_random.nextInt(icons.length)];
      final color = palette[_random.nextInt(palette.length)];
      return _ParticleData(
        icon: icon,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.025 + _random.nextDouble() * 0.045,
        size: _pickSize(_random),
        sway: 0.015 + _random.nextDouble() * 0.03,
        phase: _random.nextDouble() * 6.28,
        rotation: (_random.nextDouble() - 0.5) * 0.8,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
        baseOpacity: 0.4 + _random.nextDouble() * 0.45,
        color: color,
        isColored: _isColoredEmoji(icon),
      );
    });
  }

  double _pickSize(Random rng) {
    final r = rng.nextDouble();
    if (r < 0.45) return 22.0 + rng.nextDouble() * 10.0;
    if (r < 0.80) return 34.0 + rng.nextDouble() * 12.0;
    return 48.0 + rng.nextDouble() * 16.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          if (width <= 0 || height <= 0) return const SizedBox.shrink();

          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final double progress = _ctrl.value;

              return Stack(
                clipBehavior: Clip.none,
                children: _particles.map((p) {
                  double yFrac = p.y - progress * p.speed;
                  yFrac = yFrac - yFrac.floor();
                  final double xFrac =
                      (p.x + sin(progress * 6.28 + p.phase) * p.sway)
                          .clamp(0.0, 1.0);

                  final double edgeFade = (yFrac < 0.06
                          ? yFrac / 0.06
                          : (yFrac > 0.94 ? (1.0 - yFrac) / 0.06 : 1.0))
                      .clamp(0.0, 1.0);
                  final double alpha =
                      (p.baseOpacity * edgeFade).clamp(0.0, 1.0);
                  if (alpha <= 0.01) return const SizedBox.shrink();

                  final double posX = xFrac * width - (p.size / 2);
                  final double posY = yFrac * height - (p.size / 2);
                  final double rot =
                      p.rotation + progress * p.rotationSpeed * 6.28;

                  return Positioned(
                    left: posX,
                    top: posY,
                    child: Opacity(
                      opacity: alpha,
                      child: Transform.rotate(
                        angle: rot,
                        child: Text(
                          p.icon,
                          style: TextStyle(
                            fontSize: p.size,
                            color: p.isColored ? null : p.color,
                            fontFamilyFallback: const [
                              'Noto Color Emoji',
                              'Apple Color Emoji',
                              'Segoe UI Emoji',
                              'Twemoji Mozilla',
                              'EmojiOne Color',
                              'Android Emoji',
                              'sans-serif',
                            ],
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _ParticleData {
  final String icon;
  final double x;
  final double y;
  final double speed;
  final double size;
  final double sway;
  final double phase;
  final double rotation;
  final double rotationSpeed;
  final double baseOpacity;
  final Color color;
  final bool isColored;

  const _ParticleData({
    required this.icon,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.sway,
    required this.phase,
    required this.rotation,
    required this.rotationSpeed,
    required this.baseOpacity,
    required this.color,
    required this.isColored,
  });
}

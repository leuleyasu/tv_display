import 'dart:math';
import 'package:flutter/material.dart';
import '../../../domain/models/idle_content.dart';
import 'gourmet_dish_card.dart';

/// Dynamic Floating Gourmet Dish Cards Widget that floats full GourmetDishCards
/// across the TV screen using smooth particle physics, continuous looping, and soft sways.
class FloatingGourmetCards extends StatefulWidget {
  final List<IdleSlide> items;
  final double scale;
  final String fallbackCurrency;
  final int seed;
  final double qrWidth;
  final double qrHeight;
  final double leftMargin;
  final double rightMargin;

  const FloatingGourmetCards({
    super.key,
    required this.items,
    required this.scale,
    this.fallbackCurrency = 'ETB',
    this.seed = 101,
    this.qrWidth = 0.0,
    this.qrHeight = 0.0,
    this.leftMargin = 70.0,
    this.rightMargin = 40.0,
  });

  @override
  State<FloatingGourmetCards> createState() => _FloatingGourmetCardsState();
}

class _FloatingGourmetCardsState extends State<FloatingGourmetCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_CardParticleData> _particles;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
    _respawn();
  }

  @override
  void didUpdateWidget(covariant FloatingGourmetCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.scale != widget.scale ||
        oldWidget.fallbackCurrency != widget.fallbackCurrency ||
        oldWidget.qrWidth != widget.qrWidth ||
        oldWidget.qrHeight != widget.qrHeight ||
        oldWidget.leftMargin != widget.leftMargin) {
      _respawn();
    }
  }

  void _respawn() {
    _random = Random(widget.seed);
    if (widget.items.isEmpty) {
      _particles = [];
      return;
    }

    // Deduplicate items to ensure no duplicate GourmetDishCard instances are displayed
    final Set<String> seenKeys = <String>{};
    final List<IdleSlide> items = [];
    for (final it in widget.items) {
      final key =
          '${it.headline.trim().toLowerCase()}_${it.category?.trim().toLowerCase() ?? ''}';
      if (seenKeys.add(key)) {
        items.add(it);
      }
    }

    if (items.isEmpty) {
      _particles = [];
      return;
    }

    final int count = items.length;

    // Distribute x positions across lanes (up to 4 lanes)
    final int laneCount = count <= 4 ? max(1, count) : 4;

    _particles = List.generate(count, (idx) {
      final item = items[idx];
      final int lane = idx % laneCount;

      // Center lanes evenly across screen width (e.g. 2 lanes -> 0.25, 0.75)
      final double laneBaseX = (lane + 0.5) / laneCount;
      final double xJitter = (_random.nextDouble() - 0.5) * 0.04;
      final double initialX = (laneBaseX + xJitter).clamp(0.06, 0.94);

      // Stagger vertical positions uniformly so cards start distributed across the screen
      final double initialY = (idx + 0.5) / count;

      return _CardParticleData(
        item: item,
        x: initialX,
        y: initialY - initialY.floor(),
        speed: 0.85 + _random.nextDouble() * 0.30,
        sway: 0.006 + _random.nextDouble() * 0.008,
        phase: _random.nextDouble() * 6.28,
        rotation: (_random.nextDouble() - 0.5) * 0.025,
        baseOpacity: 0.94 + _random.nextDouble() * 0.06,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          if (width <= 0 || height <= 0) return const SizedBox.shrink();

          final double cardWidth = 350.0 * widget.scale;
          final double cardHeight = 280.0 * widget.scale;

          final double leftPad = widget.leftMargin * widget.scale;
          final double rightPad = widget.rightMargin * widget.scale;

          final double qrWidthWithMargin = widget.qrWidth;
          final double qrHeightWithMargin = widget.qrHeight;

          final double maxPosX = max(leftPad, width - rightPad - cardWidth);
          final double availableWidth = max(0.0, maxPosX - leftPad);
          final double availableHeight = max(0.0, height - cardHeight);

          // QR Code Exclusion Boundary in the bottom right corner
          final double qrLeftBound = width - qrWidthWithMargin;
          final double qrTopBound = height - qrHeightWithMargin;
          final bool hasQrZone = widget.qrWidth > 0 && widget.qrHeight > 0;

          return AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final double progress = _ctrl.value;

              return Stack(
                clipBehavior: Clip.none,
                children: _particles.map((p) {
                  // Upward continuous vertical drift with wrap-around
                  double yFrac = p.y - (progress * p.speed);
                  yFrac = yFrac - yFrac.floor();

                  // Subtle horizontal sine wave sway
                  final double xFrac =
                      (p.x + sin(progress * 6.28 + p.phase) * p.sway)
                          .clamp(0.0, 1.0);

                  // Gentle edge fade at the extreme boundaries
                  final double edgeFade = (yFrac < 0.04
                          ? yFrac / 0.04
                          : (yFrac > 0.96 ? (1.0 - yFrac) / 0.04 : 1.0))
                      .clamp(0.0, 1.0);

                  final double posX = leftPad + (xFrac * availableWidth);
                  final double posY = yFrac * availableHeight;

                  // QR Code Zone: gentle dimming if overlapping instead of vanishing
                  double qrFade = 1.0;
                  if (hasQrZone) {
                    final bool touchesQrHorizontally =
                        (posX + cardWidth > qrLeftBound);
                    final bool touchesQrVertically =
                        (posY + cardHeight > qrTopBound);

                    if (touchesQrHorizontally && touchesQrVertically) {
                      qrFade = 0.40;
                    }
                  }

                  final double alpha =
                      (p.baseOpacity * edgeFade * qrFade).clamp(0.0, 1.0);
                  if (alpha <= 0.01) return const SizedBox.shrink();

                  final double rot =
                      p.rotation + sin(progress * 6.28 + p.phase) * 0.010;

                  return Positioned(
                    left: posX,
                    top: posY,
                    child: Opacity(
                      opacity: alpha,
                      child: Transform.rotate(
                        angle: rot,
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: GourmetDishCard(
                            item: p.item,
                            scale: widget.scale,
                            fallbackCurrency: widget.fallbackCurrency,
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

class _CardParticleData {
  final IdleSlide item;
  final double x;
  final double y;
  final double speed;
  final double sway;
  final double phase;
  final double rotation;
  final double baseOpacity;

  const _CardParticleData({
    required this.item,
    required this.x,
    required this.y,
    required this.speed,
    required this.sway,
    required this.phase,
    required this.rotation,
    required this.baseOpacity,
  });
}

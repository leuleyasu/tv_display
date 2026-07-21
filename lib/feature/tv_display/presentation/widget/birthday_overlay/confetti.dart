part of 'birthday_overlay.dart';

enum _ConfettiShape { ribbon, circle }

class _ConfettiPiece {
  final double x;
  final double y;
  final double speed;
  final double burstSeed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final _ConfettiShape shape;

  const _ConfettiPiece({
    required this.x,
    required this.y,
    required this.speed,
    required this.burstSeed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final burstBoost =
          (1 - progress).clamp(0.0, 1.0) * piece.burstSeed * 0.08;
      final y = (piece.y + progress * (piece.speed + burstBoost)) % 1.0;
      final x = piece.x + sin(progress * 4 + piece.rotation) * 0.02;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(piece.rotation + progress * piece.rotationSpeed);

      final paint = Paint()..color = piece.color;

      if (piece.shape == _ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, piece.size * 0.45, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.size * 0.5,
              height: piece.size * 1.6,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

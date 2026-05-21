import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/shoutout_request.dart';

class TvDisplayScreen extends StatefulWidget {
  final String organizationId;
  const TvDisplayScreen({super.key, required this.organizationId});

  @override
  State<TvDisplayScreen> createState() => _TvDisplayScreenState();
}

class _TvDisplayScreenState extends State<TvDisplayScreen>
    with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  // ── Data ────────────────────────────────────────────────────
  List<ShoutoutRequest> _messages = [];
  int _currentIndex = 0;

  StreamSubscription? _adsSub;
  StreamSubscription? _settingsSub;

  int _durationSeconds = 7;
  int _vipBonusSeconds = 3;
  int _expireHours = 24;
  bool _isEnabled = true;
  bool _isLoading = true;

  // ── Progress ─────────────────────────────────────────────────
  Timer? _advanceTimer;
  Timer? _progressTimer;
  Timer? _clockTimer;
  double _progressValue = 1.0;
  int _remainingMs = 0;
  int _totalMs = 0;
  DateTime _now = DateTime.now();

  // ── Colors ───────────────────────────────────────────────────
  static const _bgColor = Color(0xFF070712);
  static const _purpleOrb = Color(0xFF3B1FA8);
  static const _purpleOrb2 = Color(0xFF1A0F6E);
  static const _amberOrb = Color(0xFF7A4A00);
  static const _amberOrb2 = Color(0xFF5C2D00);
  static const _purpleAccent = Color(0xFF7C5CFC);
  static const _purpleSoft = Color(0xFFA78BFA);
  static const _amberAccent = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _loadSettings();
    _loadAds();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbCtrl.dispose();
    _advanceTimer?.cancel();
    _progressTimer?.cancel();
    _clockTimer?.cancel();
    _adsSub?.cancel();
    _settingsSub?.cancel();
    super.dispose();
  }

  // ── Firebase ─────────────────────────────────────────────────
  void _loadSettings() {
    _settingsSub =
        FirebaseFirestore.instanceFor(app: Firebase.app('TV_DISPLAY'))
            .collection('organizations')
            .doc(widget.organizationId)
            .collection('settings')
            .doc('tv_display')
            .snapshots()
            .listen(
      (snap) {
        final data = snap.data() ?? {};
        setState(() {
          _durationSeconds = data['durationSeconds'] ?? 7;
          _vipBonusSeconds = data['vipBonusSeconds'] ?? 3;
          _expireHours = data['expireHours'] ?? 24;
          _isEnabled = data['isEnabled'] ?? true;
          _isLoading = false;
        });
        _restartCurrentMessage();
      },
      onError: (_) {
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _loadAds() {
    final cutoff = DateTime.now().subtract(Duration(hours: _expireHours));
    _adsSub = FirebaseFirestore.instanceFor(app: Firebase.app('TV_DISPLAY'))
        .collection('shoutout_requests')
        .where('organizationId', isEqualTo: widget.organizationId)
        .where('type', isEqualTo: 'advertisement')
        .where('status', whereIn: ['accepted', 'paid'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          final messages = snap.docs
              .map(
                (d) => ShoutoutRequest.fromMap(
                  d.data(),
                  d.id,
                ),
              )
              .where((r) => r.createdAt.isAfter(cutoff))
              .toList();

          if (!mounted) return;
          setState(() {
            _messages = messages;
            if (_currentIndex >= _messages.length) _currentIndex = 0;
            if (_messages.isNotEmpty) _showMessage(_currentIndex);
          });
        }, onError: (_) {});
  }

  // ── Message cycling ──────────────────────────────────────────
  void _showMessage(int index) {
    if (index >= _messages.length) return;
    _advanceTimer?.cancel();
    _progressTimer?.cancel();

    final isVip = _messages[index].isVip;
    final ms =
        (isVip ? _durationSeconds + _vipBonusSeconds : _durationSeconds) * 1000;
    _totalMs = ms;
    _remainingMs = ms;
    _progressValue = 1.0;

    _fadeCtrl.forward(from: 0);

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _remainingMs -= 50;
      if (_remainingMs <= 0) {
        _remainingMs = 0;
        t.cancel();
      }
      setState(() => _progressValue = _remainingMs / _totalMs);
    });

    _advanceTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      final next = (_currentIndex + 1) % _messages.length;
      if (next == 0 && _messages.length > 1) _messages.shuffle(Random());
      setState(() => _currentIndex = next);
      _showMessage(_currentIndex);
    });
  }

  void _restartCurrentMessage() {
    if (_messages.isNotEmpty) _showMessage(_currentIndex);
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _purpleAccent)),
      );
    }

    if (!_isEnabled || _messages.isEmpty) {
      return _buildEmptyState();
    }

    final msg = _messages[_currentIndex];
    final isVip = msg.isVip;

    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              // ── Ambient orbs & Grid (Parallax Layer) ───────────────
              _buildOrbs(isVip, box),
              // ── Progress strip ────────────────────────────────

              _buildProgressStrip(isVip),
              // ── Top bar ───────────────────────────────────────
              _buildTopBar(scale),
              // ── Main content (Perspective Layer) ──────────────
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) {
                      // 2.5D Perspective Transform
                      final double tilt = (1.0 - _fadeAnim.value) * 0.15;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateY(tilt) // Slight Y-axis tilt
                          ..multiply(Matrix4.translationValues(
                              0.0, tilt * 100, 0.0)), // Float up effect
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: _buildContent(msg, isVip, box, scale),
                  ),
                ),
              ),
              // ── Dots ──────────────────────────────────────────
              if (_messages.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildDots()),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Ambient orbs & Grid ──────────────────────────────────────
  Widget _buildOrbs(bool isVip, BoxConstraints box) {
    final Color c1 = isVip ? _amberOrb : _purpleOrb;
    final Color c2 = isVip ? _amberOrb2 : _purpleOrb2;
    return Stack(children: [
      // Subtle tech grid
      Positioned.fill(
        child: CustomPaint(
          painter: _TechGridPainter(
            color:
                (isVip ? _amberAccent : _purpleAccent).withValues(alpha: 0.05),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _orbAnim,
        builder: (_, __) {
          final double t = _orbAnim.value;
          return Stack(
            children: [
              // Deep Layer
              Positioned(
                top: ui.lerpDouble(-120, -20, t),
                left: ui.lerpDouble(-100, 20, t),
                child: _orb(c1, 0.25, 600, 700, 100),
              ),
              // Middle Layer
              Positioned(
                bottom: ui.lerpDouble(-150, -40, t),
                right: ui.lerpDouble(-80, 40, t),
                child: _orb(c2, 0.35, 500, 600, 80),
              ),
              // Accent Layer
              Positioned(
                top: ui.lerpDouble(
                    box.maxHeight * 0.2, box.maxHeight * 0.4, 1 - t),
                right: ui.lerpDouble(box.maxWidth * 0.1, box.maxWidth * 0.3, t),
                child: _orb(
                    isVip ? _amberAccent : _purpleAccent, 0.08, 300, 300, 120),
              ),
            ],
          );
        },
      )
    ]);
  }

  Widget _orb(Color color, double opacity, double w, double h, double blur) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ── Progress strip ────────────────────────────────────────────
  Widget _buildProgressStrip(bool isVip) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          value: _progressValue,
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          valueColor: AlwaysStoppedAnimation<Color>(
            isVip ? _amberAccent : _purpleAccent,
          ),
          minHeight: 4,
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar(double scale) {
    final TextStyle textStyle = GoogleFonts.spaceGrotesk(
      fontSize: 12 * scale,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.0,
      color: Colors.white.withValues(alpha: 0.25),
    );
    return Positioned(
      top: 30 * scale,
      left: 40 * scale,
      right: 40 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulseDot(color: _purpleAccent, size: 8 * scale),
              SizedBox(width: 12 * scale),
              Text('SYSTEM.CORE // ACTIVE', style: textStyle),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(_now),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d').format(_now).toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Center content ────────────────────────────────────────────
  Widget _buildContent(
    ShoutoutRequest msg,
    bool isVip,
    BoxConstraints box,
    double scale,
  ) {
    final double msgSize = min(box.maxWidth * 0.045, 64.0) * scale;
    final Color accentColor = isVip ? _amberAccent : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: box.maxWidth * 0.12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(isVip, scale),
          SizedBox(height: box.maxHeight * 0.05),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                accentColor,
                accentColor.withValues(alpha: 0.8),
                accentColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: AnimatedBuilder(
              animation: _orbAnim,
              builder: (context, child) {
                final double pulse = (sin(_orbAnim.value * pi * 2) * 0.1) + 1.0;
                return _TypewriterText(
                  text: '> ${msg.message}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: msgSize * (isVip ? pulse : 1.0),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                    shadows: [
                      if (isVip) ...[
                        Shadow(
                          color: _amberAccent.withValues(alpha: 0.8 * pulse),
                          blurRadius: 20 * scale * pulse,
                        ),
                        Shadow(
                          color: _amberAccent.withValues(alpha: 0.5 * pulse),
                          blurRadius: 40 * scale * pulse,
                        ),
                      ] else ...[
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: box.maxHeight * 0.05),
          _buildSenderRow(msg, isVip, scale),
        ],
      ),
    );
  }

  // ── Badge ─────────────────────────────────────────────────────
  Widget _buildBadge(bool isVip, double scale) {
    final Color accent = isVip ? _amberAccent : _purpleSoft;
    final Color bg = accent.withValues(alpha: 0.12);
    final Color border = accent.withValues(alpha: 0.3);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: accent, size: 6 * scale),
          SizedBox(width: 10 * scale),
          Text(
            isVip ? 'OVERRIDE: VIP_SHOUTOUT' : 'SYS_MSG: SHOUTOUT',
            style: GoogleFonts.spaceMono(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sender row ────────────────────────────────────────────────
  Widget _buildSenderRow(ShoutoutRequest msg, bool isVip, double scale) {
    final Color accent = isVip ? _amberAccent : _purpleSoft;
    final bool hasUser = msg.userName != null && msg.userName!.isNotEmpty;
    final String initials = hasUser
        ? msg.userName!
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasUser) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              'USR: $initials',
              style: GoogleFonts.spaceMono(
                fontSize: 10 * scale,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            '< ${msg.userName!} />',
            style: GoogleFonts.spaceMono(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              color: isVip
                  ? _amberAccent.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(width: 16 * scale),
          Container(
            width: 1,
            height: 14 * scale,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          SizedBox(width: 16 * scale),
        ],
        Text(
          '[ SYS.TIME: ${DateFormat('HH:mm:ss').format(msg.createdAt)} ]',
          style: GoogleFonts.spaceMono(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  // ── Dots ─────────────────────────────────────────────────────
  Widget _buildDots() {
    final int total = min(_messages.length, 20);
    final double step =
        _messages.length > total ? _messages.length / total : 1.0;
    final int active = (_currentIndex / step).round();
    final int count = (_messages.length / step).ceil().clamp(0, total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color:
                isActive ? _purpleAccent : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(0),
          ),
        );
      }),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tv_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 20),
            Text(
              _isEnabled ? 'No messages yet' : 'Display disabled',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Approved shoutouts will appear here',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing dot widget ────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const _PulseDot({required this.color, required this.size});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      builder: (_, __) => Opacity(
        opacity: (ui.lerpDouble(0.3, 1.0, _anim.value) ?? 0.3),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Typewriter Text ───────────────────────────────────────────
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const _TypewriterText({
    Key? key,
    required this.text,
    required this.style,
    required this.textAlign,
  }) : super(key: key);

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with TickerProviderStateMixin {
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
    _typeCtrl =
        AnimationController(vsync: this, duration: Duration(milliseconds: ms));
    _typeAnim = StepTween(begin: 0, end: widget.text.length).animate(_typeCtrl);
    _cursorCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..repeat(reverse: true);
    _typeCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
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
        final showCursor =
            _typeAnim.isCompleted ? _cursorCtrl.value > 0.5 : true;
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

// ── Tech Grid Painter ─────────────────────────────────────────
class _TechGridPainter extends CustomPainter {
  final Color color;
  _TechGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double step = 40.0;

    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) =>
      color != oldDelegate.color;
}

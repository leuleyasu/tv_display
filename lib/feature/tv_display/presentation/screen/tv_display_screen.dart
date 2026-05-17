import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/shoutout_request.dart';
import '../../../../core/theme/app_colors.dart';

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
                  d.data() as Map<String, dynamic>,
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
          final scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              // ── Ambient orbs ──────────────────────────────────
              _buildOrbs(isVip),
              // ── Progress strip ────────────────────────────────
              _buildProgressStrip(isVip),
              // ── Top bar ───────────────────────────────────────
              _buildTopBar(scale),
              // ── Main content ──────────────────────────────────
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildContent(msg, isVip, box, scale),
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

  // ── Ambient orbs ─────────────────────────────────────────────
  Widget _buildOrbs(bool isVip) {
    final c1 = isVip ? _amberOrb : _purpleOrb;
    final c2 = isVip ? _amberOrb2 : _purpleOrb2;
    return AnimatedBuilder(
      animation: _orbAnim,
      builder: (_, __) {
        final t = _orbAnim.value;
        return Stack(
          children: [
            Positioned(
              top: lerpDouble(-80, -40, t)!,
              left: lerpDouble(-60, -20, t)!,
              child: _orb(c1, 0.38, 500, 600),
            ),
            Positioned(
              bottom: lerpDouble(-100, -60, t)!,
              right: lerpDouble(-40, 0, t)!,
              child: _orb(c2, 0.45, 400, 500),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(Color color, double opacity, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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
        height: 3,
        child: LinearProgressIndicator(
          value: _progressValue,
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          valueColor: AlwaysStoppedAnimation<Color>(
            isVip ? _amberAccent : _purpleAccent,
          ),
          minHeight: 3,
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar(double scale) {
    final textStyle = GoogleFonts.spaceGrotesk(
      fontSize: 11 * scale,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
      color: Colors.white.withValues(alpha: 0.22),
    );
    return Positioned(
      top: 16,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VENUE NAME', style: textStyle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a').format(_now),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(_now),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10 * scale,
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
    final msgSize = min(box.maxWidth * 0.042, 52.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: box.maxWidth * 0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(isVip, scale),
          SizedBox(height: box.maxHeight * 0.035),
          Text(
            msg.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: msgSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.22,
            ),
          ),
          SizedBox(height: box.maxHeight * 0.035),
          _buildSenderRow(msg, isVip, scale),
        ],
      ),
    );
  }

  // ── Badge ─────────────────────────────────────────────────────
  Widget _buildBadge(bool isVip, double scale) {
    final accent = isVip ? _amberAccent : _purpleSoft;
    final bg = accent.withValues(alpha: 0.12);
    final border = accent.withValues(alpha: 0.3);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: accent, size: 5 * scale),
          SizedBox(width: 8 * scale),
          Text(
            isVip ? '★  VIP SHOUTOUT  ★' : 'SHOUTOUT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sender row ────────────────────────────────────────────────
  Widget _buildSenderRow(ShoutoutRequest msg, bool isVip, double scale) {
    final accent = isVip ? _amberAccent : _purpleSoft;
    final hasUser = msg.userName != null && msg.userName!.isNotEmpty;
    final initials = hasUser
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
            width: 30 * scale,
            height: 30 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Text(
            msg.userName!,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              color: isVip
                  ? _amberAccent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(width: 14 * scale),
          Container(
            width: 1,
            height: 12 * scale,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          SizedBox(width: 14 * scale),
        ],
        Text(
          DateFormat('MMM d, h:mm a').format(msg.createdAt),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11 * scale,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }

  // ── Dots ─────────────────────────────────────────────────────
  Widget _buildDots() {
    final total = min(_messages.length, 20);
    final step = _messages.length > total ? _messages.length / total : 1.0;
    final active = (_currentIndex / step).round();
    final count = (_messages.length / step).ceil().clamp(0, total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 7,
          height: 3,
          decoration: BoxDecoration(
            color: isActive
                ? _purpleAccent
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
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
        opacity: lerpDouble(0.3, 1.0, _anim.value)!,
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

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

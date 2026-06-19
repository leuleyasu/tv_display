import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/shoutout_request.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/repositories/tv_display_repository.dart';

class TvDisplayScreen extends StatefulWidget {
  final String organizationId;
  const TvDisplayScreen({
    super.key,
    required this.organizationId,
  });

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

  static List<ShoutoutRequest> _sampleClubMessages(String orgName) {
    final now = DateTime.now();
    final name = orgName.isEmpty ? 'CLUB' : orgName.toUpperCase();
    final msgs = [
      "✨ The board is waiting for your message.\nScan the QR code to send a shoutout, request a song, or share a message with everyone!"
    ];
    return List.generate(1, (i) {
      final time = now.subtract(Duration(minutes: 5 - i));
      return ShoutoutRequest(
        id: 'sample_$i',
        userId: 'sample_$i',
        userName: name,
        message: msgs[i],
        type: ShoutoutType.shoutout,
        status: ShoutoutStatus.accepted,
        paymentStatus: PaymentStatus.free,
        createdAt: time,
        organizationId: orgName,
        isVip: false,
        isCreditBased: false,
        deductedCredits: 0,
        price: 0,
      );
    });
  }

  late final TvDisplayRepository _repo;
  StreamSubscription? _adsSub;
  StreamSubscription? _settingsSub;
  StreamSubscription? _orgNameSub;
  StreamSubscription? _qrSub;

  SettingsModel? _settings;
  String _orgName = '';
  String? _qrCodeUrl;
  bool _isLoading = true;

  // ── Progress ─────────────────────────────────────────────────
  Timer? _advanceTimer;
  Timer? _progressTimer;
  Timer? _clockTimer;
  bool _showQrPhase = false;
  double _progressValue = 1.0;
  int _remainingMs = 0;
  int _totalMs = 0;
  DateTime _now = DateTime.now();

  // ── Colors ───────────────────────────────────────────────────
  static const _bgColor = Color(0xFF070712);
  static const _pinkOrb = Color(0xFFB8005C);
  static const _pinkOrb2 = Color(0xFF660033);
  static const _amberOrb = Color(0xFF7A4A00);
  static const _amberOrb2 = Color(0xFF5C2D00);
  static const _pinkAccent = Color(0xFFFF007A);
  static const _pinkSoft = Color(0xFFFF5C9E);
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

    _repo = TvDisplayRepository(organizationId: widget.organizationId);
    _loadOrgName();
    _loadSettings();
    _loadAds();
    _loadQrCode();
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
    _orgNameSub?.cancel();
    _qrSub?.cancel();
    super.dispose();
  }

  // ── Data streams ────────────────────────────────────────────
  bool get _isShowingSample =>
      _messages.isNotEmpty && _messages.first.id.startsWith('sample_');

  void _refreshSampleMessages() {
    if (!_isShowingSample) return;
    _messages = _sampleClubMessages(_orgName);
    _showMessage(_currentIndex.clamp(0, _messages.length - 1));
  }

  void _loadOrgName() {
    _orgNameSub = _repo.organizationNameStream().listen((name) {
      if (!mounted) return;
      setState(() {
        _orgName = name;
        if (_isShowingSample) _refreshSampleMessages();
      });
    });
  }

  void _loadSettings() {
    _settingsSub = _repo.settingsStream().listen((settings) {
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
      _restartCurrentMessage();
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _loadAds() {
    _adsSub = _repo.adsStream(expireHours: _settings?.expireHours ?? 24).listen(
      (messages) {
        if (!mounted) return;
        setState(() {
          _messages =
              messages.isEmpty ? _sampleClubMessages(_orgName) : messages;
          if (_currentIndex >= _messages.length) _currentIndex = 0;
          _showMessage(_currentIndex);
        });
      },
      onError: (_) {},
    );
  }

  void _loadQrCode() {
    _qrSub = _repo.qrCodeUrlStream().listen((url) {
      if (!mounted) return;
      setState(() => _qrCodeUrl = url);
    });
  }

  // ── Message cycling ──────────────────────────────────────────
  void _showMessage(int index) {
    if (index >= _messages.length) return;
    _advanceTimer?.cancel();
    _progressTimer?.cancel();

    setState(() => _showQrPhase = false);

    final isVip = _messages[index].isVip;
    final duration = _settings?.thoughtDisplayDuration ?? 7;
    final bonus = _settings?.vipBonusSeconds ?? 3;
    final ms = (isVip ? duration + bonus : duration) * 1000;
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
      if (next == 0) {
        if (_messages.length > 1) _messages.shuffle(Random());
        if (!_isShowingSample) {
          setState(() => _showQrPhase = true);
          _advanceTimer = Timer(const Duration(seconds: 15), () {
            if (!mounted) return;
            setState(() => _currentIndex = 0);
            _showMessage(0);
          });
          return;
        }
      }
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
        body: Center(child: CircularProgressIndicator(color: _pinkAccent)),
      );
    }

    if (_settings?.isEnabled == false) {
      return _buildEmptyState();
    }

    final msg = _messages[_currentIndex];
    final isVip = msg.isVip;

    if (_showQrPhase) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: LayoutBuilder(
          builder: (ctx, box) {
            final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
            return Stack(
              children: [
                _buildOrbs(false, box),
                _buildTopBar(scale),
                Center(
                  child: QrImageView(
                    data: _qrCodeUrl ?? '',
                    version: QrVersions.auto,
                    size: 500 * scale,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40 * scale,
                  left: 0,
                  right: 0,
                  child: Text(
                    'SCAN TO JOIN',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              _buildOrbs(isVip, box),
              _buildProgressStrip(isVip),
              _buildTopBar(scale),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) {
                      final double tilt = (1.0 - _fadeAnim.value) * 0.15;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(tilt)
                          ..multiply(
                              Matrix4.translationValues(0.0, tilt * 100, 0.0)),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: _buildContent(msg, isVip, box, scale),
                  ),
                ),
              ),
              // if (_messages.length > 1)
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
    final Color c1 = isVip ? _amberOrb : _pinkOrb;
    final Color c2 = isVip ? _amberOrb2 : _pinkOrb2;
    return Stack(children: [
      Positioned.fill(
        child: CustomPaint(
          painter: _TechGridPainter(
            color: (isVip ? _amberAccent : _pinkAccent).withValues(alpha: 0.05),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _orbAnim,
        builder: (_, __) {
          final double t = _orbAnim.value;
          return Stack(
            children: [
              Positioned(
                top: ui.lerpDouble(-120, -20, t),
                left: ui.lerpDouble(-100, 20, t),
                child: _orb(c1, 0.25, 600, 700, 100),
              ),
              Positioned(
                bottom: ui.lerpDouble(-150, -40, t),
                right: ui.lerpDouble(-80, 40, t),
                child: _orb(c2, 0.35, 500, 600, 80),
              ),
              Positioned(
                top: ui.lerpDouble(
                    box.maxHeight * 0.2, box.maxHeight * 0.4, 1 - t),
                right: ui.lerpDouble(box.maxWidth * 0.1, box.maxWidth * 0.3, t),
                child: _orb(
                    isVip ? _amberAccent : _pinkAccent, 0.08, 300, 300, 120),
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
            isVip ? _amberAccent : _pinkAccent,
          ),
          minHeight: 4,
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar(double scale) {
    final TextStyle baseStyle = GoogleFonts.spaceGrotesk(
      fontSize: 26 * scale,
      fontWeight: FontWeight.w900,
      letterSpacing: 6.0,
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
              _PulseDot(color: _pinkAccent, size: 8 * scale),
              SizedBox(width: 12 * scale),
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (context, child) {
                  final glow = _orbAnim.value * 0.5 + 0.5;
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-0.8 + _orbAnim.value * 1.6, 0.0),
                      end: Alignment(1.0, 0.0),
                      colors: [
                        _pinkAccent.withValues(alpha: 0.6),
                        Colors.white,
                        Colors.white,
                        _pinkAccent.withValues(alpha: 0.6),
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      _orgName.isNotEmpty
                          ? _orgName.toUpperCase()
                          : 'SYSTEM.CORE // ACTIVE',
                      style: baseStyle.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: _pinkAccent.withValues(alpha: glow * 0.7),
                            blurRadius: 20 * scale,
                          ),
                          Shadow(
                            color: _pinkAccent.withValues(alpha: glow * 0.3),
                            blurRadius: 40 * scale,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
    final double userNameSize = min(
            box.maxWidth * (_isShowingSample ? 0.065 : 0.025),
            _isShowingSample ? 96.0 : 32.0) *
        scale;
    final double msgSize = min(
            box.maxWidth * (_isShowingSample ? 0.035 : 0.055),
            _isShowingSample ? 48.0 : 72.0) *
        scale;
    final Color accent = isVip ? _amberAccent : _pinkAccent;
    final bool hasUser = msg.userName != null && msg.userName!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: box.maxWidth * 0.12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(isVip, scale),
          SizedBox(height: box.maxHeight * 0.06),
          if (hasUser) ...[
            AnimatedBuilder(
              animation: _orbAnim,
              builder: (context, child) {
                final double pulse =
                    (sin(_orbAnim.value * pi * 2) * 0.08) + 1.0;
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.7),
                      Colors.white,
                      accent.withValues(alpha: 0.7),
                      accent,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    msg.userName!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: userNameSize * pulse,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: accent.withValues(alpha: 0.6 * pulse),
                          blurRadius: 30 * scale * pulse,
                        ),
                        Shadow(
                          color: accent.withValues(alpha: 0.3 * pulse),
                          blurRadius: 60 * scale * pulse,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: box.maxHeight * 0.04),
          ],
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white70,
                Colors.white.withValues(alpha: 0.8),
                Colors.white70,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: AnimatedBuilder(
              animation: _orbAnim,
              builder: (context, child) {
                final displayText = msg.message.trim().isEmpty
                    ? '> DROP YOUR SHOUTOUT'
                    : '> ${msg.message}';
                return _TypewriterText(
                  text: displayText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: msgSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: 0.5,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: box.maxHeight * 0.04),
          _buildSenderMeta(msg, isVip, scale),
        ],
      ),
    );
  }

  // ── Badge ─────────────────────────────────────────────────────
  Widget _buildBadge(bool isVip, double scale) {
    final Color accent = isVip ? _amberAccent : _pinkSoft;
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

  // ── Sender meta row ────────────────────────────────────────────
  Widget _buildSenderMeta(ShoutoutRequest msg, bool isVip, double scale) {
    final Color accent = isVip ? _amberAccent : _pinkAccent;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_send_rounded,
            size: 10 * scale,
            color: accent.withValues(alpha: 0.4),
          ),
          SizedBox(width: 5 * scale),
          Text(
            DateFormat('HH:mm').format(msg.createdAt),
            style: GoogleFonts.spaceMono(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w500,
              color: accent.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
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
                isActive ? _pinkAccent : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(0),
          ),
        );
      }),
    );
  }

  // ── Empty state (display disabled) ────────────────────────────
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
              'Display disabled',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.3),
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
                text: '\u2588',
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

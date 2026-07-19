import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/models/shoutout_request.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/models/music_request.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../widget/world_cup_overlay.dart';
import '../widget/birthday_overlay/birthday_overlay.dart';
import '../widget/now_playing_screen.dart';
import '../widget/pulse_dot.dart';
import '../widget/typewriter_text.dart';
import '../widget/tech_grid_painter.dart';
import 'dart:ui' as ui;

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

  // Message card entry: drives frame draw-in + name scale + cursor
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;
  late Animation<double> _frameAnim;
  late Animation<double> _nameAnim;
  late Animation<double> _metaAnim;

  // Idle-specific continuous animations
  late AnimationController _idleBreathCtrl;
  late Animation<double> _idleBreathAnim;
  late AnimationController _idleRadarCtrl;
  late Animation<double> _idleRadarAnim;

  // VIP gold sweep that runs continuously while a VIP card is up
  late AnimationController _vipSweepCtrl;
  late Animation<double> _vipSweepAnim;

  // Scanning line that drifts across the message card
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;

  // ── Data ────────────────────────────────────────────────────
  List<ShoutoutRequest> _messages = [];
  int _currentIndex = 0;
  bool _isIdleMode = false;

  late final TvDisplayRepository _repo;
  StreamSubscription? _adsSub;
  StreamSubscription? _settingsSub;
  StreamSubscription? _orgNameSub;
  StreamSubscription? _qrSub;
  StreamSubscription? _wcSub;
  StreamSubscription? _birthdaySub;
  StreamSubscription? _birthdayWishesSub;
  StreamSubscription? _nowPlayingSub;

  MusicRequest? _nowPlaying;
  bool _showMusicPhase = false;
  Timer? _musicTimer;

  SettingsModel? _settings;
  String _orgName = '';
  String? _qrCodeUrl;
  bool _isLoading = true;
  bool _isWorldCupEnabled = false;

  // ── Progress & Timers ───────────────────────────────────────
  Timer? _advanceTimer;
  Timer? _progressTimer;
  Timer? _clockTimer;
  Timer? _idleTimer;
  Timer? _idleEnergyTimer;

  bool _showQrPhase = false;
  bool _showBirthdayPhase = false;
  bool _showBirthdayWishesPhase = false;
  List<String> _birthdayImageUrls = [];
  List<Map<String, dynamic>> _birthdayWishes = [];
  int _birthdayWishIndex = 0;
  String _birthdayName = '';
  String _birthdayWish = '';
  int _birthdayDurationSeconds = 7;
  bool _isBirthdayActive = false;

  double _progressValue = 1.0;
  int _remainingMs = 0;
  int _totalMs = 0;
  DateTime _now = DateTime.now();

  // ── Idle Mode (data) ────────────────────────────────────────
  static const List<_IdleSuggestion> _defaultSuggestions = [
    _IdleSuggestion(icon: Icons.campaign_rounded, label: 'SHOUTOUT'),
    _IdleSuggestion(icon: Icons.cake_rounded, label: 'BIRTHDAY'),
    _IdleSuggestion(icon: Icons.music_note_rounded, label: 'REQUEST A SONG'),
    _IdleSuggestion(icon: Icons.favorite_rounded, label: 'DEDICATE'),
  ];

  static const List<_IdleSlide> _defaultSlides = [
    _IdleSlide(
      emoji: '🎤',
      headline: 'SHOUT THEM OUT',
      subtitle: 'Put your crew on the big screen for everyone to see',
      suggestionIndex: 0,
    ),
    _IdleSlide(
      emoji: '🎂',
      headline: 'BIRTHDAY TAKEOVER',
      subtitle: 'Turn the whole venue into their birthday moment',
      suggestionIndex: 1,
    ),
    _IdleSlide(
      emoji: '🎵',
      headline: 'YOUR SONG. NOW.',
      subtitle: 'Queue the track that makes the whole room lose it',
      suggestionIndex: 2,
    ),
    _IdleSlide(
      emoji: '💌',
      headline: 'DROP A LOVE NOTE',
      subtitle: 'Slide into the DMs of the room — public and unforgettable',
      suggestionIndex: 3,
    ),
    _IdleSlide(
      emoji: '📸',
      headline: 'SELFIE WALL',
      subtitle: 'Snap a pic and watch yourself appear on the big screen',
      suggestionIndex: 0,
    ),
    _IdleSlide(
      emoji: '🍻',
      headline: 'CHEERS TO THE CREW',
      subtitle: 'Tag your people and make the whole room toast with you',
      suggestionIndex: 1,
    ),
  ];

  List<_IdleSuggestion> get _effectiveSuggestions {
    final labels = _settings?.idleSuggestionLabels;
    if (labels == null || labels.length < _defaultSuggestions.length) {
      return _defaultSuggestions;
    }
    return List.generate(_defaultSuggestions.length, (i) {
      return _IdleSuggestion(
        icon: _defaultSuggestions[i].icon,
        label: labels[i],
      );
    });
  }

  List<_IdleSlide> get _effectiveSlides {
    final scenes = _settings?.idleScenes;
    if (scenes == null || scenes.isEmpty) return _defaultSlides;
    final maxIdx = _effectiveSuggestions.length - 1;
    return scenes.map((s) {
      return _IdleSlide(
        emoji: s.emoji,
        headline: s.headline,
        subtitle: s.subtitle,
        suggestionIndex: s.suggestionIndex.clamp(0, maxIdx < 0 ? 0 : maxIdx),
      );
    }).toList();
  }

  int _idleSlideIndex = 0;
  double _energyLevel = 0.7;

  // ── Colors ───────────────────────────────────────────────────
  static const _bgColor = Color(0xFF070712);
  static const _pinkOrb = Color(0xFFB8005C);
  static const _pinkOrb2 = Color(0xFF660033);
  static const _amberOrb = Color(0xFF7A4A00);
  static const _amberOrb2 = Color(0xFF5C2D00);
  static const _pinkAccent = Color(0xFFFF007A);
  static const _pinkSoft = Color(0xFFFF5C9E);
  static const _amberAccent = Color(0xFFFBBF24);
  static const _cyanAccent = Color(0xFF22D3EE);
  static const _purpleAccent = Color(0xFFA78BFA);
  static const _goldAccent = Color(0xFFFFD24A);
  static const _goldDeep = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _orbCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);

    // Message card entry: 0..1 over 1100ms, eased.
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _frameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _nameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
    );
    _metaAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _idleBreathCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _idleBreathAnim =
        CurvedAnimation(parent: _idleBreathCtrl, curve: Curves.easeInOut);

    _idleRadarCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _idleRadarAnim =
        CurvedAnimation(parent: _idleRadarCtrl, curve: Curves.linear);

    _vipSweepCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _vipSweepAnim =
        CurvedAnimation(parent: _vipSweepCtrl, curve: Curves.linear);

    _scanCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.linear);

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _idleEnergyTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted || !_isIdleMode) return;
      setState(() => _energyLevel = 0.55 + Random().nextDouble() * 0.45);
    });

    _repo = TvDisplayRepository(organizationId: widget.organizationId);

    _loadOrgName();
    _loadSettings();
    _loadAds();
    _loadQrCode();
    _loadWcFlag();
    _loadBirthdaySettings();
    _loadBirthdayWishes();
    _loadNowPlaying();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbCtrl.dispose();
    _entryCtrl.dispose();
    _idleBreathCtrl.dispose();
    _idleRadarCtrl.dispose();
    _vipSweepCtrl.dispose();
    _scanCtrl.dispose();
    _advanceTimer?.cancel();
    _progressTimer?.cancel();
    _clockTimer?.cancel();
    _idleTimer?.cancel();
    _idleEnergyTimer?.cancel();
    _musicTimer?.cancel();
    _adsSub?.cancel();
    _settingsSub?.cancel();
    _orgNameSub?.cancel();
    _qrSub?.cancel();
    _wcSub?.cancel();
    _birthdaySub?.cancel();
    _birthdayWishesSub?.cancel();
    _nowPlayingSub?.cancel();
    super.dispose();
  }

  // ── Data streams ────────────────────────────────────────────
  void _loadOrgName() {
    _orgNameSub = _repo.organizationNameStream().listen((name) {
      if (!mounted) return;
      setState(() => _orgName = name);
    });
  }

  void _loadSettings() {
    _settingsSub = _repo.settingsStream().listen((settings) {
      if (!mounted) return;
      setState(() => _settings = settings);
      if (!_isIdleMode) _restartCurrentMessage();
    });
  }

  void _loadAds() {
    _adsSub = _repo.adsStream(expireHours: _settings?.expireHours ?? 24).listen(
      (messages) {
        if (!mounted) return;

        final hasRealMessages = messages.isNotEmpty &&
            !messages.any((m) => m.id.startsWith('sample_'));

        setState(() {
          _messages = messages.isEmpty ? [] : messages;
          _isIdleMode = !hasRealMessages;

          if (_isIdleMode) {
            _startIdleMode();
          } else {
            if (_currentIndex >= _messages.length) _currentIndex = 0;
            _showMessage(_currentIndex);
          }
        });
      },
    );
  }

  void _loadQrCode() {
    _qrSub = _repo.qrCodeUrlStream().listen((url) {
      if (!mounted) return;
      setState(() => _qrCodeUrl = url);
    });
  }

  void _loadWcFlag() {
    _wcSub = _repo.worldCupEnabledStream().listen((enabled) {
      if (!mounted) return;
      setState(() => _isWorldCupEnabled = enabled);
    });
  }

  void _loadBirthdaySettings() {
    _birthdaySub = _repo.birthdaySettingsStream().listen((data) {
      if (!mounted) return;
      setState(() {
        _birthdayImageUrls = List<String>.from(data['birthdayImageUrls'] ?? []);
        _birthdayName = data['birthdayName'] as String? ?? '';
        _birthdayWish = data['birthdayWish'] as String? ?? '';
        _birthdayDurationSeconds = data['birthdayDurationSeconds'] as int? ?? 7;
        _isBirthdayActive = data['isBirthdayActive'] == true;
      });
    });
  }

  void _loadBirthdayWishes() {
    _birthdayWishesSub = _repo.birthdayWishesStream().listen((wishes) {
      if (!mounted) return;
      setState(() {
        _birthdayWishes = wishes;
        _birthdayWishIndex = 0;
      });
    });
  }

  void _loadNowPlaying() {
    _nowPlayingSub = _repo.nowPlayingStream().listen((request) {
      if (!mounted) return;

      final wasPlaying = _nowPlaying != null;
      final isPlaying = request != null;

      debugPrint(
          '🎵 nowPlaying stream | wasPlaying=$wasPlaying isPlaying=$isPlaying');

      if (isPlaying && !wasPlaying) {
        debugPrint('🎵 → NEW TRACK: ${request.trackName}');
        _advanceTimer?.cancel();
        _progressTimer?.cancel();
        _musicTimer?.cancel();
        setState(() {
          _nowPlaying = request;
          _showMusicPhase = true;
        });
        _musicTimer = Timer(Duration(seconds: request.durationSeconds), () {
          if (!mounted) return;
          debugPrint('🎵 → music phase timeout — hiding');
          setState(() => _showMusicPhase = false);
          _resumeAfterMusicPhase();
        });
      } else if (!isPlaying && wasPlaying) {
        debugPrint('🎵 → TRACK STOPPED');
        _advanceTimer?.cancel();
        _progressTimer?.cancel();
        _musicTimer?.cancel();
        setState(() {
          _nowPlaying = null;
          _showMusicPhase = false;
        });
        _resumeAfterMusicPhase();
      } else {
        debugPrint('🎵 → same state, updating data only');
        setState(() => _nowPlaying = request);
      }
    }, onError: (e) {
      debugPrint('🎵 nowPlaying stream ERROR: $e');
    });
  }

  void _resumeAfterMusicPhase() {
    if (_isIdleMode) {
      _startIdleMode();
    } else if (_messages.isNotEmpty) {
      _showMessage(_currentIndex);
    } else {
      _startIdleMode();
    }
  }

  // ── Idle Mode ───────────────────────────────────────────────
  void _startIdleMode() {
    _advanceTimer?.cancel();
    _progressTimer?.cancel();
    _idleTimer?.cancel();
    _fadeCtrl.forward(from: 0);

    _idleTimer = Timer.periodic(
      Duration(seconds: _settings?.idleSceneDurationSeconds ?? 5),
      (_) {
        if (!mounted) return;
        setState(() =>
            _idleSlideIndex = (_idleSlideIndex + 1) % _effectiveSlides.length);
        _fadeCtrl.forward(from: 0);
      },
    );
  }

  // ── Message cycling ─────────────────────────────────────────
  void _showMessage(int index) {
    if (index >= _messages.length || _isIdleMode) return;

    _advanceTimer?.cancel();
    _progressTimer?.cancel();

    setState(() {
      _showQrPhase = false;
      _showBirthdayPhase = false;
    });

    final msg = _messages[index];
    final isVip = msg.isVip;
    final base = (_settings?.durationSeconds ?? 7) * 1000;
    final bonus = isVip ? (_settings?.vipBonusSeconds ?? 3) * 1000 : 0;
    final ms = base + bonus;

    _totalMs = ms;
    _remainingMs = ms;
    _progressValue = 1.0;

    // Kick the entry sequence for the framed card.
    _entryCtrl.forward(from: 0);
    _fadeCtrl.forward(from: 0);

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _remainingMs -= 50;
      if (_remainingMs <= 0) _remainingMs = 0;
      setState(() => _progressValue = _remainingMs / _totalMs);
    });

    _advanceTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _markCurrentDelivered();

      final next = (_currentIndex + 1) % _messages.length;
      if (next == 0 && _messages.length > 1) _messages.shuffle(Random());

      if (next == 0) {
        setState(() => _showQrPhase = true);
        _advanceTimer = Timer(const Duration(seconds: 15), () {
          if (!mounted) return;
          setState(() => _showQrPhase = false);
          _advanceToPostMusicPhase();
        });
        return;
      }

      setState(() => _currentIndex = next);
      _showMessage(_currentIndex);
    });
  }

  void _restartCurrentMessage() {
    if (!_isIdleMode && _messages.isNotEmpty) {
      _showMessage(_currentIndex);
    }
  }

  void _markCurrentDelivered() {
    if (_isIdleMode || _messages.isEmpty) return;
    final msg = _messages[_currentIndex];
    if (msg.status == ShoutoutStatus.accepted ||
        msg.status == ShoutoutStatus.paid) {
      _repo.markShoutoutDelivered(msg.id);
    }
  } // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _pinkAccent)),
      );
    }

    if (_settings?.isEnabled == false) return _buildEmptyState();
    if (_showMusicPhase) return _buildNowPlayingScreen();
    if (_showBirthdayPhase) return _buildBirthdayOverlay();
    if (_showBirthdayWishesPhase) return _buildBirthdayWishOverlay();
    if (_isIdleMode) return _buildIdleScreen();
    if (_showQrPhase) return _buildQrScreen();

    final msg = _messages[_currentIndex];
    final isVip = msg.isVip;

    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final bool hasQr = _qrCodeUrl != null && _qrCodeUrl!.isNotEmpty;
          return Stack(
            children: [
              _buildOrbs(isVip, box),
              _buildProgressStrip(isVip),
              _buildTopBar(scale),
              if (_isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: hasQr
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: box.maxWidth * 0.06),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // _buildMessageQr(scale),
                              SizedBox(width: box.maxWidth * 0.05),
                              Flexible(
                                child: _buildFramedContent(
                                    msg, isVip, box, scale,
                                    noPadding: true),
                              ),
                            ],
                          ),
                        )
                      : _buildFramedContent(msg, isVip, box, scale),
                ),
              ),
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

  Widget _buildBirthdayOverlay() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return BirthdayOverlay(
            imageUrl:
                _birthdayImageUrls.isNotEmpty ? _birthdayImageUrls.first : null,
            name: _birthdayName,
            wish: _birthdayWish,
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildBirthdayWishOverlay() {
    if (_birthdayWishes.isEmpty) return const SizedBox.shrink();
    final wish = _birthdayWishes[_birthdayWishIndex];
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final isAnonymous = wish['isAnonymous'] == true;
          final name = isAnonymous
              ? 'Anonymous'
              : (wish['userName'] as String? ?? 'Someone');
          final content = wish['content'] as String? ?? '';
          final toName = wish['toName'] as String? ?? _birthdayName;
          return BirthdayOverlay(
            imageUrl:
                _birthdayImageUrls.isNotEmpty ? _birthdayImageUrls.first : null,
            name: toName,
            wish: '$name says: $content',
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingScreen() {
    final req = _nowPlaying;
    if (req == null) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return NowPlayingScreen(request: req, scale: scale);
        },
      ),
    );
  }

  void _advanceToPostMusicPhase() {
    if (_isBirthdayActive && _birthdayName.isNotEmpty) {
      setState(() => _showBirthdayPhase = true);
      _advanceTimer = Timer(Duration(seconds: _birthdayDurationSeconds), () {
        if (!mounted) return;
        if (_birthdayWishes.isNotEmpty) {
          setState(() {
            _showBirthdayPhase = false;
            _showBirthdayWishesPhase = true;
            _birthdayWishIndex = 0;
          });
          _advanceTimer = Timer(const Duration(seconds: 7), _nextBirthdayWish);
        } else {
          setState(() => _showBirthdayPhase = false);
          _currentIndex = 0;
          _showMessage(0);
        }
      });
    } else {
      setState(() => _currentIndex = 0);
      _showMessage(0);
    }
  }

  void _nextBirthdayWish() {
    if (!mounted) return;
    final next = _birthdayWishIndex + 1;
    if (next < _birthdayWishes.length) {
      setState(() => _birthdayWishIndex = next);
      _advanceTimer = Timer(const Duration(seconds: 7), _nextBirthdayWish);
    } else {
      setState(() {
        _showBirthdayWishesPhase = false;
        _currentIndex = 0;
      });
      _showMessage(0);
    }
  }

  // ── Idle Screen ─────────────────────────────────────────────
  Widget _buildIdleScreen() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final slide = _effectiveSlides[_idleSlideIndex];
          final accent = _accentForSlide(slide.suggestionIndex);
          final greeting = _timeGreeting(_now);

          final double baseFont = _settings?.fontSize ?? 72.0;
          final double orgNameSize =
              (_settings?.idleOrgNameSize ?? baseFont * 0.72) * scale;
          final double headlineSize =
              (_settings?.idleHeadlineSize ?? baseFont * 1.0) * scale;
          final double subtitleSize =
              (_settings?.idleSubtitleSize ?? baseFont * 0.28) * scale;
          final double ctaSize =
              (_settings?.idleCtaSize ?? baseFont * 0.22) * scale;
          final double cardLabelSize =
              (_settings?.idleCardLabelSize ?? baseFont * 0.17) * scale;
          final double cardHintSize =
              (_settings?.idleCardHintSize ?? baseFont * 0.11) * scale;
          final double footerMonoSize =
              (_settings?.idleFooterSize ?? baseFont * 0.16) * scale;
          final double greetingSize =
              (_settings?.idleGreetingSize ?? baseFont * 0.19) * scale;

          final labelStyle = _getFontStyle(
            fontSize: cardLabelSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          );

          return Stack(
            children: [
              _buildOrbs(false, box),
              _buildTopBar(scale),
              if (_isWorldCupEnabled) WorldCupOverlay(scale: scale),
           Positioned.fill(
  child: IgnorePointer(
    child: _FloatingParticles(
      seed: _idleSlideIndex + 7,
      accent: accent,   // ← already computed above as _accentForSlide(slide.suggestionIndex)
    ),
  ),
),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.spaceMono(
                          fontSize: greetingSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [accent, Colors.white, accent],
                        ).createShader(bounds),
                        child: Text(
                          _orgName.isNotEmpty
                              ? _orgName.toUpperCase()
                              : 'WELCOME',
                          style: _getFontStyle(
                            fontSize: orgNameSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      SizedBox(height: 30 * scale),
                      AnimatedBuilder(
                        animation:
                            Listenable.merge([_idleBreathAnim, _orbAnim]),
                        builder: (context, _) {
                          final breath =
                              1.0 + (_idleBreathAnim.value - 0.5) * 0.05;
                          return Transform.scale(
                            scale: breath,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment(-1.0 + _orbAnim.value * 2, 0),
                                end: const Alignment(1.0, 0),
                                colors: [
                                  Colors.white,
                                  accent,
                                  Colors.white,
                                  accent,
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              ).createShader(bounds),
                              child: Text(
                                slide.headline,
                                key: ValueKey('hl_$_idleSlideIndex'),
                                textAlign: TextAlign.center,
                                style: _getFontStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  height: 1.05,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.5),
                                      blurRadius: 40 * scale,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16 * scale),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: Text(
                          slide.subtitle,
                          key: ValueKey('sub_$_idleSlideIndex'),
                          textAlign: TextAlign.center,
                          style: _getFontStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      SizedBox(height: 40 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIdleSuggestionCards(
                            scale,
                            slide.suggestionIndex,
                            labelStyle: labelStyle,
                            hintFontSize: cardHintSize,
                          ),
                          _buildIdleQr(scale),
                        ],
                      ),
                      Text(
                        'SCAN TO JOIN THE PARTY',
                        style: _getFontStyle(
                          fontSize: ctaSize,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w800,
                          color: accent.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24 * scale,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildIdleFooter(
                    scale,
                    monoFontSize: footerMonoSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _accentForSlide(int suggestionIndex) {
    switch (suggestionIndex) {
      case 0:
        return _pinkAccent;
      case 1:
        return _amberAccent;
      case 2:
        return _cyanAccent;
      case 3:
        return _purpleAccent;
      default:
        return _pinkAccent;
    }
  }

  String _timeGreeting(DateTime t) {
    final h = t.hour;
    if (h < 5) return 'LATE NIGHT VIBES';
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    if (h < 22) return 'GOOD EVENING';
    return 'LATE NIGHT VIBES';
  }

  Widget _buildIdleSuggestionCards(
    double scale,
    int activeIndex, {
    required TextStyle labelStyle,
    required double hintFontSize,
  }) {
    final suggestions = _effectiveSuggestions;
    final cardWidth = _settings?.idleCardWidth ?? 190;
    final cardHeight = _settings?.idleCardHeight ?? 130;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(suggestions.length, (i) {
        final s = suggestions[i];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
          child: _IdleSuggestionCard(
            suggestion: s,
            accent: _accentForSlide(i),
            scale: scale,
            active: i == activeIndex,
            labelStyle: labelStyle,
            hintFontSize: hintFontSize,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
          ),
        );
      }),
    );
  }

  Widget _buildIdleQr(double scale) {
    if (_qrCodeUrl == null || _qrCodeUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    final double baseQr =
        _settings?.qrCodeSize ?? ((_settings?.qrCodeSize ?? 280) * 0.6);
    final double size = baseQr * scale;

    return AnimatedBuilder(
      animation: _idleRadarAnim,
      builder: (context, _) {
        return SizedBox(
          width: size + 80,
          height: size + 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (i) {
                final double t = (_idleRadarAnim.value + i / 3) % 1.0;
                return Container(
                  width: size + t * 80,
                  height: size + t * 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _pinkAccent.withValues(alpha: (1 - t) * 0.35),
                      width: 2,
                    ),
                  ),
                );
              }),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _pinkAccent.withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: QrImageView(
                  data: _qrCodeUrl!,
                  size: size,
                  eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdleFooter(double scale, {required double monoFontSize}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _EqualizerBars(scale: scale, color: _pinkAccent),
        SizedBox(width: 10 * scale),
        PulseDot(color: _pinkAccent, size: 7 * scale),
        SizedBox(width: 8 * scale),
        Text(
          'LIVE FROM THE CLUB',
          style: GoogleFonts.spaceMono(
            fontSize: monoFontSize,
            letterSpacing: 4,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(width: 22 * scale),
        Container(
          width: 1,
          height: 14 * scale,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        SizedBox(width: 22 * scale),
        Text(
          'ENERGY',
          style: GoogleFonts.spaceMono(
            fontSize: monoFontSize,
            letterSpacing: 3,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(width: 8 * scale),
        _EnergyMeter(
          scale: scale,
          level: _energyLevel,
          fontSize: monoFontSize,
        ),
      ],
    );
  }

  // ── QR Screen ──────────────────────────────────────────────
  Widget _buildQrScreen() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              _buildOrbs(false, box),
              _buildTopBar(scale),
              if (_isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Center(
                child: _qrCodeUrl == null || _qrCodeUrl!.isEmpty
                    ? const SizedBox.shrink()
                    : QrImageView(
                        data: _qrCodeUrl!,
                        size: (_settings?.qrCodeSize ?? 500) * scale,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square, color: Colors.black),
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
                    fontSize: 25 * scale,
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

  // ── Ambient orbs & Grid ─────────────────────────────────────
  Widget _buildOrbs(bool isVip, BoxConstraints box) {
    final Color c1 = isVip ? _amberOrb : _pinkOrb;
    final Color c2 = isVip ? _amberOrb2 : _pinkOrb2;
    return Stack(children: [
      Positioned.fill(
        child: CustomPaint(
          painter: TechGridPainter(
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

  // ── Progress strip ──────────────────────────────────────────
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

  // ── Top bar ────────────────────────────────────────────────
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
              PulseDot(color: _pinkAccent, size: 8 * scale),
              SizedBox(width: 12 * scale),
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (context, child) {
                  final glow = _orbAnim.value * 0.5 + 0.5;
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-0.8 + _orbAnim.value * 1.6, 0.0),
                      end: const Alignment(1.0, 0.0),
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

  // ── Message QR (left side) ──────────────────────────────────
  Widget _buildMessageQr(double scale) {
    if (_qrCodeUrl == null || _qrCodeUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    final double size = (_settings?.qrCodeSize ?? 280) * scale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _pinkAccent.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: QrImageView(
        data: _qrCodeUrl!,
        size: size,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  } // ══════════════════════════════════════════════════════════════
  // REDESIGNED MESSAGE CONTENT — framed card with brackets,
  // dramatic name reveal, quote-style message, and a sleek
  // meta bar. VIP gets the gold treatment.
  // ══════════════════════════════════════════════════════════════

  Widget _buildFramedContent(
    ShoutoutRequest msg,
    bool isVip,
    BoxConstraints box,
    double scale, {
    bool noPadding = false,
  }) {
    final double fontSizeCap = _settings?.fontSize ?? 72.0;

    final double userNameSize = min(
          box.maxWidth * 0.028,
          fontSizeCap * 0.72,
        ) *
        scale;

    final double msgSize = min(
          box.maxWidth * 0.05,
          fontSizeCap * 0.95,
        ) *
        scale;

    final Color accent = isVip ? _goldAccent : _pinkAccent;
    final Color accentSoft = isVip ? _amberAccent : _pinkSoft;
    final Color accentDeep = isVip ? _goldDeep : _pinkAccent;
    final bool hasUser = msg.userName != null && msg.userName!.isNotEmpty;

    final double cardMaxWidth =
        noPadding ? double.infinity : box.maxWidth * 0.78;
    final double cardPaddingH = 48 * scale;
    final double cardPaddingV = 38 * scale;

    final card = AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) {
        final double t = _entryAnim.value;
        final double slideX = (1 - t) * 40;
        final double scaleIn = 0.94 + 0.06 * t;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(slideX, 0),
            child: Transform.scale(
              scale: scaleIn,
              child: child,
            ),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardMaxWidth),
        child: _MessageFrame(
          accent: accent,
          accentDeep: accentDeep,
          drawProgress: _frameAnim.value,
          scanProgress: _scanAnim.value,
          isVip: isVip,
          borderRadius: 18,
          child: Stack(
            children: [
              if (isVip)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _vipSweepAnim,
                      builder: (_, __) {
                        return CustomPaint(
                          painter:
                              _GoldSweepPainter(progress: _vipSweepAnim.value),
                        );
                      },
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cardPaddingH,
                  vertical: cardPaddingV,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBadge(isVip, scale),
                    SizedBox(height: box.maxHeight * 0.04),
                    if (hasUser) ...[
                      _buildAnimatedName(
                        msg.userName!.toUpperCase(),
                        accent: accent,
                        accentSoft: accentSoft,
                        fontSize: userNameSize,
                        scale: scale,
                        isVip: isVip,
                      ),
                      SizedBox(height: box.maxHeight * 0.035),
                    ],
                    _buildMessageQuote(
                      text: msg.message.trim().isEmpty
                          ? '> DROP YOUR SHOUTOUT'
                          : '> ${msg.message}',
                      accent: accent,
                      fontSize: msgSize,
                      scale: scale,
                    ),
                    SizedBox(height: box.maxHeight * 0.035),
                    _buildSenderMeta(msg, isVip, scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (noPadding) return card;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: box.maxWidth * 0.1),
      child: card,
    );
  }

  Widget _buildAnimatedName(
    String name, {
    required Color accent,
    required Color accentSoft,
    required double fontSize,
    required double scale,
    required bool isVip,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameAnim, _orbAnim, _vipSweepAnim]),
      builder: (context, _) {
        final t = _nameAnim.value;
        final double punch = t == 0 ? 0.6 : (t > 1 ? 1.0 : t);
        final double overshoot =
            punch < 1 ? 0.6 + 0.4 * Curves.easeOutBack.transform(punch) : 1.0;
        final double pulse = (sin(_orbAnim.value * pi * 2) * 0.04) + 1.0;
        final double scaleNow = overshoot * pulse;
        final double sweep = (_orbAnim.value * 2 - 1);

        return Opacity(
          opacity: punch.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scaleNow,
            child: ShaderMask(
              shaderCallback: (bounds) {
                if (isVip) {
                  return LinearGradient(
                    begin: Alignment(-1.0 + sweep * 2, 0),
                    end: Alignment(1.0 + sweep * 2, 0),
                    colors: const [
                      _goldDeep,
                      _goldAccent,
                      Colors.white,
                      _goldAccent,
                      _goldDeep,
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ).createShader(bounds);
                }
                return LinearGradient(
                  begin: Alignment(-1.0 + sweep * 2, 0),
                  end: Alignment(1.0 + sweep * 2, 0),
                  colors: [
                    accent,
                    accentSoft,
                    Colors.white,
                    accentSoft,
                    accent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _getFontStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: isVip ? 10 : 8,
                  shadows: [
                    Shadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 32 * scale,
                    ),
                    Shadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 64 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageQuote({
    required String text,
    required Color accent,
    required double fontSize,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 36 * scale,
        vertical: 28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -22 * scale,
            left: -14 * scale,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              scale: _entryAnim.value,
              child: _QuoteGlyph(
                color: accent,
                size: 56 * scale,
                align: Alignment.topLeft,
              ),
            ),
          ),
          Positioned(
            bottom: -28 * scale,
            right: -14 * scale,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              scale: _entryAnim.value,
              child: _QuoteGlyph(
                color: accent,
                size: 56 * scale,
                align: Alignment.bottomRight,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white70,
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white70,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: AnimatedBuilder(
                    animation: _orbAnim,
                    builder: (context, child) {
                      return TypewriterText(
                        key: ValueKey('tw_${_currentIndex}_$text'),
                        text: text,
                        textAlign: TextAlign.center,
                        style: _getFontStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 6 * scale),
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _BlinkingCursor(
                  color: accent,
                  height: fontSize * 0.9,
                  width: 4 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isVip, double scale) {
    final Color accent = isVip ? _goldAccent : _pinkSoft;
    final Color bg = isVip
        ? _goldAccent.withValues(alpha: 0.14)
        : accent.withValues(alpha: 0.12);
    final Color border = isVip
        ? _goldAccent.withValues(alpha: 0.45)
        : accent.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) {
        final t = _nameAnim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
          boxShadow: isVip
              ? [
                  BoxShadow(
                    color: _goldAccent.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseDot(color: accent, size: 6 * scale),
            SizedBox(width: 10 * scale),
            Icon(
              isVip ? Icons.workspace_premium_rounded : Icons.campaign_rounded,
              size: 12 * scale,
              color: accent,
            ),
            SizedBox(width: 6 * scale),
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
      ),
    );
  }

  Widget _buildSenderMeta(ShoutoutRequest msg, bool isVip, double scale) {
    final Color accent = isVip ? _goldAccent : _pinkAccent;
    return AnimatedBuilder(
      animation: _metaAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _metaAnim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _metaAnim.value) * 12),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _metaDash(accent, scale, align: 'left'),
          SizedBox(width: 12 * scale),
          Icon(
            Icons.schedule_send_rounded,
            size: 11 * scale,
            color: accent.withValues(alpha: 0.6),
          ),
          SizedBox(width: 6 * scale),
          Text(
            DateFormat('HH:mm').format(msg.createdAt),
            style: GoogleFonts.spaceMono(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 18 * scale),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 18 * scale),
          Text(
            'MSG ${_currentIndex + 1}/${_messages.length}',
            style: GoogleFonts.spaceMono(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 12 * scale),
          _metaDash(accent, scale, align: 'right'),
        ],
      ),
    );
  }

  Widget _metaDash(Color accent, double scale, {required String align}) {
    return SizedBox(
      width: 60 * scale,
      child: Row(
        children: [
          if (align == 'right') const Spacer(),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: align == 'left'
                      ? [
                          Colors.transparent,
                          accent.withValues(alpha: 0.6),
                        ]
                      : [
                          accent.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  TextStyle _getFontStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
    Color color = Colors.white,
    double height = 1.0,
    List<Shadow> shadows = const [],
  }) {
    final family = _settings?.fontFamily;
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
      shadows: shadows,
    );
    if (family != null && family.isNotEmpty) {
      return GoogleFonts.getFont(family, textStyle: base);
    }
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }
}

// ═══════════════════════════════════════════════════════════════
// Idle data + helper widgets
// ═══════════════════════════════════════════════════════════════

class _IdleSuggestion {
  final IconData icon;
  final String label;
  const _IdleSuggestion({required this.icon, required this.label});
}

class _IdleSlide {
  final String emoji;
  final String headline;
  final String subtitle;
  final int suggestionIndex;
  const _IdleSlide({
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.suggestionIndex,
  });
}

class IdleSceneConfig {
  final String emoji;
  final String headline;
  final String subtitle;
  final int suggestionIndex;
  const IdleSceneConfig({
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.suggestionIndex,
  });

  factory IdleSceneConfig.fromJson(Map<String, dynamic> json) {
    return IdleSceneConfig(
      emoji: json['emoji'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      suggestionIndex: json['suggestionIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'headline': headline,
        'subtitle': subtitle,
        'suggestionIndex': suggestionIndex,
      };
}

// ═══════════════════════════════════════════════════════════════
// Message frame — corner brackets that draw on entry, with a
// subtle scanning line. Used for both regular and VIP shoutouts.
// ═══════════════════════════════════════════════════════════════

class _MessageFrame extends StatelessWidget {
  final Widget child;
  final Color accent;
  final Color accentDeep;
  final double drawProgress;
  final double scanProgress;
  final bool isVip;
  final double borderRadius;

  const _MessageFrame({
    required this.child,
    required this.accent,
    required this.accentDeep,
    required this.drawProgress,
    required this.scanProgress,
    required this.isVip,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E1A).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isVip ? 0.35 : 0.25),
                blurRadius: isVip ? 60 : 40,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.6),
                        radius: 1.1,
                        colors: [
                          accent.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScanLinePainter(
                      progress: scanProgress,
                      color: accent,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CornerBracketsPainter(
                      progress: drawProgress,
                      color: accent,
                      colorDeep: accentDeep,
                      radius: borderRadius,
                      isVip: isVip,
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color colorDeep;
  final double radius;
  final bool isVip;

  _CornerBracketsPainter({
    required this.progress,
    required this.color,
    required this.colorDeep,
    required this.radius,
    required this.isVip,
  });

  static const double _armLong = 90;
  static const double _armShort = 36;
  static const double _thickness = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    const cornerCount = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = _thickness + 4
      ..strokeCap = StrokeCap.square
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;

    void drawArm(Offset from, Offset to, double p) {
      if (p <= 0) return;
      final end = Offset.lerp(from, to, p.clamp(0.0, 1.0))!;
      canvas.drawLine(from, end, glowPaint);
      canvas.drawLine(from, end, paint);
    }

    final r = radius;
    final corners = <_CornerOrigin>[
      _CornerOrigin(Offset(r, 0), const Offset(1, 0), const Offset(0, 1)),
      _CornerOrigin(
          Offset(size.width - r, 0), const Offset(-1, 0), const Offset(0, 1)),
      _CornerOrigin(
          Offset(r, size.height), const Offset(1, 0), const Offset(0, -1)),
      _CornerOrigin(Offset(size.width - r, size.height), const Offset(-1, 0),
          const Offset(0, -1)),
    ];

    for (int i = 0; i < cornerCount; i++) {
      final c = corners[i];
      final local = ((progress - i * 0.08) / 0.68).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final longP = (local / 0.65).clamp(0.0, 1.0);
      final shortP = ((local - 0.65) / 0.35).clamp(0.0, 1.0);

      final longEnd = c.origin + c.longDir * _armLong;
      final shortEnd = c.origin + c.shortDir * _armShort;

      drawArm(c.origin, longEnd, longP);
      drawArm(c.origin, shortEnd, shortP);

      if (local >= 1.0) {
        final dotPaint = Paint()
          ..color = isVip ? Colors.white : color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(c.origin, 4, dotPaint);
        canvas.drawCircle(c.origin, 2.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter old) =>
      old.progress != progress || old.color != color || old.isVip != isVip;
}

class _CornerOrigin {
  final Offset origin;
  final Offset longDir;
  final Offset shortDir;
  const _CornerOrigin(this.origin, this.longDir, this.shortDir);
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) =>
      old.progress != progress || old.color != color;
}

class _GoldSweepPainter extends CustomPainter {
  final double progress;
  _GoldSweepPainter({required this.progress});
  static const _goldAccent = Color(0xFFFFD24A);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + progress * 2, 0),
        end: Alignment(0.0 + progress * 2, 0),
        colors: [
          Colors.transparent,
          _goldAccent.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldSweepPainter old) =>
      old.progress != progress;
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;
  final double width;
  const _BlinkingCursor({
    required this.color,
    required this.height,
    required this.width,
  });

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
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

class _QuoteGlyph extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment align;
  const _QuoteGlyph({
    required this.color,
    required this.size,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter:
              _QuotePainter(color: color, flip: align == Alignment.bottomRight),
        ),
      ),
    );
  }
}

class _QuotePainter extends CustomPainter {
  final Color color;
  final bool flip;
  _QuotePainter({required this.color, required this.flip});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (flip) {
      canvas.translate(size.width, size.height);
      canvas.rotate(pi);
    }
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p1 = Path()
      ..moveTo(size.width * 0.62, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.30,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.55, size.height * 0.85);

    final p2 = Path()
      ..moveTo(size.width * 0.95, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.20,
        size.width * 0.62,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.88, size.height * 0.85);

    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(p1, glow);
    canvas.drawPath(p2, glow);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QuotePainter old) =>
      old.color != color || old.flip != flip;
}

class _IdleSuggestionCard extends StatefulWidget {
  final _IdleSuggestion suggestion;
  final Color accent;
  final double scale;
  final bool active;
  final TextStyle labelStyle;
  final double hintFontSize;
  final double cardWidth;
  final double cardHeight;
  const _IdleSuggestionCard({
    required this.suggestion,
    required this.accent,
    required this.scale,
    required this.active,
    required this.labelStyle,
    required this.hintFontSize,
    this.cardWidth = 190,
    this.cardHeight = 130,
  });

  @override
  State<_IdleSuggestionCard> createState() => _IdleSuggestionCardState();
}

class _IdleSuggestionCardState extends State<_IdleSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final scale = widget.scale;
    final active = widget.active;
    final cardScale = widget.cardWidth / 190;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = active ? _pulse.value : 0.0;
        final scaleAnim = active ? 1.0 + _pulse.value * 0.06 : 1.0;
        return Transform.scale(
          scale: scaleAnim,
          child: Container(
            width: widget.cardWidth * scale,
            height: widget.cardHeight * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale * cardScale,
              vertical: 12 * scale * cardScale,
            ),
            decoration: BoxDecoration(
              color: active
                  ? widget.accent.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12 * cardScale),
              border: Border.all(
                color: active
                    ? widget.accent.withValues(alpha: 0.55 + glow * 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: active ? 2 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4 * glow),
                        blurRadius: 28 * cardScale,
                        spreadRadius: 1 * cardScale,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(10 * scale * cardScale),
                  decoration: BoxDecoration(
                    color: active
                        ? widget.accent.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    s.icon,
                    color: active
                        ? widget.accent
                        : Colors.white.withValues(alpha: 0.35),
                    size: 26 * scale * cardScale,
                  ),
                ),
                SizedBox(height: 10 * scale * cardScale),
                Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: widget.labelStyle.copyWith(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                SizedBox(height: 4 * scale * cardScale),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: active ? 1.0 : 0.0,
                  child: Text(
                    'TAP TO START',
                    style: GoogleFonts.spaceMono(
                      fontSize: widget.hintFontSize,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: widget.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// DROP-IN REPLACEMENT for the _FloatingParticles block in
// /home/l3ul/nightmusictoughtdasboard/lib/features/tv_display/widget/tv_display_screen.dart
//
// Find the block that starts with the comment:
//
//   // ═══════════════════════════════════════════════════════════════
//   // Floating particles (subtle, music-themed)     ← in tv_display_screen.dart
//   // ═══════════════════════════════════════════════════════════════
//
// and ends at the closing `}` of class _ParticlePainter. Replace the
// ENTIRE block (4 classes: _FloatingParticles, _FloatingParticlesState,
// _Particle, _ParticlePainter) with the one below.
//
// Then update the call site in _buildIdleScreen from:
//   _FloatingParticles(seed: _idleSlideIndex + 7)
// to:
//   _FloatingParticles(seed: _idleSlideIndex + 7, accent: accent)
// where `accent` is already computed in _buildIdleScreen as
// `_accentForSlide(slide.suggestionIndex)`.
// ═══════════════════════════════════════════════════════════════════════════

// Floating music-note particles
//
// Renders actual music glyphs (♪ ♫ ♬ ♩ ♭ ♯) instead of generic dots.
// Sizes are distributed across three buckets (small / medium / large)
// so the field reads as varied depth-of-field particles, not a uniform
// sprinkle. Each glyph is pre-baked as a white TextPainter and
// re-tinted per-frame via ColorFilter.modulate to keep the alpha
// animation cost-free. On the idle screen the accent rotates per slide
// (pink → amber → cyan → purple), so we pass it in and let the
// particles pick up the current slide's vibe.

class _FloatingParticles extends StatefulWidget {
  final int seed;
  final Color accent;
  const _FloatingParticles({required this.seed, required this.accent});
  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  static const double _baseFontSize = 64; // canvas units, scaled per particle

  // Music glyphs — outline shapes that tint cleanly across platforms.
  static const _musicIcons = <String>[
    '♪', // eighth note
    '♫', // beamed eighth notes
    '♬', // beamed sixteenth notes
    '♩', // quarter note
    '♭', // flat
    '♯', // sharp
  ];

  late AnimationController _ctrl;
  late List<_Particle> _particles;
  late Random _random;

  // Painter cache, keyed by "icon-argb". One entry per (glyph, color)
  // combination — 6 icons × ~5 colors = ~30 max over the lifetime.
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
  void didUpdateWidget(covariant _FloatingParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-tint particles if the slide's accent changed.
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
            fontSize: _baseFontSize,
            color: color,
            fontFamily: 'serif',
            height: 1.0,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(),
    );
  }

  void _respawn() {
    _random = Random(widget.seed);
    // Idle palette — pink + soft + amber + cyan + purple + white.
    // The accent is already in widget.accent, but we keep the rest of
    // the brand palette so the field has a colorful, balanced look.
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

  // Distribute sizes across three buckets:
  //   50% small  (12–20)
  //   35% medium (22–32)
  //   15% large  (36–44)
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
      final double edgeFade = (y < 0.05
              ? y / 0.05
              : (y > 0.95 ? (1 - y) / 0.05 : 1.0))
          .clamp(0.0, 1.0);
      final paintAlpha = (p.opacity * edgeFade).clamp(0.0, 1.0);
      if (paintAlpha <= 0) continue;

      final cx = x * size.width;
      final cy = y * size.height;
      final double scale = p.size / _FloatingParticlesState._baseFontSize;
      final double rot = p.rotation + progress * p.rotationSpeed * 6.28;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.scale(scale);

      // Per-frame alpha via ColorFilter.modulate — multiplies the
      // layer's alpha by the filter's alpha, leaving the baked glyph
      // color untouched.
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
      canvas.restore(); // saveLayer
      canvas.restore(); // outer
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}

class _EqualizerBars extends StatefulWidget {
  final double scale;
  final Color color;
  const _EqualizerBars({required this.scale, required this.color});
  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<double> _phases;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat();
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

class _EnergyMeter extends StatelessWidget {
  final double scale;
  final double level;
  final double fontSize;
  const _EnergyMeter({
    required this.scale,
    required this.level,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (level * 100).round();
    final w = 110.0 * scale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w,
          height: 6 * scale,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: w * level,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF007A), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          '$pct%',
          style: GoogleFonts.spaceMono(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/match_result.dart';
import '../../../../core/services/world_cup_service.dart';

/// Corner overlay shown on the TV screen. Kept visually consistent with the
/// main shoutout display: dark glass card, pink/amber accents, Space
/// Grotesk / Space Mono type — instead of the old flat green/gold panel.
class WorldCupOverlay extends StatefulWidget {
  final double scale;
  const WorldCupOverlay({super.key, this.scale = 1.0});

  @override
  State<WorldCupOverlay> createState() => _WorldCupOverlayState();
}

class _WorldCupOverlayState extends State<WorldCupOverlay>
    with SingleTickerProviderStateMixin {
  final WorldCupService _service = WorldCupService();
  List<MatchResult> _matches = [];
  StreamSubscription? _sub;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _pink = Color(0xFFFF007A);
  static const _amber = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _sub = _service.matchesStream.listen(
      (matches) {
        if (!mounted) return;
        setState(() => _matches = matches);
        _entryCtrl.forward(from: 0);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _matches = []);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _entryCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  List<MatchResult> get _liveMatches =>
      _matches.where((m) => m.status == 'in_progress').toList();

  List<MatchResult> get _pastMatches =>
      _matches.where((m) => m.status == 'completed').take(3).toList();

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    Widget? card;

    if (_liveMatches.isNotEmpty) {
      card = _LiveMatchCard(match: _liveMatches.first, scale: s);
    } else if (_pastMatches.isNotEmpty) {
      card = _PastMatchesCard(matches: _pastMatches, scale: s);
    }

    if (card == null) return const SizedBox.shrink();

    return Positioned(
      top: 96 * s,
      right: 24 * s,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(position: _slideAnim, child: card),
      ),
    );
  }
}

/// Frosted glass shell shared by both card variants so the overlay reads as
/// part of the same UI system as the rest of the TV screen.
class _GlassShell extends StatelessWidget {
  final Widget child;
  final double scale;
  final Color accent;

  const _GlassShell({
    required this.child,
    required this.scale,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0B0B18).withValues(alpha: 0.82),
                const Color(0xFF17081F).withValues(alpha: 0.82),
              ],
            ),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: accent.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 28 * s,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final double scale;
  final Color accent;
  final String text;
  const _SectionLabel({
    required this.scale,
    required this.accent,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Icon(Icons.emoji_events_rounded, color: accent, size: 13 * s),
        SizedBox(width: 6 * s),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11 * s,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  final double size;
  const _LivePulseDot({required this.size});

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final Animation<double> _anim =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: _anim.value * 0.5 + 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: _anim.value * 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMatchCard extends StatelessWidget {
  final MatchResult match;
  final double scale;
  const _LiveMatchCard({required this.match, required this.scale});

  static const _pink = Color(0xFFFF007A);
  static const _amber = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    final m = match;
    final s = scale;
    final score = m.hasResult ? '${m.homeScore} - ${m.awayScore}' : 'LIVE';
    final minute = m.liveMinute != null ? "${m.liveMinute}'" : 'LIVE';
    final poss = m.stats.where((st) => st.label == 'Possession').toList();
    final shots =
        m.stats.where((st) => st.label == 'Shots on target').toList();

    return SizedBox(
      width: 300 * s,
      child: _GlassShell(
        scale: s,
        accent: _pink,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(s, minute, m.round),
            SizedBox(height: 10 * s),
            _scoreRow(s, m, score),
            if (m.homeGoals.isNotEmpty || m.awayGoals.isNotEmpty) ...[
              SizedBox(height: 8 * s),
              _goalsRow(s, m),
            ],
            if (poss.isNotEmpty || shots.isNotEmpty) ...[
              SizedBox(height: 10 * s),
              Row(
                children: [
                  if (poss.isNotEmpty) Expanded(child: _statBar(s, poss.first)),
                  if (poss.isNotEmpty && shots.isNotEmpty)
                    SizedBox(width: 10 * s),
                  if (shots.isNotEmpty)
                    Expanded(child: _statBar(s, shots.first)),
                ],
              ),
            ],
            if (m.ground.isNotEmpty) ...[
              SizedBox(height: 6 * s),
              Text(
                m.ground,
                style: GoogleFonts.spaceMono(
                  fontSize: 9 * s,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(double s, String minute, String round) {
    return Row(
      children: [
        _LivePulseDot(size: 7 * s),
        SizedBox(width: 7 * s),
        Text(
          minute,
          style: GoogleFonts.spaceMono(
            fontSize: 13 * s,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.redAccent,
          ),
        ),
        const Spacer(),
        if (round.isNotEmpty) ...[
          Flexible(
            child: Text(
              round,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          SizedBox(width: 8 * s),
        ],
        _SectionLabel(scale: s, accent: _amber, text: 'WORLD CUP'),
      ],
    );
  }

  Widget _scoreRow(double s, MatchResult m, String score) {
    return Row(
      children: [
        Expanded(
          child: Text(
            m.homeTeam,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8 * s),
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 5 * s),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(color: _pink.withValues(alpha: 0.3)),
          ),
          child: Text(
            score,
            style: GoogleFonts.spaceMono(
              fontSize: 19 * s,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            m.awayTeam,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _goalsRow(double s, MatchResult m) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6 * s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: m.homeGoals
                  .map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 2 * s),
                        child: Text(
                          '⚽ ${g.name} ${g.minute}\'',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceMono(
                            fontSize: 9 * s,
                            color: _amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: m.awayGoals
                  .map((g) => Padding(
                        padding: EdgeInsets.only(bottom: 2 * s),
                        child: Text(
                          '${g.minute}\' ${g.name} ⚽',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.spaceMono(
                            fontSize: 9 * s,
                            color: _amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBar(double s, MatchStat stat) {
    final total = stat.homeValue + stat.awayValue;
    final homeRatio = total > 0 ? stat.homeValue / total : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 8 * s,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(height: 3 * s),
        Row(
          children: [
            SizedBox(
              width: 18 * s,
              child: Text(
                '${stat.homeValue}',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 4 * s),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3 * s),
                child: SizedBox(
                  height: 5 * s,
                  child: Row(
                    children: [
                      Flexible(
                        flex: (homeRatio * 100).round().clamp(1, 99),
                        child: Container(color: _pink),
                      ),
                      Flexible(
                        flex: ((1 - homeRatio) * 100).round().clamp(1, 99),
                        child: Container(color: _amber),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 4 * s),
            SizedBox(
              width: 18 * s,
              child: Text(
                '${stat.awayValue}',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PastMatchesCard extends StatelessWidget {
  final List<MatchResult> matches;
  final double scale;
  const _PastMatchesCard({required this.matches, required this.scale});

  static const _pink = Color(0xFFFF007A);
  static const _amber = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: 260 * s,
      child: _GlassShell(
        scale: s,
        accent: _amber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _SectionLabel(scale: s, accent: _amber, text: 'WORLD CUP'),
                const Spacer(),
                Text(
                  'RESULTS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * s),
            ...matches.map((m) => _row(s, m)),
          ],
        ),
      ),
    );
  }

  Widget _row(double s, MatchResult m) {
    return Container(
      margin: EdgeInsets.only(bottom: 6 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8 * s),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              m.homeTeam,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 3 * s),
            margin: EdgeInsets.symmetric(horizontal: 6 * s),
            decoration: BoxDecoration(
              color: _pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5 * s),
              border: Border.all(color: _pink.withValues(alpha: 0.25)),
            ),
            child: Text(
              m.hasResult ? '${m.homeScore}-${m.awayScore}' : '–',
              style: GoogleFonts.spaceMono(
                fontSize: 10 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              m.awayTeam,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
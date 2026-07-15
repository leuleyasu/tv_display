class Goal {
  final String name;
  final String minute;
  final String? assist;

  const Goal({required this.name, required this.minute, this.assist});

  factory Goal.fromJson(Map json) => Goal(
        name: json['name'] as String? ?? '',
        minute: json['minute']?.toString() ?? '',
        assist: json['assist'] as String?,
      );
}

class MatchStat {
  final String label;
  final int homeValue;
  final int awayValue;
  final String unit;

  const MatchStat({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    this.unit = '',
  });

  factory MatchStat.fromJson(Map json) => MatchStat(
        label: json['k_en'] as String? ?? json['k'] as String? ?? '',
        homeValue: (json['v'] is List && (json['v'] as List).length > 1)
            ? ((json['v'] as List)[0] as num).toInt()
            : 0,
        awayValue: (json['v'] is List && (json['v'] as List).length > 1)
            ? ((json['v'] as List)[1] as num).toInt()
            : 0,
        unit: json['unit'] as String? ?? '',
      );
}

class MatchResult {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final int matchTime;
  final int? liveMinute;
  final String ground;
  final String round;
  final List<Goal> homeGoals;
  final List<Goal> awayGoals;
  final List<MatchStat> stats;

  const MatchResult({
    this.id = 0,
    required this.homeTeam,
    required this.awayTeam,
    this.homeFlag = '',
    this.awayFlag = '',
    this.homeScore,
    this.awayScore,
    this.status = 'scheduled',
    this.matchTime = 0,
    this.liveMinute,
    this.ground = '',
    this.round = '',
    this.homeGoals = const [],
    this.awayGoals = const [],
    this.stats = const [],
  });

  factory MatchResult.fromJson(Map json) {
    int? hs;
    int? as;
    if (json['score'] is List) {
      final scores = json['score'] as List;
      hs = scores.isNotEmpty ? (scores[0] as num).toInt() : null;
      as = scores.length > 1 ? (scores[1] as num).toInt() : null;
    } else {
      hs = json['home_score'] as int?;
      as = json['away_score'] as int?;
    }

    final homeGoals = (json['goals1'] as List?)
            ?.map((g) => Goal.fromJson(g as Map))
            .toList() ??
        [];
    final awayGoals = (json['goals2'] as List?)
            ?.map((g) => Goal.fromJson(g as Map))
            .toList() ??
        [];

    // Use goal counts for the score when goal details are available,
    // because the score field only reflects the 90-minute score
    // and doesn't include extra time goals.
    if (homeGoals.isNotEmpty || awayGoals.isNotEmpty) {
      hs = homeGoals.length;
      as = awayGoals.length;
    }

    return MatchResult(
      id: json['id'] as int? ?? 0,
      homeTeam: (json['team1'] ?? json['home_team'] ?? '') as String,
      awayTeam: (json['team2'] ?? json['away_team'] ?? '') as String,
      homeFlag: json['flag1'] as String? ?? '',
      awayFlag: json['flag2'] as String? ?? '',
      homeScore: hs,
      awayScore: as,
      status: _parseStatus(json['status'] as String? ?? 'scheduled'),
      matchTime: json['datetime'] as int? ?? 0,
      liveMinute: json['live_minute'] as int?,
      ground: json['ground'] as String? ?? '',
      round: json['round'] as String? ?? '',
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      stats: (json['stats'] as List?)
              ?.map((s) => MatchStat.fromJson(s as Map))
              .toList() ??
          [],
    );
  }

  static String _parseStatus(String s) {
    if (s == 'finished') return 'completed';
    if (s == 'live') return 'in_progress';
    return s;
  }

  bool get hasResult => homeScore != null && awayScore != null;
}

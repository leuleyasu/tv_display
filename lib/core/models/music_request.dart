import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight read model for a music request that is currently playing
/// in-venue. Only surfaces the fields the TV needs to render.
class MusicRequest {
  final String id;
  final String trackName;
  final String artistName;
  final String imageUrl;
  final String userName;
  final String? dedication;
  final DateTime? startedPlayingAt;
  final int durationSeconds;

  const MusicRequest({
    required this.id,
    required this.trackName,
    required this.artistName,
    required this.imageUrl,
    required this.userName,
    this.dedication,
    this.startedPlayingAt,
    this.durationSeconds = 180,
  });

  factory MusicRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final trackData = data['track'] is Map<String, dynamic>
        ? (data['track'] as Map<String, dynamic>)
        : <String, dynamic>{};

    final startedTs = (data['startedPlayingAt'] as Timestamp?) ??
        (data['startedAt'] as Timestamp?) ??
        (data['createdAt'] as Timestamp?);

    // Extract raw duration from all potential backend field names
    num? rawDuration = (trackData['durationMs'] as num?) ??
        (trackData['duration_ms'] as num?) ??
        (trackData['durationSeconds'] as num?) ??
        (trackData['duration_seconds'] as num?) ??
        (trackData['duration'] as num?) ??
        (data['durationMs'] as num?) ??
        (data['duration_ms'] as num?) ??
        (data['durationSeconds'] as num?) ??
        (data['duration_seconds'] as num?) ??
        (data['displayDurationSeconds'] as num?) ??
        (data['duration'] as num?);

    int durationInSec = 180; // 3 minutes fallback if track duration missing
    if (rawDuration != null && rawDuration > 0) {
      if (rawDuration > 1000) {
        durationInSec = (rawDuration / 1000).ceil();
      } else {
        durationInSec = rawDuration.toInt();
      }
    }
    durationInSec = durationInSec.clamp(5, 600);

    String trackName = (trackData['name'] as String?) ??
        (data['trackName'] as String?) ??
        (data['songName'] as String?) ??
        (data['title'] as String?) ??
        (data['track'] is String ? data['track'] as String : '');

    String artistName = (trackData['artistName'] as String?) ??
        (trackData['artist'] as String?) ??
        (data['artistName'] as String?) ??
        (data['artist'] as String?) ??
        '';

    String imageUrl = (trackData['imageUrl'] as String?) ??
        (trackData['coverUrl'] as String?) ??
        (data['imageUrl'] as String?) ??
        (data['coverUrl'] as String?) ??
        (data['albumArtUrl'] as String?) ??
        '';

    return MusicRequest(
      id: doc.id,
      trackName: trackName,
      artistName: artistName,
      imageUrl: imageUrl,
      userName: (data['userName'] as String?) ?? (data['user_name'] as String?) ?? '',
      dedication: (data['dedication'] as String?) ?? (data['message'] as String?),
      startedPlayingAt: startedTs?.toDate(),
      durationSeconds: durationInSec,
    );
  }

  bool get hasTrack => trackName.isNotEmpty || artistName.isNotEmpty;
}

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
    this.durationSeconds = 30,
  });

  factory MusicRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final trackData = data['track'] as Map<String, dynamic>? ?? {};

    final startedTs = data['startedPlayingAt'] as Timestamp?;
    final ms = (trackData['durationMs'] as num?)?.toInt() ??
        (data['durationMs'] as num?)?.toInt();

    return MusicRequest(
      id: doc.id,
      trackName: (trackData['name'] as String?) ?? '',
      artistName: (trackData['artistName'] as String?) ?? '',
      imageUrl: (trackData['imageUrl'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? '',
      dedication: data['dedication'] as String?,
      startedPlayingAt: startedTs?.toDate(),
      durationSeconds: ms != null ? (ms / 1000).ceil().clamp(10, 300) : 30,
    );
  }

  bool get hasTrack => trackName.isNotEmpty || artistName.isNotEmpty;
}

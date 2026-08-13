// import 'dart:async';
// import 'package:dio/dio.dart';
// import '../models/match_result.dart';

// class WorldCupService {
//   final Dio _dio;
//   final int refreshIntervalSec;
//   Timer? _refreshTimer;
//   StreamController<List<MatchResult>>? _controller;

//   WorldCupService({this.refreshIntervalSec = 60})
//       : _dio = Dio(BaseOptions(
//           baseUrl: 'https://wcup2026.org',
//           connectTimeout: const Duration(seconds: 10),
//           receiveTimeout: const Duration(seconds: 10),
//         ));

//   Stream<List<MatchResult>> get matchesStream {
//     _controller ??= StreamController<List<MatchResult>>.broadcast();
//     _fetchAndEmit();
//     _refreshTimer?.cancel();
//     _refreshTimer = Timer.periodic(
//       Duration(seconds: refreshIntervalSec),
//       (_) => _fetchAndEmit(),
//     );
//     return _controller!.stream;
//   }

//   Future<void> _fetchAndEmit() async {
//     try {
//       final results = await _dio.get('/api/data.php', queryParameters: {
//         'action': 'results',
//         'limit': 20,
//       });
//       final live = await _dio.get('/api/data.php', queryParameters: {
//         'action': 'live',
//       });

//       final List<MatchResult> allMatches = [];

//       void parseList(dynamic data) {
//         if (data is Map && data['matches'] is List) {
//           for (final m in data['matches']) {
//             if (m is Map) {
//               allMatches.add(MatchResult.fromJson(m));
//             }
//           }
//         }
//       }

//       if (results.data != null) parseList(results.data);
//       if (live.data != null) parseList(live.data);

//       // Sort so we can identify the most recent matches
//       allMatches.sort((a, b) => b.matchTime.compareTo(a.matchTime));

//       // Collect IDs that need detailed match data:
//       // - live/in-progress matches (for full live stats & goals)
//       // - top recent completed matches (for accurate score including extra time;
//       //   the results-list score field only reflects the 90-minute score)
//       final detailIds = <int>{};
//       for (final m in allMatches) {
//         if (m.status == 'in_progress') {
//           detailIds.add(m.id);
//         }
//       }
//       for (final m in allMatches) {
//         if (m.status == 'completed') {
//           detailIds.add(m.id);
//           if (detailIds.length >= 8) break;
//         }
//       }

//       final detailed = <int, MatchResult>{};
//       for (final id in detailIds) {
//         try {
//           final detail = await _dio.get('/api/data.php',
//               queryParameters: {'action': 'match', 'id': id});
//           if (detail.data is Map && (detail.data as Map)['match'] is Map) {
//             final m =
//                 MatchResult.fromJson((detail.data as Map)['match'] as Map);
//             detailed[id] = m;
//           }
//         } catch (_) {}
//       }

//       final merged = allMatches.map((m) {
//         if (detailed.containsKey(m.id)) {
//           return detailed[m.id]!;
//         }
//         return m;
//       }).toList();

//       merged.sort((a, b) => b.matchTime.compareTo(a.matchTime));

//       if (merged.isNotEmpty) {
//         _controller?.add(merged);
//       }
//     } catch (e) {
//       _controller?.addError(e);
//     }
//   }

//   void dispose() {
//     _refreshTimer?.cancel();
//     _controller?.close();
//   }
// }

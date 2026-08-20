import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../theme/tv_display_colors.dart';

/// Production-ready Live Video Stream Player for Match Mode.
/// Supports HLS (.m3u8), MP4, and HTTP live feeds with auto-retry on network drop.
class LiveStreamPlayerWidget extends StatefulWidget {
  final String streamUrl;
  final double scale;
  final String? venueName;
  final bool isMuted;

  const LiveStreamPlayerWidget({
    super.key,
    required this.streamUrl,
    required this.scale,
    this.venueName,
    this.isMuted = true,
  });

  @override
  State<LiveStreamPlayerWidget> createState() => _LiveStreamPlayerWidgetState();
}

class _LiveStreamPlayerWidgetState extends State<LiveStreamPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _reconnectTimer;
  int _retryAttempt = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.streamUrl);
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _reconnectTimer?.cancel();
      _disposeCurrentController();
      _initializePlayer(widget.streamUrl);
    }
  }

  void _disposeCurrentController() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  Future<void> _initializePlayer(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No stream URL provided';
      });
      return;
    }

    try {
      final uri = Uri.parse(trimmed);
      final controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _controller = controller;
      controller.addListener(_playerListener);

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);
      await controller.setLooping(true);
      await controller.play();

      setState(() {
        _isInitialized = true;
        _hasError = false;
        _retryAttempt = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Connecting to broadcast feed...';
      });
      _scheduleReconnect();
    }
  }

  void _playerListener() {
    if (!mounted || _controller == null) return;

    if (_controller!.value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = _controller!.value.errorDescription ?? 'Stream connection lost';
      });
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _retryAttempt++;
    final delay = Duration(seconds: (_retryAttempt <= 3) ? 4 : 8);

    _reconnectTimer = Timer(delay, () {
      if (mounted) {
        _disposeCurrentController();
        _initializePlayer(widget.streamUrl);
      }
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _disposeCurrentController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    if (_hasError) {
      return _buildErrorState(s);
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingState(s);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Live Video Surface
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio > 0
                ? _controller!.value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(_controller!),
          ),
        ),

        // 2. Buffering Indicator
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller!,
          builder: (context, val, child) {
            if (val.isBuffering) {
              return Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: TvDisplayColors.accentCyan,
                    size: 36 * s,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(double s) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: TvDisplayColors.accentCyan,
              size: 40 * s,
            ),
            SizedBox(height: 14 * s),
            Text(
              'TUNING INTO LIVE BROADCAST...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double s) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Color(0xFF160A1A), Color(0xFF07040B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                  width: 1.5 * s,
                ),
              ),
              child: Icon(
                Icons.wifi_tethering_error_rounded,
                color: Colors.redAccent,
                size: 36 * s,
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              'LIVE FEED RECONNECTING (Attempt #$_retryAttempt)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13 * s,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6 * s),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11 * s,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * s),
            SizedBox(
              width: 16 * s,
              height: 16 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2 * s,
                color: TvDisplayColors.accentCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

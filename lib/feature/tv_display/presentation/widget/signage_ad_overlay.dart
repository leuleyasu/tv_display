import 'package:flutter/material.dart';

class SignageAdOverlay extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final double scale;
  final double progressValue;
  final String venueName;

  const SignageAdOverlay({
    super.key,
    required this.campaign,
    required this.scale,
    required this.progressValue,
    required this.venueName,
  });

  @override
  Widget build(BuildContext context) {
    final title = (campaign['title'] as String?) ?? 'Featured Promotion';
    final caption = (campaign['caption'] as String?) ?? '';
    final mediaUrl = (campaign['mediaUrl'] as String?) ?? '';
    final mediaType = (campaign['mediaType'] as String?) ?? 'image';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      width: 1400 * scale,
      height: 780 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F1A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(
          color: const Color(0xFFFF007A).withOpacity(0.4),
          width: 3 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF007A).withOpacity(0.25),
            blurRadius: 40 * scale,
            spreadRadius: 5 * scale,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30 * scale,
            offset: Offset(0, 15 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29 * scale),
        child: Stack(
          children: [
            // Media Content Background / Viewport
            Positioned.fill(
              child: mediaType == 'image' && mediaUrl.isNotEmpty
                  ? Image.network(
                      mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF16192B),
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.white24, size: 80 * scale),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF121422),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_collection_rounded,
                                size: 100 * scale,
                                color: const Color(0xFFFF007A)),
                            SizedBox(height: 16 * scale),
                            Text(
                              'NIGHT TRACK TV VIDEO STREAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Top Header: Sponsored Tag + Venue Header
            Positioned(
              top: 24 * scale,
              left: 28 * scale,
              right: 28 * scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 18 * scale, vertical: 10 * scale),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30 * scale),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12 * scale,
                          height: 12 * scale,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF007A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        Text(
                          venueName.isNotEmpty
                              ? venueName.toUpperCase()
                              : 'SIGNAGE DISPLAY NETWORK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16 * scale, vertical: 8 * scale),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF007A), Color(0xFFA78BFA)],
                      ),
                      borderRadius: BorderRadius.circular(10 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF007A).withOpacity(0.5),
                          blurRadius: 10 * scale,
                        ),
                      ],
                    ),
                    child: Text(
                      'SPONSORED AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Overlay Bar with App Logo Branding
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(28 * scale),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // App Logo Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14 * scale, vertical: 8 * scale),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF007A), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(12 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007A).withOpacity(0.5),
                                blurRadius: 12 * scale,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tv_rounded,
                                  color: Colors.white, size: 20 * scale),
                              SizedBox(width: 8 * scale),
                              Text(
                                'NIGHT TRACK TV',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 8 * scale,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (caption.isNotEmpty) ...[
                      SizedBox(height: 10 * scale),
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 18 * scale,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Progress Bar at bottom edge
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: Colors.white10,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFF007A)),
                minHeight: 6 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

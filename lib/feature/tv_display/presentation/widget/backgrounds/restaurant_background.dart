import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Modern Luxury Daytime Champagne & Warm Slate Background for Restaurant Signage.
/// Optimized for maximum contrast, crystal-clear readability, and sunlit daytime environments.
class RestaurantBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;
  final String orgName;
  final DateTime now;
  final List<String>? customParticles;
  final dynamic customMenuItems;
  final bool showParticles;

  const RestaurantBackground({
    super.key,
    required this.box,
    required this.orbAnim,
    required this.orgName,
    required this.now,
    this.customParticles,
    this.customMenuItems,
    this.showParticles = false,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
    const primaryGold = Color(0xFFF59E0B);
    const champagneAccent = Color(0xFFFDE68A);

    return Stack(
      children: [
        // 1. Modern Multi-Stop Radial & Linear Champagne Gradient Backdrop
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.2, -0.4),
                radius: 1.4,
                colors: [
                  Color(0xFF2C241C), // Warm sunlit champagne glow
                  Color(0xFF1E1A16), // Deep warm slate
                  Color(0xFF14110E), // Ultra-rich espresso base
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // 2. Subtle Sunlit Amber Ambient Glows
        Positioned(
          top: -100 * scale,
          left: box.maxWidth * 0.15,
          width: 700 * scale,
          height: 450 * scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryGold.withValues(alpha: 0.14),
                  champagneAccent.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120 * scale,
          right: box.maxWidth * 0.2,
          width: 800 * scale,
          height: 500 * scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD97706).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // 3. Ultra-Luxury Separate Floating Header Pods (Brand Prestige Pod, Center Signature Badge & Chronos Live Time Island)
        AnimatedBuilder(
          animation: orbAnim,
          builder: (context, _) {
            final double pulse = orbAnim.value;

            return Stack(
              children: [
                // 3A. Left Floating Pod: Brand Prestige & Fine Dining Crest Island
                Positioned(
                  top: 22 * scale,
                  left: 44 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 12 * scale,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF241C16), // Deep warm obsidian
                          Color(0xFF15110E), // Espresso charcoal
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22 * scale),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(
                          alpha: 0.30 + (0.15 * pulse),
                        ),
                        width: 1.3 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.70),
                          blurRadius: 24 * scale,
                          offset: Offset(0, 10 * scale),
                        ),
                        BoxShadow(
                          color: primaryGold.withValues(
                            alpha: 0.10 + (0.08 * pulse),
                          ),
                          blurRadius: 18 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Luxury Crest Badge with multi-layer gold border & ambient glow
                        Container(
                          width: 44 * scale,
                          height: 44 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              radius: 0.9,
                              colors: [
                                Color(0xFFFFDF7A),
                                Color(0xFFF59E0B),
                                Color(0xFFB45309),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGold.withValues(
                                  alpha: 0.40 + (0.20 * pulse),
                                ),
                                blurRadius: (12 + 6 * pulse) * scale,
                                offset: Offset(0, 3 * scale),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFFFBEB),
                              width: 1.4 * scale,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: const Color(0xFF1C1308),
                              size: 22 * scale,
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * scale),

                        // Restaurant Name + Michelin Stars & Live Sub-tag
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  orgName.isNotEmpty
                                      ? orgName.toUpperCase()
                                      : 'GOURMET DINING',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22 * scale,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.8,
                                    color: const Color(0xFFFFFBEB),
                                    shadows: [
                                      Shadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.8),
                                        blurRadius: 8 * scale,
                                        offset: Offset(0, 2 * scale),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10 * scale),
                                // 3 Golden Prestige Stars
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    3,
                                    (i) => Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 1.5 * scale,
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        color: const Color(0xFFFBBF24),
                                        size: 13 * scale,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3 * scale),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Glowing Emerald Live Dot
                                Container(
                                  width: 7 * scale,
                                  height: 7 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF10B981),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color(0xFF10B981).withValues(
                                          alpha: 0.6 + (0.4 * pulse),
                                        ),
                                        blurRadius: (6 + 4 * pulse) * scale,
                                        spreadRadius: 1 * scale,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 7 * scale),
                                Text(
                                  'FINE DINING',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5 * scale,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6 * scale,
                                  ),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: const Color(0xFFFDE68A).withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 10 * scale,
                                    ),
                                  ),
                                ),
                                Text(
                                  'CHEF\'S SPECIAL SELECTION',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // // 3B. Center Floating Accent Badge: Signature Experience Pill
                // Positioned(
                //   top: 22 * scale,
                //   left: 0,
                //   right: 0,
                //   child: Center(
                //     child: Container(
                //       padding: EdgeInsets.symmetric(
                //         horizontal: 18 * scale,
                //         vertical: 9 * scale,
                //       ),
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           colors: [
                //             const Color(0xFF261D15).withValues(alpha: 0.90),
                //             const Color(0xFF18130F).withValues(alpha: 0.95),
                //           ],
                //         ),
                //         borderRadius: BorderRadius.circular(16 * scale),
                //         border: Border.all(
                //           color: const Color(0xFFFBBF24).withValues(
                //             alpha: 0.35 + (0.15 * pulse),
                //           ),
                //           width: 1.1 * scale,
                //         ),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black.withValues(alpha: 0.5),
                //             blurRadius: 18 * scale,
                //             offset: Offset(0, 8 * scale),
                //           ),
                //           BoxShadow(
                //             color: primaryGold.withValues(
                //               alpha: 0.08 + (0.06 * pulse),
                //             ),
                //             blurRadius: 12 * scale,
                //           ),
                //         ],
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(
                //             Icons.auto_awesome,
                //             size: 13 * scale,
                //             color: const Color(0xFFFBBF24),
                //           ),
                //           SizedBox(width: 8 * scale),
                //           Text(
                //             'TODAY\'S SIGNATURE MENU',
                //             style: GoogleFonts.outfit(
                //               fontSize: 11 * scale,
                //               fontWeight: FontWeight.w800,
                //               letterSpacing: 2.2,
                //               color: const Color(0xFFFFFBEB),
                //             ),
                //           ),
                //           SizedBox(width: 8 * scale),
                //           Icon(
                //             Icons.auto_awesome,
                //             size: 13 * scale,
                //             color: const Color(0xFFFBBF24),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                // 3C. Right Floating Pod: Chronos Master Live Time & Date Island
                Positioned(
                  top: 22 * scale,
                  right: 44 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 9 * scale,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF241C16),
                          Color(0xFF15110E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22 * scale),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(
                          alpha: 0.30 + (0.15 * pulse),
                        ),
                        width: 1.3 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.70),
                          blurRadius: 24 * scale,
                          offset: Offset(0, 10 * scale),
                        ),
                        BoxShadow(
                          color: primaryGold.withValues(
                            alpha: 0.10 + (0.08 * pulse),
                          ),
                          blurRadius: 18 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Live Digital Time Capsule
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale,
                            vertical: 6 * scale,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2E241B),
                                Color(0xFF1B140E),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(
                              color: const Color(0xFFFBBF24).withValues(
                                alpha: 0.45,
                              ),
                              width: 1 * scale,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGold.withValues(alpha: 0.18),
                                blurRadius: 8 * scale,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16 * scale,
                                color: const Color(0xFFFBBF24),
                              ),
                              SizedBox(width: 8 * scale),
                              Text(
                                DateFormat('HH:mm').format(now),
                                style: GoogleFonts.outfit(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFFFFFBEB),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical Golden Hairline Divider
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 14 * scale),
                          width: 1.2 * scale,
                          height: 28 * scale,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFFBBF24).withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Calendar Date & Day of Week
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('EEEE').format(now).toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            SizedBox(height: 1 * scale),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(now)
                                  .toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 12.5 * scale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 6 * scale),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

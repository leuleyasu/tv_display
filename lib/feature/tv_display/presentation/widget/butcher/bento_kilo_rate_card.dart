import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Live Weight-Based Pricing HUD Widget for Butcher Houses (ሥጋ ቤት).
/// Displays real-time market rates for 1kg, 0.5kg, 0.25kg, and popular meat cuts.
class BentoKiloRateCard extends StatelessWidget {
  final double baseKiloPrice;
  final String currency;
  final double scale;

  const BentoKiloRateCard({
    super.key,
    required this.baseKiloPrice,
    this.currency = 'ETB',
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    const primaryEmber = Color(0xFFEF4444);
    const warmAmber = Color(0xFFF59E0B);

    final tiers = [
      {
        'am': '1 ኪሎ',
        'en': '1.0 KG',
        'sub': 'ሙሉ ኪሎ (Full Kilo)',
        'price': baseKiloPrice,
        'badge': 'MOST POPULAR',
        'isHighlight': true,
      },
      {
        'am': '½ ኪሎ',
        'en': '0.5 KG',
        'sub': 'ግማሽ ኪሎ (Half Kilo)',
        'price': (baseKiloPrice * 0.52).roundToDouble(),
        'badge': null,
        'isHighlight': false,
      },
      {
        'am': '¼ ኪሎ',
        'en': '0.25 KG',
        'sub': 'ሩብ ኪሎ (Quarter)',
        'price': (baseKiloPrice * 0.27).roundToDouble(),
        'badge': null,
        'isHighlight': false,
      },
    ];

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF16100E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: primaryEmber.withValues(alpha: 0.25),
          width: 1.5 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + Live Market Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: BoxDecoration(
                      color: primaryEmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Icon(
                      Icons.scale_rounded,
                      color: primaryEmber,
                      size: 22 * scale,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'የዕለቱ የሥጋ ገበያ ዋጋ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17 * scale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'LIVE KILO RATE • 100% OX BEEF',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 5 * scale,
                ),
                decoration: BoxDecoration(
                  color: primaryEmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(
                    color: primaryEmber.withValues(alpha: 0.5),
                    width: 1 * scale,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7 * scale,
                      height: 7 * scale,
                      decoration: const BoxDecoration(
                        color: primaryEmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      'DAILY FRESH',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16 * scale),

          // Kilo Tiers
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tiers.map((tier) {
                final isHighlight = tier['isHighlight'] as bool;
                final priceVal = tier['price'] as double;
                final formattedPrice = currencyFormatter.format(priceVal.round());

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? warmAmber.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14 * scale),
                    border: Border.all(
                      color: isHighlight
                          ? warmAmber.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.07),
                      width: 1 * scale,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Weight Tag
                      Container(
                        width: 52 * scale,
                        height: 52 * scale,
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? warmAmber.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tier['am'] as String,
                          style: TextStyle(
                            color: isHighlight ? warmAmber : Colors.white,
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      // Labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tier['en'] as String,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (tier['badge'] != null) ...[
                                  SizedBox(width: 8 * scale),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6 * scale,
                                      vertical: 2 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      color: warmAmber.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6 * scale),
                                    ),
                                    child: Text(
                                      tier['badge'] as String,
                                      style: GoogleFonts.outfit(
                                        color: warmAmber,
                                        fontSize: 9 * scale,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              tier['sub'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? primaryEmber.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                            color: isHighlight
                                ? primaryEmber.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPrice,
                              style: GoogleFonts.outfit(
                                color: isHighlight ? const Color(0xFFFCA5A5) : Colors.white,
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              currency,
                              style: GoogleFonts.outfit(
                                color: warmAmber,
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 10 * scale),

          // Cuts Badges Ticker
          Wrap(
            spacing: 6 * scale,
            runSpacing: 4 * scale,
            children: [
              _buildCutChip('ጭን (Round)', 'Kurt Cut', scale),
              _buildCutChip('ጎድን (Ribs)', 'Tibs Cut', scale),
              _buildCutChip('ቀይ ሥጋ (Lean)', 'Kitfo Cut', scale),
              _buildCutCutBadge('100% FRESH', scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCutChip(String name, String role, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6 * scale),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 10 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCutCutBadge(String text, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: const Color(0xFF34D399),
          fontSize: 10 * scale,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

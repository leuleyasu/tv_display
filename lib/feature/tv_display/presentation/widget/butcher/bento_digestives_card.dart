import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Digestive Pairings & High-Margin Upsell Card for Butcher Houses (ሥጋ ቤት).
/// Highlights Ambo Mineral Water (አምቦ ውሀ), cold beers, and traditional pairings.
class BentoDigestivesCard extends StatelessWidget {
  final double scale;

  const BentoDigestivesCard({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const cyanAccent = Color(0xFF06B6D4);
    const warmAmber = Color(0xFFF59E0B);

    final items = [
      {
        'emoji': '💧',
        'nameAm': 'ቀዝቃዛ አምቦ ውሀ',
        'nameEn': 'Ambo Mineral Water',
        'sub': 'ለሥጋ መፈጨት ፍቱን (Digestive Companion)',
        'price': '60 ETB',
        'color': cyanAccent,
        'badge': 'ESSENTIAL',
      },
      {
        'emoji': '🍺',
        'nameAm': 'ቀዝቃዛ ቢራ',
        'nameEn': 'Cold Local Draft & Beers',
        'sub': 'Habesha, Walia, St. George',
        'price': '120 ETB',
        'color': warmAmber,
        'badge': 'COLD DRAFT',
      },
      {
        'emoji': '🫓',
        'nameAm': 'ትኩስ ዳቦ እና እንጀራ',
        'nameEn': 'Fresh Dabo & Injera',
        'sub': 'Warm from oven & Teff Injera',
        'price': 'INCLUDED',
        'color': const Color(0xFF10B981),
        'badge': 'FRESH BAKED',
      },
    ];

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF16100E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: cyanAccent.withValues(alpha: 0.25),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: cyanAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  Icons.local_drink_rounded,
                  color: cyanAccent,
                  size: 20 * scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ማወራረጃ እና መጠጦች',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'DIGESTIVES & BEVERAGES',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10.5 * scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12 * scale),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.map((item) {
                final color = item['color'] as Color;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1 * scale,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38 * scale,
                        height: 38 * scale,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['emoji'] as String,
                          style: TextStyle(fontSize: 18 * scale),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item['nameAm'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 6 * scale),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5 * scale,
                                    vertical: 1.5 * scale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4 * scale),
                                  ),
                                  child: Text(
                                    item['badge'] as String,
                                    style: GoogleFonts.outfit(
                                      color: color,
                                      fontSize: 8 * scale,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item['sub'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9.5 * scale,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['price'] as String,
                        style: GoogleFonts.outfit(
                          color: color,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

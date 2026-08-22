import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preparation Styles Matrix Card for Ethiopian Butcher Houses (ሥጋ ቤት).
/// Displays interactive cards for Kurt, Shekla Tibs, Special Kitfo, and Gored Gored.
class BentoPrepGrid extends StatelessWidget {
  final double scale;

  const BentoPrepGrid({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const primaryEmber = Color(0xFFEF4444);
    const warmAmber = Color(0xFFF59E0B);

    final preps = [
      {
        'emoji': '🥩',
        'titleAm': 'ጥሬ ሥጋ / ቁርት',
        'titleEn': 'Prime Kurt (Raw)',
        'pairing': 'Awaze & Senafich',
        'badge': 'RAW CUT',
        'color': primaryEmber,
      },
      {
        'emoji': '🥘',
        'titleAm': 'ልዩ ሸክላ ጥብስ',
        'titleEn': 'Sizzling Shekla Tibs',
        'pairing': 'Rosemary & Chili',
        'badge': 'CLAYPOT',
        'color': warmAmber,
      },
      {
        'emoji': '🧈',
        'titleAm': 'ልዩ ክትፎ',
        'titleEn': 'Special Kitfo',
        'pairing': 'Ayib, Gomen & Kocho',
        'badge': 'NITER KIBBEH',
        'color': const Color(0xFFFBBF24),
      },
      {
        'emoji': '🍖',
        'titleAm': 'ጎረድ ጎረድ',
        'titleEn': 'Gored Gored / Lebleb',
        'pairing': 'Warm Spiced Butter',
        'badge': 'LIGHT SEAR',
        'color': const Color(0xFFF87171),
      },
    ];

    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF16100E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: warmAmber.withValues(alpha: 0.25),
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
                  color: warmAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: warmAmber,
                  size: 20 * scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የአዘገጃጀት አማራጮች',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'PREPARATION STYLES & SIDES',
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

          SizedBox(height: 12 * scale),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10 * scale,
              crossAxisSpacing: 10 * scale,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: preps.map((prep) {
                final color = prep['color'] as Color;

                return Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14 * scale),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1 * scale,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prep['emoji'] as String,
                            style: TextStyle(fontSize: 18 * scale),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6 * scale,
                              vertical: 2 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6 * scale),
                            ),
                            child: Text(
                              prep['badge'] as String,
                              style: GoogleFonts.outfit(
                                color: color,
                                fontSize: 8.5 * scale,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prep['titleAm'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            prep['pairing'] as String,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10 * scale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

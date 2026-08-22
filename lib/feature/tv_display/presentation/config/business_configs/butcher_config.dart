import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content, meat cuts, and default data configuration for Butcher House (ሥጋ ቤት) business type.
class ButcherTvConfig {
  static const String typeId = 'butcher';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.outdoor_grill_rounded, label: 'ልዩ ሸክላ ጥብስ • Sizzling Tibs'),
    IdleSuggestion(icon: Icons.restaurant_rounded, label: 'ጥሬ ሥጋ እና ቁርት • Prime Kurt'),
    IdleSuggestion(icon: Icons.soup_kitchen_rounded, label: 'ልዩ ክትፎ • Special Kitfo'),
    IdleSuggestion(icon: Icons.local_drink_rounded, label: 'ቀዝቃዛ አምቦ ውሀ • Ambo Water'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '🔥',
      headline: 'ልዩ ሸክላ ጥብስ (Shekla Tibs)',
      subtitle: 'Sizzling hot claypot tender ox beef seared with fresh rosemary, garlic, sliced onions, and green chilies.',
      category: 'SIZZLING CLAYPOT',
      imageUrl: 'assets/images/shekla_tibs.jpg',
      price: 2200,
      currency: 'ETB',
      pairingNote: 'Best paired with ice-cold Ambo Mineral Water & fresh Dabo',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '🥩',
      headline: 'ጥሬ ሥጋ / ቁርት (Prime Kurt)',
      subtitle: '100% Fresh morning slaughter prime Harar/Chercher ox beef cut to perfection, served with spicy Awaze & Senafich.',
      category: 'RAW SELECTION',
      imageUrl: 'assets/images/kurt_siga.jpg',
      price: 2200,
      currency: 'ETB',
      pairingNote: 'Served with house Awaze, Senafich & Mitmita',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '🧈',
      headline: 'ልዩ ክትፎ (Special Kitfo)',
      subtitle: 'Finely minced lean beef infused with aromatic spiced Niter Kibbeh & Mitmita, served with Ayib, Gomen & Kocho.',
      category: 'TRADITIONAL GOURMET',
      imageUrl: 'assets/images/special_kitfo.jpg',
      price: 2400,
      currency: 'ETB',
      pairingNote: 'Garnished with fresh Ayib (cottage cheese) & Kocho',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '🍖',
      headline: 'ጎረድ ጎረድ (Gored Gored)',
      subtitle: 'Succulent cubes of tender raw beef tossed in warm spiced butter and Awaze paste.',
      category: 'RAW SELECTION',
      imageUrl: 'assets/images/kurt_siga.jpg',
      price: 2200,
      currency: 'ETB',
      pairingNote: 'Served with warm Niter Kibbeh & Dabo',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '💧',
      headline: 'ቀዝቃዛ አምቦ ውሀ (Ambo Water)',
      subtitle: 'Naturally sparkling Ethiopian mineral water — the essential digestion companion for meat dishes.',
      category: 'DIGESTIVES & BEVERAGES',
      imageUrl: 'assets/images/ambo_water.jpg',
      price: 60,
      currency: 'ETB',
      pairingNote: 'Essential digestive companion for meat dishes',
      suggestionIndex: 3,
    ),
  ];

  /// Standard weight multipliers for butcher houses
  static const List<Map<String, dynamic>> defaultKiloTiers = [
    {
      'labelAmharic': '1 ኪሎ',
      'labelEn': '1.0 KG',
      'multiplier': 1.0,
      'badge': 'FULL KILO',
      'isPopular': true,
    },
    {
      'labelAmharic': '½ ኪሎ',
      'labelEn': '0.5 KG',
      'multiplier': 0.5,
      'badge': 'HALF KILO',
      'isPopular': false,
    },
    {
      'labelAmharic': '¼ ኪሎ',
      'labelEn': '0.25 KG',
      'multiplier': 0.25,
      'badge': 'QUARTER',
      'isPopular': false,
    },
  ];

  /// Popular meat cuts highlighted on the TV
  static const List<Map<String, String>> popularCuts = [
    {'am': 'ጭን (Round)', 'desc': 'Ideal for Kurt & Raw cuts'},
    {'am': 'ጎድን (Ribs)', 'desc': 'Juicy & tender for Shekla Tibs'},
    {'am': 'ቀይ ሥጋ (Lean)', 'desc': 'Finest cut for Special Kitfo'},
    {'am': 'ፍርምባ (Brisket)', 'desc': 'Rich flavor for Tibs & Lebleb'},
  ];
}

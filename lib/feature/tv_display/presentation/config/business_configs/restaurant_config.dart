import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content and theme configuration for Restaurant business type.
class RestaurantTvConfig {
  static const String typeId = 'restaurant';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [];

  static const List<IdleSlide> defaultSlides = [];
}

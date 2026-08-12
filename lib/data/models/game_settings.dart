import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';
import 'movie.dart';

enum IndustryFilter { bollywood, hollywood, both }

extension IndustryFilterX on IndustryFilter {
  String get label {
    switch (this) {
      case IndustryFilter.bollywood:
        return 'Bollywood';
      case IndustryFilter.hollywood:
        return 'Hollywood';
      case IndustryFilter.both:
        return 'Both';
    }
  }

  bool matches(MovieIndustry industry) {
    switch (this) {
      case IndustryFilter.bollywood:
        return industry == MovieIndustry.bollywood;
      case IndustryFilter.hollywood:
        return industry == MovieIndustry.hollywood;
      case IndustryFilter.both:
        return true;
    }
  }
}

class GameSettings extends Equatable {
  const GameSettings({
    this.timerMinutes = AppConstants.defaultTimerMinutes,
    this.industry = IndustryFilter.both,
    this.startYear = AppConstants.minYear,
    this.endYear,
    this.hintCount = AppConstants.defaultHintCount,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final int timerMinutes; // 0 = unlimited
  final IndustryFilter industry;
  final int startYear;
  final int? endYear;
  final int hintCount;
  final bool soundEnabled;
  final bool hapticsEnabled;

  int get resolvedEndYear => endYear ?? AppConstants.maxYear;

  Duration? get timerDuration {
    if (timerMinutes <= 0) return null;
    return Duration(minutes: timerMinutes);
  }

  GameSettings copyWith({
    int? timerMinutes,
    IndustryFilter? industry,
    int? startYear,
    int? endYear,
    int? hintCount,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return GameSettings(
      timerMinutes: timerMinutes ?? this.timerMinutes,
      industry: industry ?? this.industry,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      hintCount: hintCount ?? this.hintCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'timerMinutes': timerMinutes,
        'industry': industry.name,
        'startYear': startYear,
        'endYear': resolvedEndYear,
        'hintCount': hintCount,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      timerMinutes: json['timerMinutes'] as int? ?? AppConstants.defaultTimerMinutes,
      industry: IndustryFilter.values.firstWhere(
        (e) => e.name == json['industry'],
        orElse: () => IndustryFilter.both,
      ),
      startYear: json['startYear'] as int? ?? AppConstants.minYear,
      endYear: json['endYear'] as int? ?? AppConstants.maxYear,
      hintCount: (json['hintCount'] as int? ?? AppConstants.defaultHintCount)
          .clamp(0, AppConstants.maxHints),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        timerMinutes,
        industry,
        startYear,
        resolvedEndYear,
        hintCount,
        soundEnabled,
        hapticsEnabled,
      ];
}

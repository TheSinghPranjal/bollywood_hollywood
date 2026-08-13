import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Movie Guess';
  static const String tagline = 'BOLLYWOOD • HOLLYWOOD';

  static const int maxLives = 10;
  static const int maxHints = 4;
  static const int defaultHintCount = 4;
  static const int defaultTimerMinutes = 10;
  static const int minYear = 1990;

  static int get maxYear => DateTime.now().year;

  static const List<String> lifeCharsBollywood = [
    'B',
    'O',
    'L',
    'L',
    'Y',
    '-',
    'W',
    'O',
    'O',
    'D',
  ];

  static const List<String> lifeCharsHollywood = [
    'H',
    'O',
    'L',
    'L',
    'Y',
    '-',
    'W',
    'O',
    'O',
    'D',
  ];

  /// Wrong-guess counts that unlock hints 1–4 (when configured).
  static const List<int> hintTriggerWrongCounts = [6, 7, 8, 9];

  static const List<String> consonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static const Set<String> vowels = {'A', 'E', 'I', 'O', 'U'};

  static const String moviesAssetPath = 'assets/data/movies.json';
  static const String settingsKey = 'game_settings_v1';
  static const String recentMoviesKey = 'recent_movies_v1';
  static const int recentMoviesLimit = 40;

  static const List<int> timerOptionsMinutes = [2, 5, 10, 15, 20, 30, 0];

  /// Show an interstitial only on every Nth Next Round tap.
  static const int interstitialEveryNRounds = 5;

  /// Always use Google's official sample IDs during development.
  static const bool isAdTestMode = true;

  static const String androidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId =
      'ca-app-pub-3940256099942544~1458002511';
  static const String androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedTestId =
      'ca-app-pub-3940256099942544/1712484513';
  static const String androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';

  static const double bannerAdHeight = 50;

  static bool get adsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? iosBannerTestId
          : androidBannerTestId;

  static String get rewardedAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? iosRewardedTestId
          : androidRewardedTestId;

  static String get interstitialAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? iosInterstitialTestId
          : androidInterstitialTestId;
}

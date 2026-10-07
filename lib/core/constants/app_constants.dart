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

  /// Extra quiet period so several fast rounds cannot stack interstitials.
  static const Duration interstitialMinimumInterval = Duration(seconds: 90);

  static const double bannerAdHeight = 50;
}

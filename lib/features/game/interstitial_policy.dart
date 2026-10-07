import '../../core/constants/app_constants.dart';

/// When a "Next round" tap may show an interstitial.
///
/// Requires both a round cadence and a minimum quiet period so fast rounds
/// cannot stack full-screen ads.
class InterstitialPolicy {
  InterstitialPolicy._();

  static bool shouldShow({
    required bool fromNextRound,
    required bool skipNext,
    required int roundsPlayed,
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (!fromNextRound || skipNext) return false;
    if (roundsPlayed <= 0 ||
        roundsPlayed % AppConstants.interstitialEveryNRounds != 0) {
      return false;
    }
    final last = lastShownAt;
    if (last != null &&
        now.difference(last) < AppConstants.interstitialMinimumInterval) {
      return false;
    }
    return true;
  }
}

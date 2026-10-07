import 'package:bollywood_hollywood/core/constants/app_constants.dart';
import 'package:bollywood_hollywood/features/game/interstitial_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 1, 1, 12);

  bool show({
    bool fromNextRound = true,
    bool skipNext = false,
    int roundsPlayed = 5,
    DateTime? lastShownAt,
  }) {
    return InterstitialPolicy.shouldShow(
      fromNextRound: fromNextRound,
      skipNext: skipNext,
      roundsPlayed: roundsPlayed,
      lastShownAt: lastShownAt,
      now: now,
    );
  }

  test('shows on every 5th next-round tap after a quiet period', () {
    expect(show(roundsPlayed: 5), isTrue);
    expect(show(roundsPlayed: 10), isTrue);
    expect(show(roundsPlayed: 4), isFalse);
    expect(show(roundsPlayed: 0), isFalse);
    expect(show(fromNextRound: false), isFalse);
    expect(show(skipNext: true), isFalse);
  });

  test('skips when the previous interstitial was too recent', () {
    expect(
      show(lastShownAt: now.subtract(const Duration(seconds: 30))),
      isFalse,
    );
    expect(
      show(lastShownAt: now.subtract(AppConstants.interstitialMinimumInterval)),
      isTrue,
    );
  });
}

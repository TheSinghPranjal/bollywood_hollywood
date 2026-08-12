import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_status.dart';
import '../../data/models/movie.dart';
import '../game/game_controller.dart';

Future<void> showWinDialog(BuildContext context, WidgetRef ref) {
  final session = ref.read(gameControllerProvider).session;
  if (session == null) return Future.value();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('YOU GOT IT!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              session.movie.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.movie.industry.label} · ${session.movie.year}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'SCORE ${session.score}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(gameControllerProvider.notifier).nextRound();
            },
            child: const Text('NEXT ROUND'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).clearSession();
              Navigator.pop(context);
            },
            child: const Text('HOME'),
          ),
        ],
      );
    },
  );
}

Future<void> showLoseDialog(BuildContext context, WidgetRef ref) {
  final state = ref.read(gameControllerProvider);
  final session = state.session;
  if (session == null) return Future.value();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          final live = ref.watch(gameControllerProvider);
          final s = live.session;
          if (s == null) return const SizedBox.shrink();

          // If rewarded life restored play, close dialog.
          if (s.status == GameStatus.extraLifePlaying ||
              s.status == GameStatus.playing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            });
          }

          final adError = live.adErrorMessage;

          return AlertDialog(
            title: Text(adError != null ? 'Reward Failed' : 'GAME OVER'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (adError != null)
                  Text(adError, textAlign: TextAlign.center)
                else ...[
                  const Text('The movie was:'),
                  const SizedBox(height: 8),
                  Text(
                    s.movie.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              if (adError != null) ...[
                TextButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).clearAdError();
                    ref.read(gameControllerProvider.notifier).watchRewardedAd();
                  },
                  child: const Text('TRY AGAIN'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref.read(gameControllerProvider.notifier).clearSession();
                    Navigator.pop(context);
                  },
                  child: const Text('END GAME'),
                ),
              ] else ...[
                if (s.canOfferRewardedLife)
                  TextButton(
                    onPressed: () {
                      ref.read(gameControllerProvider.notifier).watchRewardedAd();
                    },
                    child: const Text('WATCH AD +1 LIFE'),
                  ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await ref.read(gameControllerProvider.notifier).nextRound();
                  },
                  child: const Text('NEXT ROUND'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref.read(gameControllerProvider.notifier).clearSession();
                    Navigator.pop(context);
                  },
                  child: const Text('HOME'),
                ),
              ],
            ],
          );
        },
      );
    },
  );
}

Future<void> showPauseDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('GAME PAUSED'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).resume();
            },
            child: const Text('RESUME'),
          ),
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: dialogContext,
                builder: (c) => AlertDialog(
                  title: const Text('Restart this round?'),
                  content: const Text('Your current progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('RESTART'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                Navigator.pop(dialogContext);
                await ref.read(gameControllerProvider.notifier).startNewRound();
              }
            },
            child: const Text('RESTART'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).clearSession();
              Navigator.pop(context);
            },
            child: const Text('EXIT TO HOME'),
          ),
        ],
      );
    },
  );
}

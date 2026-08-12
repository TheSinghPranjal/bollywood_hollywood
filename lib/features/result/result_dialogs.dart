import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_status.dart';
import '../../data/models/movie.dart';
import '../game/game_controller.dart';

const Color _gold = Color(0xFFE4C15A);

Future<void> showWinDialog(BuildContext context, WidgetRef ref) {
  final session = ref.read(gameControllerProvider).session;
  if (session == null) return Future.value();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'You got it',
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _WinResultCard(
        title: session.movie.title,
        industry: session.movie.industry.label,
        year: session.movie.year,
        score: session.score,
        onNextRound: () async {
          Navigator.pop(dialogContext);
          await ref.read(gameControllerProvider.notifier).nextRound();
        },
        onHome: () {
          Navigator.pop(dialogContext);
          ref.read(gameControllerProvider.notifier).clearSession();
          Navigator.pop(context);
        },
      );
    },
    transitionBuilder: (context, anim, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
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

class _WinResultCard extends StatelessWidget {
  const _WinResultCard({
    required this.title,
    required this.industry,
    required this.year,
    required this.score,
    required this.onNextRound,
    required this.onHome,
  });

  final String title;
  final String industry;
  final int year;
  final int score;
  final VoidCallback onNextRound;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF221A38), Color(0xFF14101F)],
                ),
                border: Border.all(color: _gold.withValues(alpha: 0.9), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.28),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                    child: Column(
                      children: [
                        const Text(
                          'YOU GOT IT!',
                          style: TextStyle(
                            color: Color(0xFFF7F4EE),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _gold,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: _gold.withValues(alpha: 0.55),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$industry  •  $year',
                          style: const TextStyle(
                            color: Color(0xFFE8E0D2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(
                          height: 18,
                          width: double.infinity,
                          child: CustomPaint(painter: _SparkleDividerPainter()),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            color: Color(0xFFB7B1C7),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _gold.withValues(alpha: 0.28),
                  ),
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Expanded(
                          child: _FooterAction(
                            label: 'NEXT ROUND',
                            onTap: onNextRound,
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: _gold.withValues(alpha: 0.28),
                        ),
                        Expanded(
                          child: _FooterAction(
                            label: 'HOME',
                            onTap: onHome,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: _gold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SparkleDividerPainter extends CustomPainter {
  const _SparkleDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final mid = size.width / 2;
    final line = Paint()
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        colors: [
          _gold.withValues(alpha: 0),
          _gold.withValues(alpha: 0.95),
          _gold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(8, cy), Offset(mid - 14, cy), line);
    canvas.drawLine(Offset(mid + 14, cy), Offset(size.width - 8, cy), line);

    final c = Offset(mid, cy);
    const r = 6.5;
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      final outer = Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r);
      final innerAngle = angle + math.pi / 4;
      final inner = Offset(
        c.dx + math.cos(innerAngle) * (r * 0.28),
        c.dy + math.sin(innerAngle) * (r * 0.28),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

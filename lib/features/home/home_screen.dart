import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../game/game_screen.dart';
import '../how_to_play/how_to_play_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _mustard = Color(0xFFD4AF37);
  static const Color _cream = Color(0xFFF4EFE4);
  static const Color _bollywoodGold = Color(0xFFC9A24A);
  static const Color _hollywoodTeal = Color(0xFF5EC8C0);
  static const Color _settingsRose = Color(0xFFC9A8B8);
  static const Color _frameBorder = Color(0x33FFFFFF);

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    await ref.read(gameControllerProvider.notifier).startNewRound();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF08070C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14101C),
              Color(0xFF0A090F),
              Color(0xFF07060A),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              left: -70,
              child: _AmbientGlow(
                color: Color(0x552D1B4D),
                size: 280,
              ),
            ),
            const Positioned(
              top: -20,
              right: -40,
              child: IgnorePointer(child: _FilmStripGraphic()),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _frameBorder, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.88, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: const _GoldReelBadge(),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'MOVIE GUESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _cream,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'BOLLYWOOD',
                                style: TextStyle(color: _bollywoodGold),
                              ),
                              TextSpan(
                                text: '  •  ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'HOLLYWOOD',
                                style: TextStyle(color: _hollywoodTeal),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _SparkleDivider(),
                        const SizedBox(height: 18),
                        const Text(
                          'GUESS THE MOVIE.\nBEAT THE CLOCK.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE8E0D2),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                            height: 1.55,
                          ),
                        ),
                        const Spacer(flex: 3),
                        _HomeActionButton(
                          filled: true,
                          color: _mustard,
                          foreground: Colors.black,
                          icon: Icons.play_arrow_rounded,
                          label: 'PLAY GAME',
                          onPressed: () => _play(context, ref),
                        ),
                        const SizedBox(height: 14),
                        _HomeActionButton(
                          filled: false,
                          color: _settingsRose,
                          foreground: _settingsRose,
                          icon: Icons.settings_outlined,
                          label: 'SETTINGS',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _HomeActionButton(
                          filled: false,
                          color: _hollywoodTeal,
                          foreground: _hollywoodTeal,
                          icon: Icons.help_outline_rounded,
                          label: 'HOW TO PLAY',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HowToPlayScreen(),
                              ),
                            );
                          },
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 90, spreadRadius: 50),
        ],
      ),
    );
  }
}

class _GoldReelBadge extends StatelessWidget {
  const _GoldReelBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.38),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(painter: _FilmReelPainter()),
    );
  }
}

class _FilmReelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF3D27A),
          Color(0xFFD4AF37),
          Color(0xFFB8902A),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    final fillPaint = Paint()
      ..color = const Color(0xFF1A140C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 3.5, fillPaint);
    canvas.drawCircle(center, radius - 3.5, ringPaint);

    final innerRing = Paint()
      ..color = const Color(0xFFE8C45A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, radius * 0.62, innerRing);

    final hubPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF0D070), Color(0xFFC9A24A)],
      ).createShader(Rect.fromCircle(center: center, radius: 10));
    canvas.drawCircle(center, 9, hubPaint);

    final spokePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final inner = Offset(
        center.dx + math.cos(angle) * 16,
        center.dy + math.sin(angle) * 16,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius * 0.52),
        center.dy + math.sin(angle) * (radius * 0.52),
      );
      canvas.drawLine(inner, outer, spokePaint);
    }

    final holePaint = Paint()..color = const Color(0xFF0C0A10);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + math.pi / 6;
      final hole = Offset(
        center.dx + math.cos(angle) * (radius * 0.36),
        center.dy + math.sin(angle) * (radius * 0.36),
      );
      canvas.drawCircle(hole, 6.5, holePaint);
      canvas.drawCircle(
        hole,
        6.5,
        Paint()
          ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleDivider extends StatelessWidget {
  const _SparkleDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: CustomPaint(
        painter: _SparkleDividerPainter(),
        size: const Size(double.infinity, 18),
      ),
    );
  }
}

class _SparkleDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final mid = size.width / 2;
    final line = Paint()
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        colors: [
          const Color(0x00D4AF37),
          const Color(0xFFD4AF37).withValues(alpha: 0.9),
          const Color(0x00D4AF37),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(8, cy), Offset(mid - 16, cy), line);
    canvas.drawLine(Offset(mid + 16, cy), Offset(size.width - 8, cy), line);

    final sparkle = Paint()..color = const Color(0xFFE8C45A);
    _drawStar(canvas, Offset(mid, cy), 7.5, sparkle);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FilmStripGraphic extends StatelessWidget {
  const _FilmStripGraphic();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.42,
      child: Opacity(
        opacity: 0.22,
        child: CustomPaint(
          size: const Size(260, 170),
          painter: _FilmStripPainter(),
        ),
      ),
    );
  }
}

class _FilmStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strip = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 20, size.width, 88),
      const Radius.circular(8),
    );
    final fill = Paint()..color = const Color(0xFF3A2458);
    canvas.drawRRect(strip, fill);

    final hole = Paint()..color = const Color(0xFF0A090F);
    for (var i = 0; i < 9; i++) {
      final x = 14.0 + i * 28;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 28, 10, 14),
          const Radius.circular(2),
        ),
        hole,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 86, 10, 14),
          const Radius.circular(2),
        ),
        hole,
      );
    }

    final frame = Paint()
      ..color = const Color(0xFF241536)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18 + i * 60.0, 48, 48, 28),
          const Radius.circular(3),
        ),
        frame,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeActionButton extends StatefulWidget {
  const _HomeActionButton({
    required this.filled,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool filled;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<_HomeActionButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final child = widget.filled
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: radius,
            ),
            child: _content(),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: widget.color, width: 1.5),
            ),
            child: _content(),
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(width: double.infinity, height: 56, child: child),
      ),
    );
  }

  Widget _content() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: widget.foreground, size: 22),
          const SizedBox(width: 10),
          Text(
            widget.label,
            style: TextStyle(
              color: widget.foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

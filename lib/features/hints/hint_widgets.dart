import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HintButton extends StatefulWidget {
  const HintButton({
    super.key,
    required this.visible,
    required this.blink,
    required this.onTap,
  });

  final bool visible;
  final bool blink;
  final VoidCallback onTap;

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant HintButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink && !oldWidget.blink) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 0.25), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.25, end: 1), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1, end: 0.25), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.25, end: 1), weight: 1),
        ]).animate(_ctrl),
        child: Material(
          color: AppColors.gold,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: AppColors.gold.withValues(alpha: 0.6),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.lightbulb, color: Colors.black, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showHintDialog({
  required BuildContext context,
  required List<String> hints,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: AppColors.gold),
            SizedBox(width: 8),
            Text('HINT'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: hints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hint ${index + 1}',
                      style: const TextStyle(
                        color: AppColors.goldSoft,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hints[index],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('GOT IT'),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Reserved bottom ad slot. Uses a test placeholder in development so layout
/// stays stable without requiring AdMob SDK initialization on every platform.
class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: AppConstants.bannerAdHeight,
        width: double.infinity,
        alignment: Alignment.center,
        color: AppColors.surface,
        child: Text(
          AppConstants.isAdTestMode
              ? 'TEST BANNER AD'
              : 'AD',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

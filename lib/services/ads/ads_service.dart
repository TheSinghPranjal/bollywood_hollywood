import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/ad_config.dart';

abstract class AdsService {
  Future<void> initialize();
  Future<bool> showRewardedAd();
  Future<bool> showInterstitial();
  bool get isInitialized;

  /// True when UMP requires a privacy-options entry point (EEA/UK and similar).
  Future<bool> get privacyOptionsRequired;

  Future<void> showPrivacyOptions();
}

/// Used in widget tests and on platforms where AdMob is unavailable.
class FakeAdsService implements AdsService {
  FakeAdsService({
    this.rewardedSucceeds = true,
    this.interstitialSucceeds = true,
  });

  bool rewardedSucceeds;
  bool interstitialSucceeds;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<bool> showRewardedAd() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return rewardedSucceeds;
  }

  @override
  Future<bool> showInterstitial() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return interstitialSucceeds;
  }

  @override
  Future<bool> get privacyOptionsRequired async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}

/// Real AdMob implementation.
///
/// Debug and profile builds request Google sample units. Release builds
/// request the production units from [AdConfig]. Mobile Ads is initialized
/// only after the UMP consent update.
class MobileAdsService implements AdsService {
  MobileAdsService({required this.isTestMode});

  final bool isTestMode;
  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  Completer<RewardedAd?>? _rewardedLoad;
  Completer<InterstitialAd?>? _interstitialLoad;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (!AdConfig.adsSupported) {
      _initialized = false;
      AdConfig.canRequestAds = false;
      return;
    }
    try {
      await _gatherConsent();
      final allowed = await ConsentInformation.instance.canRequestAds();
      AdConfig.canRequestAds = allowed;
      if (!allowed) {
        debugPrint(
          'AdMob: canRequestAds=false after consent. Ads will not load.',
        );
        _initialized = false;
        return;
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint(
        'AdMob ${isTestMode ? 'TEST' : 'RELEASE'} ready '
        'banner=${AdConfig.bannerAdUnitId} '
        'interstitial=${AdConfig.interstitialAdUnitId} '
        'rewarded=${AdConfig.rewardedAdUnitId}',
      );
      unawaited(_loadRewarded());
      unawaited(_loadInterstitial());
    } catch (error, stack) {
      debugPrint('AdMob initialize failed: $error\n$stack');
      _initialized = false;
      AdConfig.canRequestAds = false;
    }
  }

  /// UMP consent before the first ad request. A failed or slow update must not
  /// hang startup; [ConsentInformation.canRequestAds] decides whether to init.
  Future<void> _gatherConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) {
              debugPrint('Consent form dismissed with error: ${error.message}');
            }
          });
        } catch (error) {
          debugPrint('Consent form failed: $error');
        }
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint(
          'Consent info update failed: ${error.message} (${error.errorCode})',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('Consent request timed out; continuing.');
      },
    );
  }

  @override
  Future<bool> get privacyOptionsRequired async {
    if (!AdConfig.adsSupported) return false;
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      debugPrint('Privacy options status failed: $error');
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() {
    return ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) {
        debugPrint('Privacy options form error: ${error.message}');
      }
    });
  }

  AdRequest get _request => const AdRequest();

  Future<RewardedAd?> _loadRewarded() {
    if (_rewardedAd != null) return Future.value(_rewardedAd);
    if (_rewardedLoad != null) return _rewardedLoad!.future;

    final completer = Completer<RewardedAd?>();
    _rewardedLoad = completer;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: $error');
          _rewardedAd = null;
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _rewardedLoad = null;
        return null;
      },
    );
  }

  Future<InterstitialAd?> _loadInterstitial() {
    if (_interstitialAd != null) return Future.value(_interstitialAd);
    if (_interstitialLoad != null) return _interstitialLoad!.future;

    final completer = Completer<InterstitialAd?>();
    _interstitialLoad = completer;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _interstitialLoad = null;
        return null;
      },
    );
  }

  @override
  Future<bool> showRewardedAd() async {
    if (!_initialized) return false;
    var ad = _rewardedAd;
    ad ??= await _loadRewarded();
    if (ad == null) {
      ad = await _loadRewarded();
    }
    if (ad == null) return false;
    _rewardedAd = null;

    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad shown');
      },
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        // iOS often fires dismiss before onUserEarnedReward.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!completer.isCompleted) completer.complete(earned);
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadRewarded());
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          earned = true;
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (error) {
      debugPrint('Rewarded show threw: $error');
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
      unawaited(_loadRewarded());
      return false;
    }

    return completer.future;
  }

  @override
  Future<bool> showInterstitial() async {
    if (!_initialized) return false;
    var ad = _interstitialAd ?? await _loadInterstitial();
    if (ad == null) return false;
    _interstitialAd = null;

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(true);
        unawaited(_loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadInterstitial());
      },
    );
    try {
      await ad.show();
    } catch (error) {
      debugPrint('Interstitial show threw: $error');
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
      unawaited(_loadInterstitial());
      return false;
    }
    return completer.future;
  }
}

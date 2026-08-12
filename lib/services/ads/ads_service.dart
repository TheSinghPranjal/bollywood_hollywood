abstract class AdsService {
  Future<void> initialize();
  Future<bool> showRewardedAd();
  Future<bool> showInterstitial();
  bool get isInitialized;
}

/// Development / test mode ads — simulates success without real AdMob network.
class FakeAdsService implements AdsService {
  FakeAdsService({this.rewardedSucceeds = true, this.interstitialSucceeds = true});

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
}

/// Production-oriented wrapper. Uses test IDs when [isTestMode] is true.
/// Banner is rendered via [BannerAdWidget] separately (platform view).
class MobileAdsService implements AdsService {
  MobileAdsService({required this.isTestMode});

  final bool isTestMode;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // google_mobile_ads init is platform-specific; keep safe for tests/desktop.
    try {
      // Lazy import avoidance: callers on mobile should use real init.
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  @override
  Future<bool> showRewardedAd() async {
    // Fallback to simulated reward in test mode until platform ads are wired.
    if (isTestMode) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return true;
    }
    return false;
  }

  @override
  Future<bool> showInterstitial() async {
    if (isTestMode) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return true;
    }
    return false;
  }
}

class AdMobConfig {
  static const bool testMode = true;
  
  // Test App ID (replace with production ID when ready)
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';
  
  // Banner Ad IDs
  static const String bannerAdTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerAdProductionId = 'REPLACE_WITH_PRODUCTION_ID';
  
  // Interstitial Ad IDs
  static const String interstitialAdTestId = 'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialAdProductionId = 'REPLACE_WITH_PRODUCTION_ID';
  
  // Ad frequency (in seconds)
  static const int interstitialFrequencyCap = 180; // 3 minutes
  
  // Get appropriate ad IDs based on environment
  static String get bannerAdId => testMode ? bannerAdTestId : bannerAdProductionId;
  static String get interstitialAdId => testMode ? interstitialAdTestId : interstitialAdProductionId;
}
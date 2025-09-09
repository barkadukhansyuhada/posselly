import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/admob_config.dart';

class AdMobService {
  static AdMobService? _instance;
  
  AdMobService._();
  
  static AdMobService get instance {
    _instance ??= AdMobService._();
    return _instance!;
  }
  
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  DateTime? _lastInterstitialShown;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadLastInterstitialTime();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
          _interstitialAd = null;
          
          // Retry loading after 30 seconds
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_canShowInterstitialAd()) {
      return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          debugPrint('InterstitialAd showed fullscreen content.');
          _lastInterstitialShown = DateTime.now();
          _saveLastInterstitialTime();
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('InterstitialAd dismissed fullscreen content.');
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('InterstitialAd failed to show fullscreen content: $error');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    }
  }

  bool _canShowInterstitialAd() {
    if (_lastInterstitialShown == null) {
      return true;
    }
    
    final difference = DateTime.now().difference(_lastInterstitialShown!);
    return difference.inSeconds >= AdMobConfig.interstitialFrequencyCap;
  }

  Future<void> _loadLastInterstitialTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('last_interstitial_shown');
      if (timestamp != null) {
        _lastInterstitialShown = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      debugPrint('Failed to load last interstitial time: $e');
    }
  }

  Future<void> _saveLastInterstitialTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_interstitial_shown',
        _lastInterstitialShown?.millisecondsSinceEpoch ?? 0,
      );
    } catch (e) {
      debugPrint('Failed to save last interstitial time: $e');
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

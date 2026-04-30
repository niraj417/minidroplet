import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../constant/app_export.dart';
import '../ad_unit_id.dart';

class AdInterstitialService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  // Load Interstitial Ad
  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdUnitId.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          debugPrint('Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load interstitial ad: $error');
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showAd({required Function onAdClosed}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad Dismissed');
          ad.dispose();
          loadAd(); // Preload another ad
          onAdClosed(); // Execute callback after ad is closed
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show interstitial ad: $error');
          ad.dispose();
          loadAd(); // Preload another ad
          onAdClosed(); // Execute callback if ad fails
        },
      );
      _interstitialAd!.show();
      _isAdLoaded = false; // Prevent showing the same ad multiple times
    } else {
      debugPrint('Interstitial Ad not ready');
      onAdClosed(); // Directly call if ad is not ready
    }
  }

  // Dispose Ad
  void dispose() {
    _interstitialAd?.dispose();
  }
}

/*
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../constant/app_export.dart';
import '../ad_unit_id.dart';

enum AdStatus {
  enabled,
  disabled,
  loading,
  error,
}

class AdState extends Equatable {
  final AdStatus bannerAdStatus;
  final AdStatus interstitialAdStatus;
  final BannerAd? bannerAd;
  final bool isBannerAdLoaded;
  final bool isInterstitialAdLoaded;
  final String errorMessage;

  const AdState({
    this.bannerAdStatus = AdStatus.loading,
    this.interstitialAdStatus = AdStatus.loading,
    this.bannerAd,
    this.isBannerAdLoaded = false,
    this.isInterstitialAdLoaded = false,
    this.errorMessage = '',
  });

  AdState copyWith({
    AdStatus? bannerAdStatus,
    AdStatus? interstitialAdStatus,
    BannerAd? bannerAd,
    bool? isBannerAdLoaded,
    bool? isInterstitialAdLoaded,
    String? errorMessage,
  }) {
    return AdState(
      bannerAdStatus: bannerAdStatus ?? this.bannerAdStatus,
      interstitialAdStatus: interstitialAdStatus ?? this.interstitialAdStatus,
      bannerAd: bannerAd ?? this.bannerAd,
      isBannerAdLoaded: isBannerAdLoaded ?? this.isBannerAdLoaded,
      isInterstitialAdLoaded: isInterstitialAdLoaded ?? this.isInterstitialAdLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    bannerAdStatus,
    interstitialAdStatus,
    bannerAd,
    isBannerAdLoaded,
    isInterstitialAdLoaded,
    errorMessage,
  ];
}

class AdCubit extends Cubit<AdState> {
  final DioClient _dio;
  InterstitialAd? _interstitialAd;

  AdCubit(this._dio) : super(const AdState());

  Future<void> checkAdsStatus() async {
    try {
      emit(state.copyWith(
        bannerAdStatus: AdStatus.loading,
        interstitialAdStatus: AdStatus.loading,
      ));

      final response = await _dio.sendGetRequest(ApiEndpoints.googleAdmobEnable);
      CommonMethods.devLog(logName: 'Ad status before data', message: response);

      if (response.data['status'] == 1) {
        final resData = response.data;
        CommonMethods.devLog(logName: 'Ad status after data', message: resData);

        final adData = resData['data'];

        CommonMethods.devLog(logName: "add_mob_status value", message: adData['add_mob_status']);

        final bannerEnabled = adData['add_mob_status'].toString() == "1";
        final interstitialEnabled = adData['add_mob_status'].toString() == "1";

        CommonMethods.devLog(logName: "Banner ad enable", message: bannerEnabled);

        emit(state.copyWith(
          bannerAdStatus: bannerEnabled ? AdStatus.enabled : AdStatus.disabled,
          interstitialAdStatus:
          interstitialEnabled ? AdStatus.enabled : AdStatus.disabled,
        ));

        await Future.delayed(const Duration(milliseconds: 100));

        if (bannerEnabled) {
          loadBannerAd();
        }

        if (interstitialEnabled) {
          loadInterstitialAd();
        }
      } else {
        emit(state.copyWith(
          bannerAdStatus: AdStatus.error,
          interstitialAdStatus: AdStatus.error,
          errorMessage: 'Failed to load ad status: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        bannerAdStatus: AdStatus.error,
        interstitialAdStatus: AdStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadBannerAd() async {
    if (state.bannerAdStatus != AdStatus.enabled) {
      CommonMethods.devLog(logName: "Banner Ad Loading", message: "Skipped - Status not enabled");
      return;
    }

    state.bannerAd?.dispose();
    CommonMethods.devLog(logName: "Banner Ad Loading", message: "Starting banner ad load");

    final adWidth = WidgetsBinding.instance.window.physicalSize.width ~/
        WidgetsBinding.instance.window.devicePixelRatio;

    final adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth.truncate());

    if (adSize == null) {
      CommonMethods.devLog(logName: "Banner Ad Loading", message: "Failed to get adaptive banner size");
      return;
    }

    CommonMethods.devLog(logName: "Banner Ad Size", message: "Width: ${adSize.width}, Height: ${adSize.height}");

    final bannerAd = BannerAd(
      adUnitId: AdUnitId.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          CommonMethods.devLog(logName: "Banner Ad", message: "Ad loaded successfully");
          emit(state.copyWith(isBannerAdLoaded: true));
        },
        onAdFailedToLoad: (ad, error) {
          CommonMethods.devLog(logName: "Banner Ad", message: "Failed to load ad: $error");
          ad.dispose();
          emit(state.copyWith(isBannerAdLoaded: false));
        },
      ),
    );

    emit(state.copyWith(bannerAd: bannerAd, isBannerAdLoaded: false));
    CommonMethods.devLog(logName: "Banner Ad", message: "Initiating ad load");
    bannerAd.load();
  }

  Future<void> loadInterstitialAd() async {
    if (state.interstitialAdStatus != AdStatus.enabled ||
        state.isInterstitialAdLoaded) {
      return;
    }

    await InterstitialAd.load(
      adUnitId: AdUnitId.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          emit(state.copyWith(isInterstitialAdLoaded: true));

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              emit(state.copyWith(isInterstitialAdLoaded: false));
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              emit(state.copyWith(isInterstitialAdLoaded: false));
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          emit(state.copyWith(isInterstitialAdLoaded: false));
          _interstitialAd = null;
          Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (state.interstitialAdStatus != AdStatus.enabled) {
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    if (_random.nextInt(3) != 0) {
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    if (!state.isInterstitialAdLoaded || _interstitialAd == null) {
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    final ad = _interstitialAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        emit(state.copyWith(isInterstitialAdLoaded: false));
        _interstitialAd = null;
        loadInterstitialAd();

        if (onAdClosed != null) {
          onAdClosed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        emit(state.copyWith(isInterstitialAdLoaded: false));
        _interstitialAd = null;
        loadInterstitialAd();

        if (onAdClosed != null) {
          onAdClosed();
        }
      },
    );

    await ad.show();
  }

  @override
  Future<void> close() {
    state.bannerAd?.dispose();
    _interstitialAd?.dispose();
    return super.close();
  }
}*/

import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../constant/app_export.dart';
import '../ad_unit_id.dart';

enum AdStatus {
  enabled,
  disabled,
  loading,
  error,
}

class AdState extends Equatable {
  final AdStatus bannerAdStatus;
  final AdStatus interstitialAdStatus;
  final bool isInterstitialAdLoaded;
  final String errorMessage;

  const AdState({
    this.bannerAdStatus = AdStatus.loading,
    this.interstitialAdStatus = AdStatus.loading,
    this.isInterstitialAdLoaded = false,
    this.errorMessage = '',
  });

  AdState copyWith({
    AdStatus? bannerAdStatus,
    AdStatus? interstitialAdStatus,
    bool? isInterstitialAdLoaded,
    String? errorMessage,
  }) {
    return AdState(
      bannerAdStatus: bannerAdStatus ?? this.bannerAdStatus,
      interstitialAdStatus: interstitialAdStatus ?? this.interstitialAdStatus,
      isInterstitialAdLoaded: isInterstitialAdLoaded ?? this.isInterstitialAdLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    bannerAdStatus,
    interstitialAdStatus,
    isInterstitialAdLoaded,
    errorMessage,
  ];
}

class AdCubit extends Cubit<AdState> {
  final DioClient _dio;
  static final Random _random = Random();
  InterstitialAd? _interstitialAd;

  // Keep track of all created banner ads for proper disposal
  final List<BannerAd> _activeBannerAds = [];

  AdCubit(this._dio) : super(const AdState());

  Future<void> checkAdsStatus() async {
    try {
      emit(state.copyWith(
        bannerAdStatus: AdStatus.loading,
        interstitialAdStatus: AdStatus.loading,
      ));

      final response = await _dio.sendGetRequest(ApiEndpoints.googleAdmobEnable);
      CommonMethods.devLog(logName: 'Ad status before data', message: response);

      if (response.data['status'] == 1) {
        final resData = response.data;
        CommonMethods.devLog(logName: 'Ad status after data', message: resData);

        final adData = resData['data'];

        CommonMethods.devLog(logName: "add_mob_status value", message: adData['add_mob_status']);

        final bannerEnabled = adData['add_mob_status'].toString() == "1";
        final interstitialEnabled = adData['add_mob_status'].toString() == "1";

        CommonMethods.devLog(logName: "Banner ad enable", message: bannerEnabled);

        emit(state.copyWith(
          bannerAdStatus: bannerEnabled ? AdStatus.enabled : AdStatus.disabled,
          interstitialAdStatus: interstitialEnabled ? AdStatus.enabled : AdStatus.disabled,
        ));

        await Future.delayed(const Duration(milliseconds: 100));

        if (interstitialEnabled) {
          loadInterstitialAd();
        }
      } else {
        emit(state.copyWith(
          bannerAdStatus: AdStatus.error,
          interstitialAdStatus: AdStatus.error,
          errorMessage: 'Failed to load ad status: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        bannerAdStatus: AdStatus.error,
        interstitialAdStatus: AdStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Creates a new banner ad instance for use in widgets
  /// Each widget should call this to get its own unique banner ad
  Future<BannerAd?> createBannerAdInstance() async {
    if (state.bannerAdStatus != AdStatus.enabled) {
      CommonMethods.devLog(logName: "Banner Ad Creation", message: "Skipped - Status not enabled");
      return null;
    }

    CommonMethods.devLog(logName: "Banner Ad Creation", message: "Creating new banner ad instance");

    final adWidth = WidgetsBinding.instance.window.physicalSize.width ~/
        WidgetsBinding.instance.window.devicePixelRatio;

    final adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth.truncate());

    if (adSize == null) {
      CommonMethods.devLog(logName: "Banner Ad Creation", message: "Failed to get adaptive banner size");
      return null;
    }

    CommonMethods.devLog(logName: "Banner Ad Size", message: "Width: ${adSize.width}, Height: ${adSize.height}");

    final bannerAd = BannerAd(
      adUnitId: AdUnitId.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          CommonMethods.devLog(logName: "Banner Ad Instance", message: "Ad loaded successfully");
        },
        onAdFailedToLoad: (ad, error) {
          CommonMethods.devLog(logName: "Banner Ad Instance", message: "Failed to load ad: $error");
          //_removeBannerAdFromTracking(ad);
          ad.dispose();
        },
        onAdWillDismissScreen: (ad) {
          CommonMethods.devLog(logName: "Banner Ad Instance", message: "Ad will dismiss screen");
        },
        onAdImpression: (ad) {
          CommonMethods.devLog(logName: "Banner Ad Instance", message: "Ad impression recorded");
        },
      ),
    );

    // Track the created banner ad for proper cleanup
    _activeBannerAds.add(bannerAd);
    CommonMethods.devLog(logName: "Banner Ad Tracking", message: "Total active banner ads: ${_activeBannerAds.length}");

    return bannerAd;
  }

  /// Remove a banner ad from tracking when it's disposed
  void _removeBannerAdFromTracking(BannerAd ad) {
    _activeBannerAds.remove(ad);
    CommonMethods.devLog(logName: "Banner Ad Tracking", message: "Removed banner ad. Remaining: ${_activeBannerAds.length}");
  }

  /// Dispose a specific banner ad instance
  void disposeBannerAdInstance(BannerAd ad) {
    _removeBannerAdFromTracking(ad);
    ad.dispose();
    CommonMethods.devLog(logName: "Banner Ad Instance", message: "Banner ad instance disposed");
  }

  /// Check if banner ads are enabled
  bool get isBannerAdEnabled => state.bannerAdStatus == AdStatus.enabled;

  /// Check if interstitial ads are enabled
  bool get isInterstitialAdEnabled => state.interstitialAdStatus == AdStatus.enabled;

  Future<void> loadInterstitialAd() async {
    if (state.interstitialAdStatus != AdStatus.enabled || state.isInterstitialAdLoaded) {
      CommonMethods.devLog(logName: "Interstitial Ad", message: "Skipped loading - Status: ${state.interstitialAdStatus}, Loaded: ${state.isInterstitialAdLoaded}");
      return;
    }

    CommonMethods.devLog(logName: "Interstitial Ad", message: "Starting interstitial ad load");

    await InterstitialAd.load(
      adUnitId: AdUnitId.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          CommonMethods.devLog(logName: "Interstitial Ad", message: "Ad loaded successfully");
          _interstitialAd = ad;
          emit(state.copyWith(isInterstitialAdLoaded: true));

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              CommonMethods.devLog(logName: "Interstitial Ad", message: "Ad showed full screen content");
            },
            onAdDismissedFullScreenContent: (ad) {
              CommonMethods.devLog(logName: "Interstitial Ad", message: "Ad dismissed full screen content");
              ad.dispose();
              emit(state.copyWith(isInterstitialAdLoaded: false));
              _interstitialAd = null;
              // Preload next interstitial ad
              Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              CommonMethods.devLog(logName: "Interstitial Ad", message: "Failed to show ad: $error");
              ad.dispose();
              emit(state.copyWith(isInterstitialAdLoaded: false));
              _interstitialAd = null;
              // Retry loading after delay
              Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
            },
            onAdImpression: (ad) {
              CommonMethods.devLog(logName: "Interstitial Ad", message: "Ad impression recorded");
            },
          );
        },
        onAdFailedToLoad: (error) {
          CommonMethods.devLog(logName: "Interstitial Ad", message: "Failed to load ad: $error");
          emit(state.copyWith(isInterstitialAdLoaded: false));
          _interstitialAd = null;
          // Retry loading after 1 minute
          Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Attempting to show interstitial ad");

    if (state.interstitialAdStatus != AdStatus.enabled) {
      CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Skipped - Ads not enabled");
      onAdClosed?.call();
      return;
    }

    if (!state.isInterstitialAdLoaded || _interstitialAd == null) {
      CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Skipped - Ad not loaded");
      onAdClosed?.call();
      // Try to load ad for next time
      if (!state.isInterstitialAdLoaded) {
        loadInterstitialAd();
      }
      return;
    }

    final ad = _interstitialAd!;

    // Set up callbacks specifically for this show instance
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Ad showed full screen content");
      },
      onAdDismissedFullScreenContent: (ad) {
        CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Ad dismissed - calling onAdClosed callback");
        ad.dispose();
        emit(state.copyWith(isInterstitialAdLoaded: false));
        _interstitialAd = null;

        // Call the callback after ad is dismissed
        onAdClosed?.call();

        // Preload next interstitial ad
        Future.delayed(const Duration(seconds: 1), loadInterstitialAd);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Failed to show ad: $error - calling onAdClosed callback");
        ad.dispose();
        emit(state.copyWith(isInterstitialAdLoaded: false));
        _interstitialAd = null;

        // Call the callback even if ad failed to show
        onAdClosed?.call();

        // Retry loading after delay
        Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
      },
      onAdImpression: (ad) {
        CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Ad impression recorded");
      },
    );

    try {
      CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Showing interstitial ad");
      await ad.show();
    } catch (e) {
      CommonMethods.devLog(logName: "Interstitial Ad Show", message: "Error showing ad: $e");
      onAdClosed?.call();
    }
  }

  /// Force reload interstitial ad (useful for debugging or manual refresh)
  Future<void> forceReloadInterstitialAd() async {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    emit(state.copyWith(isInterstitialAdLoaded: false));
    await loadInterstitialAd();
  }

  /// Get current ad status info for debugging
  Map<String, dynamic> getAdStatusInfo() {
    return {
      'bannerAdStatus': state.bannerAdStatus.toString(),
      'interstitialAdStatus': state.interstitialAdStatus.toString(),
      'isInterstitialAdLoaded': state.isInterstitialAdLoaded,
      'activeBannerAdsCount': _activeBannerAds.length,
      'errorMessage': state.errorMessage,
    };
  }

  @override
  Future<void> close() {
    CommonMethods.devLog(logName: "AdCubit", message: "Disposing AdCubit and cleaning up resources");

    // Dispose interstitial ad
    _interstitialAd?.dispose();

    // Dispose all active banner ads
    for (final bannerAd in _activeBannerAds) {
      bannerAd.dispose();
    }
    _activeBannerAds.clear();

    CommonMethods.devLog(logName: "AdCubit", message: "All ad resources cleaned up");

    return super.close();
  }
}

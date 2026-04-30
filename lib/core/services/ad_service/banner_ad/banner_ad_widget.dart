import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tinydroplets/core/services/ad_service/ad_manager.dart';
import 'package:tinydroplets/core/services/ad_service/ad_unit_id.dart';
import '../../../constant/app_export.dart';
import '../ad_bloc/ad_cubit.dart';
/*

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdCubit, AdState>(
      buildWhen:
          (previous, current) =>
              previous.bannerAdStatus != current.bannerAdStatus ||
              previous.isBannerAdLoaded != current.isBannerAdLoaded ||
              previous.bannerAd != current.bannerAd,
      builder: (context, state) {
        if (state.bannerAdStatus != AdStatus.enabled ||
            !state.isBannerAdLoaded ||
            state.bannerAd == null) {
          return const SizedBox.shrink();
        }
        if (AdManager().shouldShowAds(context)) {
          // Return the ad widget
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                width: state.bannerAd!.size.width.toDouble(),
                height: state.bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: state.bannerAd!),
              ),
              const SizedBox(height: 10),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tinydroplets/core/services/ad_service/ad_manager.dart';
import '../ad_bloc/ad_cubit.dart';

class BannerAdWidget extends StatefulWidget {
  final String? debugLabel;

  const BannerAdWidget({
    super.key,
    this.debugLabel,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  late AdCubit _adCubit;   // <-- Store provider safely here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read provider safely while widget is alive
    _adCubit = context.read<AdCubit>();
    _loadBannerAd();
  }

  @override
  void initState() {
    super.initState();
    // We cannot use context in initState, so load will start after didChangeDependencies
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _adCubit = context.read<AdCubit>(); // safe
  //   _loadBannerAd();                    // START LOAD HERE (safe)
  // }

  Future<void> _loadBannerAd() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      if (_adCubit.isBannerAdEnabled) {
        final bannerAd = await _adCubit.createBannerAdInstance();

        if (bannerAd != null && mounted) {
          _bannerAd = bannerAd;
          await bannerAd.load();

          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _disposeBannerAd() {
    if (_bannerAd != null) {
      _adCubit.disposeBannerAdInstance(_bannerAd!); // SAFE now
      _bannerAd = null;
      _isAdLoaded = false;
    }
  }

  @override
  void dispose() {
    _disposeBannerAd(); // uses stored provider safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdCubit, AdState>(
      listenWhen: (previous, current) =>
      previous.bannerAdStatus != current.bannerAdStatus,
      listener: (context, state) {
        if (state.bannerAdStatus == AdStatus.enabled &&
            _bannerAd == null &&
            !_isLoading) {
          _loadBannerAd();
        } else if (state.bannerAdStatus != AdStatus.enabled &&
            _bannerAd != null) {
          _disposeBannerAd();
          if (mounted) setState(() {});
        }
      },
      child: _buildAdWidget(),
    );
  }

  Widget _buildAdWidget() {
    if (_bannerAd == null || !_isAdLoaded || _isLoading) {
      return const SizedBox.shrink();
    }

    if (!AdManager().shouldShowAds(context)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
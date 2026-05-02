import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ad_bloc/ad_cubit.dart';
import '../ad_manager.dart';

class InterstitialAdWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdClosed;
  final VoidCallback? onTapWithoutAd;
  final bool shouldShowAd;

  const InterstitialAdWidget({
    super.key,
    required this.child,
    this.onAdClosed,
    this.onTapWithoutAd,
    this.shouldShowAd = true,
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  bool _isWaitingForAd = false;

  @override
  void initState() {
    super.initState();
    if (widget.shouldShowAd) {
      context.read<AdCubit>().loadInterstitialAd();
    }
  }

  void _handleTap() {
    final adCubit = context.read<AdCubit>();

    if (widget.shouldShowAd && AdManager().shouldShowAds(context)) {
      if (adCubit.state.isInterstitialAdLoaded) {
        adCubit.showInterstitialAd(onAdClosed: widget.onAdClosed);
        return;
      }

      setState(() {
        _isWaitingForAd = true;
      });
      adCubit.loadInterstitialAd();
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !_isWaitingForAd) {
          return;
        }
        setState(() {
          _isWaitingForAd = false;
        });
        _continueWithoutAd();
      });
      return;
    }

    _continueWithoutAd();
  }

  void _continueWithoutAd() {
    if (widget.onTapWithoutAd != null) {
      widget.onTapWithoutAd!();
    } else if (widget.onAdClosed != null) {
      widget.onAdClosed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdCubit, AdState>(
      listenWhen: (previous, current) =>
          _isWaitingForAd &&
          previous.isInterstitialAdLoaded != current.isInterstitialAdLoaded,
      listener: (context, state) {
        if (!_isWaitingForAd || !mounted) {
          return;
        }

        if (state.isInterstitialAdLoaded) {
          setState(() {
            _isWaitingForAd = false;
          });
          context.read<AdCubit>().showInterstitialAd(
                onAdClosed: widget.onAdClosed,
              );
        }
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            widget.child,
            if (_isWaitingForAd)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

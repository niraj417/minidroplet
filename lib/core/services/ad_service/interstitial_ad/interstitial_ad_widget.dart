/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ad_bloc/ad_cubit.dart';
import '../ad_manager.dart';


class InterstitialAdWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdClosed;

  const InterstitialAdWidget({
    super.key,
    required this.child,
    this.onAdClosed,
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  @override
  void initState() {
    super.initState();
    context.read<AdCubit>().loadInterstitialAd();
  }

  void _showAd() {
    if (AdManager().shouldShowAds(context)) {
      context.read<AdCubit>().showInterstitialAd(
        onAdClosed: widget.onAdClosed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAd,
      child: widget.child,
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ad_bloc/ad_cubit.dart';
import '../ad_manager.dart';

class InterstitialAdWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAdClosed;
  final VoidCallback? onTapWithoutAd; // For cases where ad shouldn't show
  final bool shouldShowAd; // Condition to determine if ad should show

  const InterstitialAdWidget({
    super.key,
    required this.child,
    this.onAdClosed,
    this.onTapWithoutAd,
    this.shouldShowAd = true, // Default to true for backward compatibility
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldShowAd) {
      context.read<AdCubit>().loadInterstitialAd();
    }
  }

  void _handleTap() {
    if (widget.shouldShowAd && AdManager().shouldShowAds(context)) {
      context.read<AdCubit>().showInterstitialAd(
        onAdClosed: widget.onAdClosed,
      );
    } else {
      // Either ads are disabled or this item shouldn't show ads
      if (widget.onTapWithoutAd != null) {
        widget.onTapWithoutAd!();
      } else if (widget.onAdClosed != null) {
        widget.onAdClosed!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
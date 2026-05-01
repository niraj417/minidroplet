import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

class CustomImage extends StatelessWidget {
  static const int _defaultMaxCacheDimension = 1280;

  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedUrl = imageUrl?.trim() ?? '';
    if (sanitizedUrl.isEmpty) {
      return _buildErrorWidget();
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = _resolveCacheDimension(
      explicitDimension: memCacheWidth,
      logicalDimension: width,
      devicePixelRatio: devicePixelRatio,
    );
    final targetHeight = _resolveCacheDimension(
      explicitDimension: memCacheHeight,
      logicalDimension: height,
      devicePixelRatio: devicePixelRatio,
    );

    return CachedNetworkImage(
      imageUrl: sanitizedUrl,
      fit: fit,
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? 200,
      memCacheWidth: targetWidth,
      memCacheHeight: targetHeight,
      maxWidthDiskCache: targetWidth,
      maxHeightDiskCache: targetHeight,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      filterQuality: FilterQuality.low,
    );
  }

  int? _resolveCacheDimension({
    required int? explicitDimension,
    required double? logicalDimension,
    required double devicePixelRatio,
  }) {
    if (explicitDimension != null && explicitDimension > 0) {
      return explicitDimension.clamp(1, _defaultMaxCacheDimension);
    }
    if (logicalDimension == null || logicalDimension <= 0) {
      return null;
    }
    final physicalDimension = (logicalDimension * devicePixelRatio).round();
    return physicalDimension.clamp(1, _defaultMaxCacheDimension);
  }

  Widget _buildPlaceholder() {
    return const RepaintBoundary(child: Loader());
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}

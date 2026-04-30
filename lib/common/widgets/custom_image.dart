import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

class CustomImage extends StatelessWidget {
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
    if (imageUrl == null) {
      return _buildErrorWidget();
    }

    // Get device pixel ratio to calculate correct cache dimensions
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate cache dimensions based on actual device pixels
    final calculatedWidth =
        width != null ? (width! * devicePixelRatio).toInt() : null;
    final calculatedHeight =
        height != null ? (height! * devicePixelRatio).toInt() : null;

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? 200,
      memCacheWidth: memCacheWidth ?? calculatedWidth,
      memCacheHeight: memCacheHeight ?? calculatedHeight,
      maxWidthDiskCache: memCacheWidth ?? calculatedWidth,
      maxHeightDiskCache: memCacheHeight ?? calculatedHeight,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  int? _getCacheSize(double? dimension) {
    return dimension?.toInt() ?? null;
  }

  Widget _buildPlaceholder() {
    return Loader();
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}

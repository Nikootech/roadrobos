import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Shared cache manager — 200 objects, 7-day staleness.
final appImageCacheManager = CacheManager(
  Config(
    'roadrobos_img_v1',
    maxNrOfCacheObjects: 200,
    stalePeriod: const Duration(days: 7),
  ),
);

/// Drop-in replacement for every Image.network() call in RoadRobos.
/// Features:
///  • Disk + memory cache via flutter_cache_manager
///  • Smooth 200ms fade-in
///  • Shimmer-style grey placeholder
///  • Consistent error fallback icon
///  • Optional clip with BorderRadius
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? customPlaceholder;
  final Widget? customError;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.customPlaceholder,
    this.customError,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return _errorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: url!,
      cacheManager: appImageCacheManager,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) =>
          customPlaceholder ?? _placeholderWidget(),
      errorWidget: (_, __, ___) =>
          customError ?? _errorWidget(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _placeholderWidget() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  Widget _errorWidget() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData? fallbackIcon;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackIcon = Icons.person_rounded,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    // On Web, standard images can hit CORS issues.
    // CachedNetworkImage on web handles basic mapping but we add a robust fallback.
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: backgroundColor ?? AppColors.bgSkyLight,
      ),
      placeholder: (context, url) => _buildFallback(isPlaceholder: true),
      errorWidget: (context, url, error) => _buildFallback(),
    );
  }

  Widget _buildFallback({bool isPlaceholder = false}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.bgSkyLight,
      child: Icon(
        fallbackIcon,
        size: radius * 0.8,
        color: isPlaceholder ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.primaryBlue,
      ),
    );
  }
}

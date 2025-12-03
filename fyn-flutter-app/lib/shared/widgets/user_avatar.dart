import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyn_flutter_app/core/utils/image_utils.dart';
import 'package:fyn_flutter_app/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarKey;
  final String? fallbackText;
  final double radius;
  final Color backgroundColor;

  const UserAvatar({
    super.key,
    this.avatarKey,
    this.fallbackText,
    this.radius = 20,
    this.backgroundColor = AppColors.surfaceHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = avatarKey != null ? ImageUtils.getAvatarUrl(avatarKey) : null;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              (fallbackText ?? 'U').substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
            )
          : null,
    );
  }
}

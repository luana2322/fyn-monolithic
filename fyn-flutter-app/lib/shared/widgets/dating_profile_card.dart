import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/dating_colors.dart';
import '../themes/dating_theme.dart';

/// Premium dating profile card for swipe interface.
/// Features full-bleed image, gradient overlay, and animated overlays.
class DatingProfileCard extends StatelessWidget {
  final String name;
  final int age;
  final String? imageUrl;
  final String? bio;
  final List<String> interests;
  final double? distance;
  final bool showLikeOverlay;
  final bool showNopeOverlay;
  final VoidCallback? onTap;

  const DatingProfileCard({
    super.key,
    required this.name,
    required this.age,
    this.imageUrl,
    this.bio,
    this.interests = const [],
    this.distance,
    this.showLikeOverlay = false,
    this.showNopeOverlay = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DatingTheme.radiusLg),
          boxShadow: DatingTheme.mediumShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DatingTheme.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              _buildImage(),
              
              // Gradient Overlay
              _buildGradient(),
              
              // Like Overlay
              if (showLikeOverlay) _buildLikeOverlay(),
              
              // Nope Overlay
              if (showNopeOverlay) _buildNopeOverlay(),
              
              // User Info
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: _buildUserInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // Generate consistent color from name
    final colors = [
      DatingColors.rose,
      DatingColors.indigo,
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    final color = colors[name.hashCode.abs() % colors.length];
    
    return Container(
      color: color,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildLikeOverlay() {
    return Positioned(
      top: 40,
      left: 20,
      child: Transform.rotate(
        angle: -0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: DatingColors.success, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'LIKE',
            style: TextStyle(
              color: DatingColors.success,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNopeOverlay() {
    return Positioned(
      top: 40,
      right: 20,
      child: Transform.rotate(
        angle: 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: DatingColors.error, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'NOPE',
            style: TextStyle(
              color: DatingColors.error,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name and Age
        Row(
          children: [
            Expanded(
              child: Text(
                '$name, $age',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Verified badge (optional)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: DatingColors.indigo,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Distance
        if (distance != null)
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                '${distance!.toStringAsFixed(1)} km away',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 8),
        
        // Bio
        if (bio != null && bio!.isNotEmpty)
          Text(
            bio!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 12),
        
        // Interests
        if (interests.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.take(4).map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

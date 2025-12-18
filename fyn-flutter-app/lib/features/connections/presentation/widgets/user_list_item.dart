import 'package:flutter/material.dart';
import '../../../auth/data/models/user_list_item_response.dart';
import '../../../../core/utils/image_utils.dart';

/// Widget hiển thị user item trong list (discover/search)
/// Match với reference design từ Litmatch
class UserListItem extends StatelessWidget {
  final UserListItemResponse user;
  final VoidCallback onTap;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fix Docker internal hostname for avatar URL
    final avatarUrl = ImageUtils.buildImageUrl(user.avatarUrl);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar với online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          _getInitials(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                // Online indicator
                if (user.isOnline == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E1E1E),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Age + Gender
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName ?? user.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Gender icon
                      if (user.gender != null) _buildGenderIcon(),
                      // Age
                      if (user.age != null)
                        Text(
                          user.age.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.pink[300],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bio
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Location (optional)
                  if (user.location != null && user.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              user.location!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.distanceKm != null) ...[
                            Text(
                              ' • ${user.distanceKm!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gender icon theo reference design
  Widget _buildGenderIcon() {
    if (user.gender == 'MALE') {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          Icons.male,
          size: 16,
          color: Colors.blue[300],
        ),
      );
    } else if (user.gender == 'FEMALE') {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          Icons.female,
          size: 16,
          color: Colors.pink[300],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Get initials from name
  String _getInitials() {
    final name = user.fullName ?? user.username;
    if (name.isEmpty) return '?';
    
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

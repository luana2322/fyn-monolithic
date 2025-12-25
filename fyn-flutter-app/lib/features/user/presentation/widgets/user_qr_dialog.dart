import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/dating_colors.dart';

class UserQrDialog extends StatelessWidget {
  final String userId;
  final String username;

  const UserQrDialog({
    super.key,
    required this.userId,
    required this.username,
  });

  String get profileUrl {
    // On web, use the current origin; otherwise use the production domain
    if (kIsWeb) {
      // For local dev: http://localhost:3000/#/u/{userId}
      // This uses the hash router format that Flutter web uses
      return 'http://localhost:3000/#/u/$userId';
    }
    return 'https://fyn.app/u/$userId';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? DatingColors.darkSurfaceElevated : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mã QR của bạn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? DatingColors.darkPrimaryText : DatingColors.lightPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '@$username',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? DatingColors.darkSecondaryText : DatingColors.lightSecondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: profileUrl,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: profileUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép liên kết vào bộ nhớ tạm')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Sao chép'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Share.share('Kết nối với mình trên FYN Social: $profileUrl');
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Chia sẻ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DatingColors.rose,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}

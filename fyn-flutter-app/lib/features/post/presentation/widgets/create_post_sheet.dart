import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Giữ nguyên các import logic của bạn
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/create_post_request.dart';
import '../../data/models/post_visibility.dart';
import '../providers/post_provider.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final List<_SelectedMedia> _media = [];
  PostVisibility _visibility = PostVisibility.public;
  final FocusNode _focusNode = FocusNode(); // Quản lý focus bàn phím

  // --- Logic Xử lý ---

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files.isEmpty) return;

      final previews = await Future.wait(
        files.map((file) async {
          final bytes = await file.readAsBytes();
          return _SelectedMedia(file: file, bytes: bytes, isVideo: false);
        }),
      );

      if (mounted) {
        setState(() => _media.addAll(previews));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;

      if (mounted) {
        setState(() {
          _media.add(_SelectedMedia(file: file, bytes: null, isVideo: true));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi chọn video: $e')));
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty && _media.isEmpty) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    try {
      final request = CreatePostRequest(
        content: content,
        visibility: _visibility,
      );
      await ref.read(postFeedProvider.notifier).createPost(
            request,
            mediaFiles: _media.map((item) => item.file).toList(),
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      setState(() => _isSubmitting = false);
    }
  }

  void _changeVisibility() async {
    FocusScope.of(context).unfocus();
    
    final selected = await showModalBottomSheet<PostVisibility>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildVisibilityBottomSheet(context),
    );

    if (selected != null && mounted) {
      setState(() => _visibility = selected);
      // Focus lại vào input sau khi chọn xong
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Widget _buildVisibilityBottomSheet(BuildContext context) {
     return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(bottom: 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Ai có thể xem bài viết này?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                _VisibilityTile(
                  icon: Icons.public,
                  title: 'Công khai',
                  subtitle: 'Bất kỳ ai trên FYN',
                  value: PostVisibility.public,
                  groupValue: _visibility,
                  onTap: () => Navigator.pop(context, PostVisibility.public),
                ),
                _VisibilityTile(
                  icon: Icons.people_alt_outlined,
                  title: 'Người theo dõi',
                  subtitle: 'Chỉ những người theo dõi bạn',
                  value: PostVisibility.followers,
                  groupValue: _visibility,
                  onTap: () => Navigator.pop(context, PostVisibility.followers),
                ),
                _VisibilityTile(
                  icon: Icons.lock_outline,
                  title: 'Chỉ mình tôi',
                  subtitle: 'Lưu trữ riêng tư',
                  value: PostVisibility.private,
                  groupValue: _visibility,
                  onTap: () => Navigator.pop(context, PostVisibility.private),
                ),
              ],
            ),
          ),
        );
  }

  String get _visibilityLabel {
    switch (_visibility) {
      case PostVisibility.followers:
        return 'Người theo dõi';
      case PostVisibility.private:
        return 'Chỉ mình tôi';
      case PostVisibility.public:
      default:
        return 'Công khai';
    }
  }

  IconData get _visibilityIcon {
    switch (_visibility) {
      case PostVisibility.followers:
        return Icons.people_alt_outlined;
      case PostVisibility.private:
        return Icons.lock_outline;
      case PostVisibility.public:
      default:
        return Icons.public;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- UI Chính ---
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final avatarUrl = ImageUtils.getAvatarUrl(user?.profile.avatarUrl);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool canSubmit = _controller.text.trim().isNotEmpty || _media.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.surface, // Nền trắng của sheet
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 1. Header
          _buildHeader(canSubmit),

          // 2. Body (Content + Media)
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // User Profile Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null
                                ? Text(user?.username[0].toUpperCase() ?? '?',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? 'Người dùng',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Visibility Selector
                              GestureDetector(
                                onTap: _changeVisibility,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_visibilityIcon, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        _visibilityLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary, 
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Input Field (Đã sửa theo yêu cầu)
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 3,
                        autofocus: true,
                        // Cấu hình chữ ĐEN và ĐẬM
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Bạn đang nghĩ gì thế?',
                          hintStyle: TextStyle(
                            fontSize: 20, 
                            color: Colors.grey[500],
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          // Nền trong suốt để đồng bộ với nền trắng bên dưới
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      
                      const SizedBox(height: 20),

                      // Media Preview Grid
                      if (_media.isNotEmpty) _buildMediaGrid(),
                      
                      // Padding bottom để tránh bị toolbar che
                      SizedBox(height: bottomInset > 0 ? 60 : 100), 
                    ],
                  ),
                ),
                
                // 3. Toolbar (Sticky Bottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomInset,
                  child: _buildBottomToolbar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Con ---

  Widget _buildHeader(bool canSubmit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            color: AppColors.primaryText,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Text(
            'Tạo bài viết',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: (canSubmit && !_isSubmitting) ? _submit : null,
              style: TextButton.styleFrom(
                backgroundColor: (canSubmit && !_isSubmitting) 
                    ? AppColors.primary 
                    : Colors.grey[300],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size(60, 36),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Đăng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: (canSubmit && !_isSubmitting) ? Colors.white : Colors.grey[500],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _media.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final double size = (constraints.maxWidth - 16) / 3;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: _buildPreviewImage(item),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _media.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPreviewImage(_SelectedMedia media) {
    if (media.isVideo) {
      return Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (media.file.path.isNotEmpty)
               Container(color: Colors.grey[900]),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
          ],
        ),
      );
    }
    if (kIsWeb || media.bytes != null) {
      return Image.memory(media.bytes!, fit: BoxFit.cover);
    }
    return Image.file(File(media.file.path), fit: BoxFit.cover);
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            "Thêm vào bài viết",
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const Spacer(),
          _ToolbarButton(
            icon: Icons.photo_library,
            color: Colors.green,
            onTap: _pickImages,
          ),
          const SizedBox(width: 16),
          _ToolbarButton(
            icon: Icons.videocam_rounded,
            color: Colors.redAccent,
            onTap: _pickVideo,
          ),
        ],
      ),
    );
  }
}

// Widget phụ cho nút Toolbar
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

// Model & Helper Class
class _SelectedMedia {
  final XFile file;
  final Uint8List? bytes;
  final bool isVideo;
  _SelectedMedia({required this.file, this.bytes, this.isVideo = false});
}

class _VisibilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PostVisibility value;
  final PostVisibility groupValue;
  final VoidCallback onTap;

  const _VisibilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.primary.withOpacity(0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryText, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.radio_button_checked, color: AppColors.primary)
            else
              const Icon(Icons.radio_button_off, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
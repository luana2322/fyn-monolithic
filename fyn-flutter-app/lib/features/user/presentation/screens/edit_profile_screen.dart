import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/update_profile_request.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isPrivate = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // Cache bytes for web

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _bioController.text = user.profile.bio ?? '';
      _websiteController.text = user.profile.website ?? '';
      _locationController.text = user.profile.location ?? '';
      _isPrivate = user.profile.isPrivate;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = null; // Reset cache
      });
      
      image.readAsBytes().then((bytes) {
        if (mounted) {
          setState(() {
            _selectedImageBytes = bytes;
          });
        }
      }).catchError((e) {
        debugPrint('Error reading image bytes: $e');
      });
    }
  }

  ImageProvider? _getImageProvider() {
    if (_selectedImage == null) return null;
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    }
    if (!kIsWeb) {
      return null; 
    }
    return null; 
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final editNotifier = ref.read(editProfileProvider.notifier);

    // Upload avatar first if selected
    if (_selectedImage != null) {
      final success = await editNotifier.uploadAvatar(_selectedImage!);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(editProfileProvider).error ?? 'Upload avatar thất bại',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    // Update profile
    final request = UpdateProfileRequest(
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isPrivate: _isPrivate,
    );

    final success = await editNotifier.updateProfile(request);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật profile thành công'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(editProfileProvider).error ?? 'Cập nhật profile thất bại',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final editState = ref.watch(editProfileProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.surface, // Nền trắng sạch sẽ
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryText, size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: editState.isLoading ? null : _saveProfile,
              icon: editState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, color: AppColors.primary, size: 28),
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar Section
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surfaceHighlight, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: AppColors.surfaceHighlight,
                                  backgroundImage: _getImageProvider() ??
                                      (ImageUtils.getAvatarUrl(user.profile.avatarUrl) != null
                                          ? CachedNetworkImageProvider(
                                              ImageUtils.getAvatarUrl(user.profile.avatarUrl)!,
                                            )
                                          : null),
                                  child: (_getImageProvider() == null &&
                                              _selectedImage == null &&
                                              user.profile.avatarUrl == null) ||
                                          (_selectedImage != null && _selectedImageBytes == null)
                                      ? Text(
                                          user.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.tertiaryText,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surface, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text(
                            'Đổi ảnh đại diện',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields - Clean Filled Style
                        _buildTextField('Tên hiển thị', _fullNameController, icon: Icons.person_outline_rounded),
                        const SizedBox(height: 20),
                        _buildTextField('Tiểu sử', _bioController, maxLines: 3, icon: Icons.info_outline_rounded),
                        const SizedBox(height: 20),
                        _buildTextField('Trang web', _websiteController, icon: Icons.link_rounded),
                        const SizedBox(height: 20),
                        _buildTextField('Vị trí', _locationController, icon: Icons.location_on_outlined),
                        
                        const SizedBox(height: 32),
                        
                        // Privacy Switch - Modern Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Tài khoản riêng tư',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            subtitle: const Text(
                              'Chỉ người theo dõi mới thấy bài viết',
                              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                            value: _isPrivate,
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _isPrivate = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 22, color: AppColors.tertiaryText) : null,
            filled: true,
            fillColor: AppColors.surfaceHighlight, // Nền xám nhạt (Liquid style)
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            hintStyle: const TextStyle(color: AppColors.tertiaryText),
          ),
        ),
      ],
    );
  }
}
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
      
      // Pre-load bytes for both web and mobile (to avoid File issues)
      image.readAsBytes().then((bytes) {
        if (mounted) {
          setState(() {
            _selectedImageBytes = bytes;
          });
        }
      }).catchError((e) {
        // If reading bytes fails, we'll show placeholder
        print('Error reading image bytes: $e');
      });
    }
  }

  ImageProvider? _getImageProvider() {
    if (_selectedImage == null) return null;
    
    // For both web and mobile: use MemoryImage from bytes
    // This avoids File/FileImage issues on web
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    }
    
    // If bytes not loaded yet, try to load them (for mobile)
    if (!kIsWeb) {
      // On mobile, we can still use FileImage as fallback
      // But prefer bytes to avoid issues
      return null; // Will show placeholder
    }
    
    return null; // Will show placeholder until bytes are loaded
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
              backgroundColor: Colors.red,
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
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(editProfileProvider).error ?? 'Cập nhật profile thất bại',
          ),
          backgroundColor: Colors.red,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Chỉnh sửa profile'),
        actions: [
          TextButton(
            onPressed: editState.isLoading ? null : _saveProfile,
            child: editState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu'),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: _getImageProvider() ??
                                (ImageUtils.getAvatarUrl(
                                            user.profile.avatarUrl) !=
                                        null
                                    ? CachedNetworkImageProvider(
                                        ImageUtils.getAvatarUrl(
                                            user.profile.avatarUrl)!,
                                      )
                                    : null),
                            child: (_getImageProvider() == null &&
                                        _selectedImage == null &&
                                        user.profile.avatarUrl == null) ||
                                    (_selectedImage != null &&
                                        _selectedImageBytes == null)
                                ? Text(
                                    user.username[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 40),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.secondary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20),
                                color: AppColors.primaryText,
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        hintText: 'Nhập họ và tên',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Giới thiệu về bản thân',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Website
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Địa điểm',
                        hintText: 'Thành phố, Quốc gia',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),

                    // Privacy Setting
                    SwitchListTile(
                      title: const Text('Tài khoản riêng tư'),
                      subtitle: const Text(
                        'Chỉ người theo dõi mới có thể xem bài viết của bạn',
                      ),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


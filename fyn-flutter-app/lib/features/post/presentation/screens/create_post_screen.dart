import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/place_tag.dart';
import '../../data/models/create_post_request.dart';
import '../providers/post_provider.dart';
import '../widgets/place_picker_dialog.dart';
import '../../../../core/services/location_service.dart';
import '../../../../theme/dating_colors.dart';

/// Maximum media items per post
const int kMaxMediaItems = 10;

/// Full screen for creating a new post with location options
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _locationService = LocationService();
  final _picker = ImagePicker();
  
  LocationData? _currentLocation;
  PlaceTag? _selectedPlace;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  final List<_SelectedMedia> _media = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _requestCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    final location = await _locationService.getCurrentLocation();
    
    setState(() {
      _isLoadingLocation = false;
      if (location != null) {
        _currentLocation = location;
        _selectedPlace = null; // Clear place if location is set
      } else {
        _showError('Không thể lấy vị trí. Vui lòng kiểm tra quyền truy cập.');
      }
    });
  }

  Future<void> _selectPlace() async {
    final place = await showDialog<PlaceTag>(
      context: context,
      builder: (context) => const PlacePickerDialog(),
    );

    if (place != null) {
      setState(() {
        _selectedPlace = place;
        _currentLocation = null; // Clear location if place is set
      });
    }
  }

  void _clearLocation() {
    setState(() {
      _currentLocation = null;
      _selectedPlace = null;
    });
  }

  Future<void> _pickImages() async {
    if (_media.length >= kMaxMediaItems) {
      _showError('Tối đa $kMaxMediaItems media cho mỗi bài viết');
      return;
    }
    
    try {
      final files = await _picker.pickMultiImage();
      if (files.isEmpty) return;

      final remaining = kMaxMediaItems - _media.length;
      final filesToAdd = files.take(remaining).toList();

      final previews = await Future.wait(
        filesToAdd.map((file) async {
          final bytes = await file.readAsBytes();
          return _SelectedMedia(
            file: file,
            bytes: bytes,
            isVideo: false,
          );
        }),
      );

      if (mounted) {
        setState(() {
          _media.addAll(previews);
        });
      }
    } catch (e) {
      _showError('Không thể chọn ảnh: $e');
    }
  }

  Future<void> _pickVideo() async {
    if (_media.length >= kMaxMediaItems) {
      _showError('Tối đa $kMaxMediaItems media cho mỗi bài viết');
      return;
    }
    
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (file == null) return;

      if (mounted) {
        setState(() {
          _media.add(_SelectedMedia(
            file: file,
            bytes: null,
            isVideo: true,
          ));
        });
      }
    } catch (e) {
      _showError('Không thể chọn video: $e');
    }
  }

  void _removeMedia(int index) {
    if (_isSubmitting) return;
    setState(() {
      _media.removeAt(index);
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    
    // Allow submit if there's either content OR media
    if (content.isEmpty && _media.isEmpty) {
      _showError('Vui lòng nhập nội dung hoặc chọn ảnh/video');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = CreatePostRequest(
        content: content.isEmpty ? null : content,
        latitude: _currentLocation?.latitude,
        longitude: _currentLocation?.longitude,
        placeCode: _selectedPlace?.code,
      );

      await ref.read(postFeedProvider.notifier).createPost(
        request,
        mediaFiles: _media.map((item) => item.file).toList(),
      );
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Không thể tạo bài viết: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DatingColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? DatingColors.darkSurface : Colors.white,
        elevation: 0,
        title: Text(
          'Tạo bài viết',
          style: TextStyle(
            color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: Text(
              'Đăng',
              style: TextStyle(
                color: DatingColors.indigo,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content input
            Container(
              color: isDark ? DatingColors.darkSurface : Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Bạn đang nghĩ gì?',
                  hintStyle: TextStyle(
                    color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Media section
            if (_media.isNotEmpty || true) // Always show for easier access
              Container(
                color: isDark ? DatingColors.darkSurface : Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_media.isNotEmpty) ...[
                      Text(
                        'Media (${_media.length}/$kMaxMediaItems)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Media grid
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _media.length,
                          itemBuilder: (context, index) {
                            final media = _media[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: _buildMediaPreview(media),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeMedia(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Media picker buttons
                    if (_media.length < kMaxMediaItems)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _pickImages,
                              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                              label: const Text('Thêm ảnh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _pickVideo,
                              icon: const Icon(Icons.videocam_outlined, size: 18),
                              label: const Text('Thêm video'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Location section
            Container(
              color: isDark ? DatingColors.darkSurface : Colors.white, 
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thêm vị trí',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Current location selected
                  if (_currentLocation != null)
                    _buildLocationChip(
                      icon: Icons.my_location,
                      label: 'Vị trí hiện tại',
                      onRemove: _clearLocation,
                      isDark: isDark,
                    ),

                  // Place selected
                  if (_selectedPlace != null)
                    _buildLocationChip(
                      icon: Icons.location_on,
                      label: _selectedPlace!.displayName,
                      onRemove: _clearLocation,
                      isDark: isDark,
                    ),

                  // Location buttons
                  if (_currentLocation == null && _selectedPlace == null) ...[
                    _buildLocationButton(
                      icon: Icons.my_location,
                      label: _isLoadingLocation
                          ? 'Đang lấy vị trí...'
                          : 'Vị trí hiện tại',
                      onTap: _isLoadingLocation ? null : _requestCurrentLocation,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationButton(
                      icon: Icons.location_city,
                      label: 'Gắn thẻ địa điểm',
                      onTap: _selectPlace,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DatingColors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: DatingColors.indigo),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: DatingColors.indigo,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: DatingColors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? DatingColors.darkBorder : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: onTap == null
                  ? (isDark ? DatingColors.darkMutedText : Colors.grey.shade400)
                  : DatingColors.indigo,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: onTap == null
                    ? (isDark ? DatingColors.darkMutedText : Colors.grey.shade400)
                    : (isDark ? DatingColors.darkPrimaryText : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(_SelectedMedia media) {
    if (media.isVideo) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ),
      );
    }
    
    // Image preview
    if (kIsWeb || media.bytes != null) {
      return Image.memory(
        media.bytes!,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    
    return FutureBuilder<Uint8List>(
      future: media.file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: 80,
            height: 100,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: 80,
          height: 100,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}

class _SelectedMedia {
  final XFile file;
  final Uint8List? bytes;
  final bool isVideo;

  _SelectedMedia({
    required this.file,
    this.bytes,
    this.isVideo = false,
  });
}

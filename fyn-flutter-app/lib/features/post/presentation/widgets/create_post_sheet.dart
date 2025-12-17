import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../../data/models/create_post_request.dart';
import '../../data/models/post_visibility.dart';
import '../providers/post_provider.dart';

/// Configurable maximum number of media items per post
const int kMaxMediaItems = 10;

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

  Future<void> _pickImages() async {
    if (_media.length >= kMaxMediaItems) {
      _showMaxMediaWarning();
      return;
    }
    
    try {
      final files = await _picker.pickMultiImage();
      if (files == null || files.isEmpty) return;

      // Limit to remaining slots
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    if (_media.length >= kMaxMediaItems) {
      _showMaxMediaWarning();
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn video: $e')),
      );
    }
  }

  void _showMaxMediaWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tối đa $kMaxMediaItems media cho mỗi bài viết')),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_isSubmitting) return;
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _media.removeAt(oldIndex);
      _media.insert(newIndex, item);
    });
  }

  void _removeMedia(int index) {
    if (_isSubmitting) return;
    setState(() {
      _media.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    
    // Error only if BOTH caption and media are empty
    if (content.isEmpty && _media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn ảnh/video')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreatePostRequest(
        content: content.isEmpty ? null : content,  // Optional caption
        visibility: PostVisibility.public,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tạo bài viết: $e')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạo bài viết',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Caption input (optional)
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Chia sẻ cảm nghĩ của bạn... (không bắt buộc)',
                    helperText: 'Caption là tuỳ chọn',
                    helperStyle: TextStyle(color: Colors.grey.shade500),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Media counter
                if (_media.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${_media.length}/$kMaxMediaItems media',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Kéo để sắp xếp',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Media grid with drag-and-drop reordering
                _buildMediaGrid(),
                
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng bài'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Draggable media items
        if (_media.isNotEmpty)
          SizedBox(
            height: 110,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _media.length,
              onReorder: _onReorder,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final media = _media[index];
                return Container(
                  key: ValueKey('media_$index'),
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      // Media preview
                      Container(
                        width: 90,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: _buildPreview(media),
                        ),
                      ),
                      // Order badge
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Delete button
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
                      // Drag handle indicator
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.drag_indicator,
                            size: 12,
                            color: Colors.white,
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
        
        // Add media buttons
        if (_media.length < kMaxMediaItems)
          Row(
            children: [
              // Add images button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickImages,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Thêm ảnh'),
                ),
              ),
              const SizedBox(width: 12),
              // Add video button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Thêm video'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPreview(_SelectedMedia media) {
    if (media.isVideo) {
      return _VideoPreviewWidget(file: media.file);
    }
    
    // Image preview
    if (kIsWeb || media.bytes != null) {
      return Image.memory(
        media.bytes!,
        width: 90,
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
            width: 90,
            height: 100,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: 90,
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

class _VideoPreviewWidget extends StatefulWidget {
  final XFile file;

  const _VideoPreviewWidget({required this.file});

  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }
  
  Future<void> _generateThumbnail() async {
    try {
      final thumbnail = await vt.VideoThumbnail.thumbnailData(
        video: widget.file.path,
        imageFormat: vt.ImageFormat.JPEG,
        maxWidth: 200,
        quality: 75,
      );
      
      if (mounted) {
        setState(() {
          _thumbnailData = thumbnail;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (_thumbnailData != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _thumbnailData!,
                fit: BoxFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Play button overlay
          if (!_isLoading)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black26,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          
          // Video badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 10,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'VIDEO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

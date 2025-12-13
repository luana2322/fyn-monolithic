import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

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

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage();
      if (files == null || files.isEmpty) return;

      final previews = await Future.wait(
        files.map((file) async {
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

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty && _media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn media')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreatePostRequest(
        content: content,
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
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Chia sẻ cảm nghĩ của bạn...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._media.asMap().entries.map(
                      (entry) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildPreview(entry.value),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                if (_isSubmitting) return;
                                setState(() {
                                  _media.removeAt(entry.key);
                                });
                              },
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
                    ),
                    if (_media.length < 4) ...[
                      // Button chọn ảnh
                      GestureDetector(
                        onTap: _isSubmitting ? null : _pickImages,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined),
                        ),
                      ),
                      // Button chọn video
                      GestureDetector(
                        onTap: _isSubmitting ? null : _pickVideo,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.videocam_outlined),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
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

  Widget _buildPreview(_SelectedMedia media) {
    if (media.isVideo) {
      return _VideoPreviewWidget(file: media.file);
    }
    
    // Image preview
    if (kIsWeb || media.bytes != null) {
      return Image.memory(
        media.bytes!,
        width: 90,
        height: 90,
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
            height: 90,
            fit: BoxFit.cover,
          );
        }
        return Container(
          width: 90,
          height: 90,
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
      height: 90,
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



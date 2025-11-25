import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
          return _SelectedMedia(file: file, bytes: bytes);
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

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty && _media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn ảnh')),
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
                    if (_media.length < 4)
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

  _SelectedMedia({required this.file, this.bytes});
}


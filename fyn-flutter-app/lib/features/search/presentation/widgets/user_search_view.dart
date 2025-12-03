import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../presentation/providers/search_provider.dart';

class UserSearchView extends ConsumerStatefulWidget {
  const UserSearchView({super.key});

  @override
  ConsumerState<UserSearchView> createState() => _UserSearchViewState();
}

class _UserSearchViewState extends ConsumerState<UserSearchView> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(userSearchProvider.notifier).search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ẩn bàn phím khi chạm ra ngoài
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // 1. Search Bar Area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề lớn nếu chưa focus (giống Instagram/Apple)
                  if (!_isFocused && _controller.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        'Tìm kiếm',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  
                  // Ô nhập liệu
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onQueryChanged,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Tìm người dùng, bài viết...',
                      hintStyle: const TextStyle(color: AppColors.tertiaryText),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 24),
                      suffixIcon: searchState.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: AppColors.secondaryText, size: 20),
                              onPressed: () {
                                _controller.clear();
                                ref.read(userSearchProvider.notifier).clearResults();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceHighlight, // Nền xám nhạt
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), // Bo góc mềm
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
                    ),
                  ),
                ],
              ),
            ),

            // 2. Content Area
            Expanded(
              child: _buildContent(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic searchState) {
    // Trường hợp đang tải
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Trường hợp chưa nhập gì (Idle State) -> Hiển thị Gợi ý
    if (searchState.query.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.explore_outlined, size: 64, color: AppColors.tertiaryText),
            ),
            const SizedBox(height: 24),
            const Text(
              'Khám phá cộng đồng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập tên người dùng hoặc từ khóa để tìm kiếm bạn bè mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // Mock "Gần đây" hoặc "Gợi ý"
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gợi ý cho bạn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 16),
            // Mock list suggestions (Placeholder UI)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: AppColors.surfaceHighlight, shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: AppColors.tertiaryText),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 100, height: 12, decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 6),
                          Container(width: 60, height: 10, decoration: BoxDecoration(color: AppColors.surfaceHighlight, borderRadius: BorderRadius.circular(4))),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // Trường hợp có lỗi
    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(searchState.error!, style: const TextStyle(color: AppColors.secondaryText)),
          ],
        ),
      );
    }

    // Trường hợp không tìm thấy kết quả
    if (searchState.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.tertiaryText),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy kết quả nào',
              style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    // Trường hợp hiển thị danh sách kết quả
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final user = searchState.results[index];
        final avatarUrl = ImageUtils.getAvatarUrl(user.profile.avatarUrl);

        return InkWell(
          onTap: () {
            context.push('/profile/${user.id}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceHighlight,
                  backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (user.fullName != null && user.fullName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            user.fullName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Navigate Icon
                const Icon(Icons.north_west_rounded, size: 20, color: AppColors.tertiaryText),
              ],
            ),
          ),
        );
      },
    );
  }
}
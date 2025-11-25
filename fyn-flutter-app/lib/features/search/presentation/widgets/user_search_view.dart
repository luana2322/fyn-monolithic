import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  Timer? _debounce;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchState.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        ref.read(userSearchProvider.notifier).clearResults();
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (searchState.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(),
          )
        else if (searchState.query.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nhập từ khóa để tìm kiếm người dùng',
                style: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
          )
        else if (searchState.error != null)
          Expanded(
            child: Center(
              child: Text(
                searchState.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          )
        else if (searchState.results.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Không tìm thấy người dùng phù hợp',
                style: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: searchState.results.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final user = searchState.results[index];
                final avatarUrl = ImageUtils.getAvatarUrl(user.profile.avatarUrl);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  subtitle: user.fullName != null && user.fullName!.isNotEmpty
                      ? Text(user.fullName!)
                      : null,
                  onTap: () {
                    context.go('/profile/${user.id}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}


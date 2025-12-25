import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_model.dart';
import '../providers/comment_provider.dart';
import '../../../../theme/dating_colors.dart';

class PostCommentsSheet extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCommentsSheet({super.key, required this.post});

  @override
  ConsumerState<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends ConsumerState<PostCommentsSheet> {
  late final TextEditingController _controller;
  late final CommentProviderArgs _args;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _args = CommentProviderArgs(
      postId: widget.post.id,
      ownerId: widget.post.author.id,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postCommentsProvider(_args).notifier).load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCommentsProvider(_args));
    final authState = ref.watch(authNotifierProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? DatingColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? Center(child: CircularProgressIndicator(
                            color: isDark ? DatingColors.rose : null,
                          ))
                        : state.error != null
                            ? Center(
                                child: Text(
                                  state.error!,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              )
                            : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: state.comments.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 24, color: isDark ? DatingColors.darkBorder : null),
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              final canDelete =
                                  authState.user?.id == comment.author.id;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isDark ? DatingColors.darkSurfaceElevated : null,
                                    child: Text(
                                      comment.author.username
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isDark ? DatingColors.darkPrimaryText : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.author.username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? DatingColors.darkPrimaryText : null,
                                              ),
                                            ),
                                            if (canDelete) ...[
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () => ref
                                                    .read(postCommentsProvider(
                                                            _args)
                                                        .notifier)
                                                    .deleteComment(
                                                        comment.id),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: TextStyle(
                                            color: isDark ? DatingColors.darkPrimaryText : null,
                                          ),
                                        ),
                                        if (comment.createdAt != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              comment.createdAt
                                                  .toString()
                                                  .substring(0, 16),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  Divider(height: 1, color: isDark ? DatingColors.darkBorder : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: isDark ? DatingColors.darkPrimaryText : null,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Viết bình luận...',
                              hintStyle: TextStyle(
                                color: isDark ? DatingColors.darkSecondaryText : null,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark ? DatingColors.darkBorder : Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark ? DatingColors.darkBorder : Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark ? DatingColors.rose : Colors.blue,
                                ),
                              ),
                              filled: isDark,
                              fillColor: isDark ? DatingColors.darkSurfaceElevated : null,
                            ),
                            minLines: 1,
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        state.isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? DatingColors.rose : null,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: isDark ? DatingColors.rose : null,
                                ),
                                onPressed: () async {
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) return;
                                  await ref
                                      .read(
                                          postCommentsProvider(_args).notifier)
                                      .addComment(text);
                                  _controller.clear();
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


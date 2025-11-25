import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/post_model.dart';
import '../providers/comment_provider.dart';

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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
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
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              final canDelete =
                                  authState.user?.id == comment.author.id;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    child: Text(
                                      comment.author.username
                                          .substring(0, 1)
                                          .toUpperCase(),
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                        Text(comment.content),
                                        if (comment.createdAt != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              comment.createdAt
                                                  .toString()
                                                  .substring(0, 16),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
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
                  const Divider(height: 1),
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
                            decoration: const InputDecoration(
                              hintText: 'Viết bình luận...',
                              border: OutlineInputBorder(),
                            ),
                            minLines: 1,
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        state.isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
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


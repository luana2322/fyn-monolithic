import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/story_model.dart';
import '../providers/story_provider.dart';
import '../screens/story_viewer.dart';

/// Story avatar ring for displaying in feed
class StoryAvatar extends ConsumerWidget {
  final StoryUserWithStories storyUser;
  final bool isCurrentUser;
  final VoidCallback? onAddStory;

  const StoryAvatar({
    super.key,
    required this.storyUser,
    this.isCurrentUser = false,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasStories = storyUser.stories.isNotEmpty;
    final allViewed = storyUser.allViewed;

    return GestureDetector(
      onTap: () {
        if (isCurrentUser && !hasStories) {
          // Show add story option
          onAddStory?.call();
        } else if (hasStories) {
          // Open story viewer
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StoryViewer(storyUser: storyUser),
            ),
          );
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Story ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: !hasStories
                        ? null
                        : allViewed
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500,
                                ],
                              )
                            : const LinearGradient(
                                colors: [
                                  AppColors.secondaryLight,
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
                              ),
                    border: hasStories
                        ? null
                        : Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 27,
                      backgroundColor: AppColors.muted,
                      backgroundImage: storyUser.avatarUrl != null
                          ? NetworkImage(storyUser.avatarUrl!)
                          : null,
                      child: storyUser.avatarUrl == null
                          ? Text(
                              storyUser.username.isNotEmpty
                                  ? storyUser.username[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                // Add button for current user
                if (isCurrentUser)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isCurrentUser ? 'Tin của bạn' : storyUser.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stories row for feed screen
class StoriesRow extends ConsumerStatefulWidget {
  final Function()? onAddStory;

  const StoriesRow({
    super.key,
    this.onAddStory,
  });

  @override
  ConsumerState<StoriesRow> createState() => _StoriesRowState();
}

class _StoriesRowState extends ConsumerState<StoriesRow> {
  @override
  void initState() {
    super.initState();
    // Load stories when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storyFeedProvider.notifier).loadStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyFeedProvider);

    if (storyState.isLoading && !storyState.hasStories) {
      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 5,
          itemBuilder: (context, index) => _buildShimmerAvatar(),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 1 + storyState.storyUsers.length, // +1 for current user
        itemBuilder: (context, index) {
          if (index == 0) {
            // Current user story
            final currentUser = storyState.currentUser;
            if (currentUser != null) {
              return StoryAvatar(
                storyUser: currentUser,
                isCurrentUser: true,
                onAddStory: widget.onAddStory,
              );
            }
            // Placeholder for current user if not loaded
            return _buildCurrentUserPlaceholder();
          }

          final storyUser = storyState.storyUsers[index - 1];
          return StoryAvatar(storyUser: storyUser);
        },
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserPlaceholder() {
    return GestureDetector(
      onTap: widget.onAddStory,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tin của bạn',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.primaryText),
            ),
          ],
        ),
      ),
    );
  }
}

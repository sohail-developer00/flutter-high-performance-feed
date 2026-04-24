import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../screens/detail_screen.dart';
import '../core/device_utils.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic cache width based on device pixel ratio for RAM optimization
    final cacheWidth = DeviceUtils.getCacheWidth(context);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // GPU OPTIMIZATION: Heavy BoxShadow with large blur radius
          // RepaintBoundary ensures this shadow is rasterized once and cached
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 30, // Heavy blur for premium UI feel
              offset: const Offset(0, 15),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RAM OPTIMIZATION: Using media_thumb_url only in feed
              // cacheWidth ensures decoded image matches UI size (~300px)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
                ),
                child: Hero(
                  tag: 'post-image-${post.id}',
                  child: CachedNetworkImage(
                    imageUrl: post.thumbUrl,
                    memCacheWidth: cacheWidth,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 280,
                    placeholder: (context, url) => Container(
                      height: 280,
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 280,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
              // Like button section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Post ${post.id.substring(0, 8)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        _LikeButton(post: post),
                        const SizedBox(width: 4),
                        Text(
                          "${post.likeCount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  final Post post;

  const _LikeButton({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          post.isLiked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(post.isLiked),
          color: post.isLiked ? Colors.red : Colors.grey,
          size: 28,
        ),
      ),
      onPressed: () => ref.read(postProvider.notifier).toggleLike(post.id),
    );
  }
}

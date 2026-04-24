import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

final postProvider =
    StateNotifierProvider<PostNotifier, AsyncValue<List<Post>>>((ref) {
      return PostNotifier();
    });

class PostNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PostNotifier() : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  final _supabase = Supabase.instance.client;
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  Timer? _debounceTimer;
  final Map<String, bool> _pendingLikes = {};

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      _isLoadingMore = false;
      state = const AsyncValue.loading();
      return;
    }

    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;

    try {
      final from = _page * 10;
      final to = from + 9;

      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      final List<dynamic> data = response as List<dynamic>;
      final List<Post> newPosts = data
          .map((json) => Post.fromJson(json))
          .toList();

      if (refresh) {
        state = AsyncValue.data(newPosts);
      } else {
        final currentPosts = state.value ?? [];
        state = AsyncValue.data([...currentPosts, ...newPosts]);
      }

      _hasMore = newPosts.length == 10;
      _page++;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get isLoadingMore => _isLoadingMore;

  void toggleLike(String postId) {
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = currentPosts[index];
    final wasLiked = post.isLiked;

    final updatedPost = post.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked ? post.likeCount - 1 : post.likeCount + 1,
    );

    final newList = [...currentPosts];
    newList[index] = updatedPost;
    state = AsyncValue.data(newList);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (_pendingLikes[postId] == true) return;
      _pendingLikes[postId] = true;

      try {
        await _supabase.rpc(
          'toggle_like',
          params: {'p_post_id': postId, 'p_user_id': 'user_123'},
        );
      } catch (e) {
        final latestPosts = state.value;
        if (latestPosts != null) {
          final idx = latestPosts.indexWhere((p) => p.id == postId);
          if (idx != -1) {
            final revertList = [...latestPosts];
            revertList[idx] = post;
            state = AsyncValue.data(revertList);
          }
        }
      } finally {
        _pendingLikes.remove(postId);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

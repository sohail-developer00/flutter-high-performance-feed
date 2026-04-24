import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../core/logger.dart';

class PostService {
  final SupabaseClient _client;

  PostService(this._client);

  Future<List<Post>> fetchPosts({
    required int page,
    required int pageSize,
    required String userId,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from('posts')
          .select('*, user_likes(user_id)')
          .order('created_at', ascending: false)
          .range(from, to);

      final List<dynamic> data = response as List<dynamic>;
      
      return data.map((json) {
        final List<dynamic> likes = json['user_likes'] ?? [];
        final isLiked = likes.any((like) => like['user_id'] == userId);
        return Post.fromJson({...json, 'user_liked': isLiked});
      }).toList();
    } catch (e, st) {
      logger.e("Error fetching posts", error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      await _client.rpc('toggle_like', params: {
        'p_post_id': postId,
        'p_user_id': userId,
      });
    } catch (e, st) {
      logger.e("Error toggling like", error: e, stackTrace: st);
      rethrow;
    }
  }
}

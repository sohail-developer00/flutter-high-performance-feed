import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Post>> fetchPosts({required int page, required int limit, String? userId}) async {
    final from = page * limit;
    final to = from + limit - 1;

    // Use simple select() as requested by user to avoid blank screen issues
    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

    final List<dynamic> data = response as List<dynamic>;
    
    // Since we can't join user_likes in this query as per user instruction, 
    // we would ideally fetch user's likes separately. 
    // For now, we'll map them.
    return data.map((json) => Post.fromJson(json, userId: userId)).toList();
  }

  Future<void> toggleLike(String postId, String userId) async {
    await _client.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': userId,
    });
  }
}

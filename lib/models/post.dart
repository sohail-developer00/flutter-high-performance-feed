class Post {
  final String id;
  final DateTime createdAt;
  final String thumbUrl;
  final String mobileUrl;
  final String rawUrl;
  final int likeCount;
  final bool isLiked;

  Post({
    required this.id,
    required this.createdAt,
    required this.thumbUrl,
    required this.mobileUrl,
    required this.rawUrl,
    required this.likeCount,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json, {String? userId}) {
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      thumbUrl: json['media_thumb_url'] ?? '',
      mobileUrl: json['media_mobile_url'] ?? '',
      rawUrl: json['media_raw_url'] ?? '',
      likeCount: json['like_count'] ?? 0,
      isLiked: false, // Default to false as per simple select() requirement
    );
  }

  Post copyWith({
    String? id,
    DateTime? createdAt,
    String? thumbUrl,
    String? mobileUrl,
    String? rawUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      mobileUrl: mobileUrl ?? this.mobileUrl,
      rawUrl: rawUrl ?? this.rawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

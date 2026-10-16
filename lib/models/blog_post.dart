class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime publishDate;
  final String authorName;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final List<Comment> comments;
  final String category;
  final int likes;
  final bool isSubscribed;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.publishDate,
    required this.authorName,
    this.beforeImageUrl,
    this.afterImageUrl,
    required this.comments,
    required this.category,
    this.likes = 0,
    this.isSubscribed = false,
  });

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? publishDate,
    String? authorName,
    String? beforeImageUrl,
    String? afterImageUrl,
    List<Comment>? comments,
    String? category,
    int? likes,
    bool? isSubscribed,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      publishDate: publishDate ?? this.publishDate,
      authorName: authorName ?? this.authorName,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
      comments: comments ?? this.comments,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.userAvatar,
  });
} 
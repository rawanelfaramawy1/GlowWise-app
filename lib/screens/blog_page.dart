import 'package:flutter/material.dart';
import 'user_profile_page.dart';
import '../models/blog_post.dart';
import 'package:intl/intl.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  bool isSubscribed = false;
  final TextEditingController _commentController = TextEditingController();
  List<BlogPost> blogPosts = [
    BlogPost(
      id: '1',
      title: 'Transform Your Skincare Routine',
      content:
          'Learn how to achieve that perfect glow with our comprehensive skincare guide. Start with gentle cleansing, followed by targeted treatments, and always finish with proper moisturization. Remember to be consistent with your routine for the best results!\n\nKey steps:\n1. Double cleansing\n2. Toning\n3. Serum application\n4. Moisturizing\n5. Sun protection',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      authorName: 'Sarah Johnson',
      beforeImageUrl: 'assets/images/natural_oils.jpg',
      afterImageUrl: 'assets/images/glowing_skin.jpg',
      category: 'Skincare Tips',
      comments: [
        Comment(
          id: '1',
          userId: '123',
          userName: 'Emily',
          content:
              'Amazing tips! I\'ve been following this routine for a week and already see results!',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
    BlogPost(
      id: '2',
      title: 'Understanding Different Skin Types',
      content:
          'Knowing your skin type is crucial for choosing the right products. Whether you have oily, dry, combination, or sensitive skin, each type requires specific care and attention. Learn how to identify your skin type and choose products that work best for you.',
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      authorName: 'Dr. Lisa Chen',
      beforeImageUrl: 'assets/images/skin_types.png',
      afterImageUrl: 'assets/images/cleanser.jpg',
      category: 'Education',
      comments: [
        Comment(
          id: '2',
          userId: '124',
          userName: 'Michael',
          content:
              'Finally understood why some products weren\'t working for me. Great article!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    BlogPost(
      id: '3',
      title: 'The Power of Natural Ingredients',
      content:
          'Discover how natural ingredients can transform your skin. From vitamin C to hyaluronic acid, learn about the most effective natural ingredients for your skincare routine.',
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      authorName: 'Maria Garcia',
      beforeImageUrl: 'assets/images/serum.jpg',
      afterImageUrl: 'assets/images/skincare_education.png',
      category: 'Natural Skincare',
      comments: [],
    ),
  ];

  void _toggleSubscription() {
    setState(() {
      isSubscribed = !isSubscribed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSubscribed
              ? 'Subscribed to blog updates!'
              : 'Unsubscribed from blog updates',
        ),
        backgroundColor: isSubscribed ? Colors.green : Colors.grey,
      ),
    );
  }

  void _showCommentDialog(BlogPost post) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Comment'),
            content: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    setState(() {
                      post.comments.add(
                        Comment(
                          id: DateTime.now().toString(),
                          userId: 'current_user_id',
                          userName: 'Current User',
                          content: _commentController.text,
                          timestamp: DateTime.now(),
                        ),
                      );
                    });
                    _commentController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                ),
                child: const Text('Post'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
        actions: [
          IconButton(
            icon: Icon(
              isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
            tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
            onPressed: _toggleSubscription,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new blog post creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon: Create new blog post')),
          );
        },
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 106, 56, 122),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Title and Date
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMMM d, y').format(post.publishDate),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            post.authorName,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Before/After Images
                if (post.beforeImageUrl != null && post.afterImageUrl != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Before & After Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      post.beforeImageUrl!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Before',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      post.afterImageUrl!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'After',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Comments Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comments (${post.comments.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showCommentDialog(post),
                              icon: const Icon(Icons.add_comment),
                              label: const Text('Add Comment'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  106,
                                  56,
                                  122,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (post.comments.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: post.comments.length,
                          itemBuilder: (context, commentIndex) {
                            final comment = post.comments[commentIndex];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  106,
                                  56,
                                  122,
                                ),
                                child: Text(
                                  comment.userName[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(comment.userName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.content),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'MMM d, y • h:mm a',
                                    ).format(comment.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
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
    );
  }
}

class AddBlogPostPage extends StatefulWidget {
  const AddBlogPostPage({super.key});

  @override
  State<AddBlogPostPage> createState() => _AddBlogPostPageState();
}

class _AddBlogPostPageState extends State<AddBlogPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPost = BlogPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        authorName: 'Anonymous',
        publishDate: DateTime.now(),
        beforeImageUrl: null,
        afterImageUrl: null,
        category: 'General',
        comments: [],
      );
      Navigator.pop(context, newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter content'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Publish')),
            ],
          ),
        ),
      ),
    );
  }
}

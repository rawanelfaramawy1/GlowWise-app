import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'skin_analysis_page.dart';

class Ad {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final bool isActive;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.isActive,
  });

  factory Ad.fromMap(Map<String, dynamic> map) {
    return Ad(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      link: map['link'] ?? '',
      isActive: map['isActive'] ?? false,
    );
  }
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  List<String> savedArticles = [];
  Map<String, List<Comment>> comments = {};
  List<Ad> ads = [];
  bool isLoadingAds = true;

  final List<ServiceArticle> articles = [
    ServiceArticle(
      title: 'Product Consultation',
      description: '1 hr · Location 1',
      price: '\$40.00',
      imageUrl: 'assets/images/selfcare_banner.png',
      content: 'Get personalized product recommendations from our experts...',
      isBookmarked: false,
    ),
    ServiceArticle(
      title: 'Skin Analysis',
      description: '1 hr · Location 1',
      price: '\$30.00',
      imageUrl: 'assets/images/selfcare_banner.png',
      content: 'Professional analysis of your skin type and concerns...',
      isBookmarked: false,
    ),
    ServiceArticle(
      title: 'Skincare Education',
      description: 'Location 1',
      price: '\$50.00 per participant',
      imageUrl: 'assets/images/selfcare_banner.png',
      content: 'Learn about proper skincare techniques and routines...',
      isBookmarked: false,
    ),
  ];

  final List<Product> recommendedProducts = [
    Product(
      name: 'Gentle Cleanser',
      description: 'Perfect for sensitive skin',
      price: 25.99,
      rating: 4.5,
      reviews: 128,
      imageUrl: 'assets/images/selfcare_banner.png',
    ),
    Product(
      name: 'Vitamin C Serum',
      description: 'Brightening & anti-aging',
      price: 45.99,
      rating: 4.8,
      reviews: 256,
      imageUrl: 'assets/images/selfcare_banner.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('ads')
              .where('isActive', isEqualTo: true)
              .get();

      setState(() {
        ads =
            snapshot.docs
                .map(
                  (doc) => Ad.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  }),
                )
                .toList();
        isLoadingAds = false;
      });
    } catch (e) {
      print('Error loading ads: $e');
      setState(() {
        isLoadingAds = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + ads.length, // Simplified count
        itemBuilder: (context, index) {
          // Show ad after every 2 services
          if (index > 0 && index % 3 == 0 && (index ~/ 3) - 1 < ads.length) {
            return _buildAdCard(ads[(index ~/ 3) - 1]);
          }
          // Show service card
          final serviceIndex = index - ((index ~/ 3));
          if (serviceIndex < articles.length) {
            return _buildServiceCard(articles[serviceIndex]);
          }
          return const SizedBox.shrink(); // Return empty widget if index is out of range
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SkinAnalysisPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildAdCard(Ad ad) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Handle ad click
          print('Ad clicked: ${ad.title}');
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                ad.imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ad.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sponsored',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceArticle article) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showServiceDetails(article),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    article.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      article.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color:
                          article.isBookmarked
                              ? const Color.fromARGB(255, 106, 56, 122)
                              : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        article.isBookmarked = !article.isBookmarked;
                      });
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(article.description),
                  Text(
                    article.price,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 106, 56, 122),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Book Now'),
                        onPressed: () => _showBookingDialog(article),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            106,
                            56,
                            122,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showServiceDetails(article),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            106,
                            56,
                            122,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Learn More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(ServiceArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceDetailScreen(
              article: article,
              recommendedProducts: recommendedProducts,
            ),
      ),
    );
  }

  void _showBookingDialog(ServiceArticle article) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book ${article.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Select Date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      // Handle date selection
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Select Time'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      // Handle time selection
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking confirmed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                ),
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
    );
  }

  void _toggleAudio() {
    setState(() {
      isPlaying = !isPlaying;
      // Implement audio playback logic here
    });
  }
}

class ServiceArticle {
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final String content;
  bool isBookmarked;

  ServiceArticle({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.content,
    this.isBookmarked = false,
  });
}

class Product {
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });
}

class ServiceDetailScreen extends StatefulWidget {
  final ServiceArticle article;
  final List<Product> recommendedProducts;

  const ServiceDetailScreen({
    super.key,
    required this.article,
    required this.recommendedProducts,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? selectedAnswer;
  bool hasSubmittedAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        backgroundColor: const Color.fromARGB(255, 106, 56, 122),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.article.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.article.description),
                  Text(
                    widget.article.price,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 106, 56, 122),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.article.content),
                  const SizedBox(height: 24),
                  _buildRecommendedProducts(),
                  const SizedBox(height: 24),
                  _buildMiniQuiz(),
                  const SizedBox(height: 24),
                  _buildCommentSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _showBookingDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 106, 56, 122),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Book Now'),
        ),
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = widget.recommendedProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imageUrl,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color.fromARGB(255, 106, 56, 122),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(' ${product.rating} (${product.reviews})'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                minimumSize: const Size(double.infinity, 30),
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniQuiz() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Knowledge Check',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'What\'s the main benefit of this service?',
              style: TextStyle(fontSize: 16),
            ),
            _buildQuizOption('A', 'Immediate results'),
            _buildQuizOption('B', 'Long-term skin health'),
            _buildQuizOption('C', 'Cost-effective solution'),
            const SizedBox(height: 16),
            if (!hasSubmittedAnswer)
              ElevatedButton(
                onPressed: () {
                  if (selectedAnswer != null) {
                    setState(() {
                      hasSubmittedAnswer = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Check Answer'),
              ),
            if (hasSubmittedAnswer)
              Container(
                padding: const EdgeInsets.all(16),
                color:
                    selectedAnswer == 'B'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                child: Text(
                  selectedAnswer == 'B'
                      ? 'Correct! This service focuses on long-term skin health.'
                      : 'Not quite. The main benefit is long-term skin health.',
                  style: TextStyle(
                    color: selectedAnswer == 'B' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(String option, String text) {
    return RadioListTile<String>(
      title: Text(text),
      value: option,
      groupValue: selectedAnswer,
      onChanged:
          hasSubmittedAnswer
              ? null
              : (String? value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
      activeColor: const Color.fromARGB(255, 106, 56, 122),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews & Discussion',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {},
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildComment(
          'Sarah',
          'Amazing service! The consultation was very helpful.',
          '2h ago',
          24,
        ),
        _buildComment(
          'Mike',
          'Very professional and knowledgeable staff.',
          '5h ago',
          15,
        ),
      ],
    );
  }

  Widget _buildComment(
    String username,
    String comment,
    String timeAgo,
    int likes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 106, 56, 122),
            child: Text(
              username[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                      iconSize: 16,
                    ),
                    Text('$likes'),
                    const SizedBox(width: 16),
                    TextButton(onPressed: () {}, child: const Text('Reply')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book ${widget.article.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Select Date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      // Handle date selection
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Select Time'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      // Handle time selection
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking confirmed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 56, 122),
                ),
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
    );
  }
}

class Comment {
  final String username;
  final String text;
  final String timeAgo;
  int likes;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.text,
    required this.timeAgo,
    this.likes = 0,
    this.replies = const [],
  });
}

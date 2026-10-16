import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    // Helper function to safely convert to double
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    // Helper function to safely convert to int
    int safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    return Product(
      id: id,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: safeToDouble(map['price']),
      imageUrl: map['imageUrl']?.toString() ?? '',
      rating: safeToDouble(map['rating']),
      reviews: safeToInt(map['reviews']),
      category: map['category']?.toString() ?? '',
    );
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Product> products = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  List<String> categories = ['All'];
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartItems();
  }

  Future<void> _loadProducts() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        products =
            snapshot.docs
                .map(
                  (doc) => Product.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList();

        // Extract unique categories
        categories = ['All'] + products.map((p) => p.category).toSet().toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadCartItems() {
    FirebaseFirestore.instance.collection('cart').snapshots().listen((
      snapshot,
    ) {
      setState(() {
        cartItems =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {...data, 'id': doc.id};
            }).toList();
      });
    });
  }

  bool _isInCart(String productId) {
    return cartItems.any((item) => item['productId'] == productId);
  }

  int _getCartQuantity(String productId) {
    final item = cartItems.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  void _updateCartItem(String productId, bool increase) {
    final item = cartItems.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => <String, dynamic>{},
    );

    if (item.isEmpty) {
      // Add new item
      final product = products.firstWhere((p) => p.id == productId);
      FirebaseFirestore.instance.collection('cart').add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'description': product.description,
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing item
      final newQuantity =
          increase
              ? (item['quantity'] ?? 1) + 1
              : (item['quantity'] ?? 1) > 1
              ? (item['quantity'] ?? 1) - 1
              : 1;

      if (newQuantity > 0) {
        FirebaseFirestore.instance.collection('cart').doc(item['id']).update({
          'quantity': newQuantity,
        });
      } else {
        FirebaseFirestore.instance.collection('cart').doc(item['id']).delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EDE5),
      appBar: AppBar(
        title: const Text('Glow Shop 🛍️'),
        backgroundColor: const Color(0xFFC1555E),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFC1555E).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFC1555E),
                    labelStyle: TextStyle(
                      color:
                          selectedCategory == category
                              ? const Color(0xFFC1555E)
                              : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          // Products Grid
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount:
                          products
                              .where(
                                (p) =>
                                    selectedCategory == 'All' ||
                                    p.category == selectedCategory,
                              )
                              .length,
                      itemBuilder: (context, index) {
                        final product =
                            products
                                .where(
                                  (p) =>
                                      selectedCategory == 'All' ||
                                      p.category == selectedCategory,
                                )
                                .toList()[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  product.imageUrl,
                                  height: 90,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 90,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 30),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            product.description,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 9,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 8,
                                                color: Colors.amber,
                                              ),
                                              Text(
                                                ' ${product.rating} (${product.reviews})',
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Color(0xFFC1555E),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (_isInCart(product.id))
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                    size: 14,
                                                  ),
                                                  onPressed:
                                                      () => _updateCartItem(
                                                        product.id,
                                                        false,
                                                      ),
                                                  color: const Color(
                                                    0xFFC1555E,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                                Text(
                                                  '${_getCartQuantity(product.id)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 14,
                                                  ),
                                                  onPressed:
                                                      () => _updateCartItem(
                                                        product.id,
                                                        true,
                                                      ),
                                                  color: const Color(
                                                    0xFFC1555E,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            )
                                          else
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_shopping_cart,
                                              ),
                                              color: const Color(0xFFC1555E),
                                              iconSize: 14,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed:
                                                  () => _updateCartItem(
                                                    product.id,
                                                    true,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roowanglow/screens/services_page.dart';
import 'package:roowanglow/screens/shop_page.dart';
import 'package:roowanglow/screens/schedule_page.dart'; // فيها SelfCareHomePage
// ✅ LoginPage import
import 'package:roowanglow/screens/cart_page.dart';
import 'package:roowanglow/screens/user_profile_page.dart'; // Add import for UserProfilePage
import 'welcome_screen.dart'; // استدعاء شاشة الترحيب
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roowanglow/utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log every Flutter framework error (layout, build, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FLUTTER ERROR] ${details.exceptionAsString()}');
    debugPrint('[FLUTTER ERROR] stack: ${details.stack}');
  };

  // Log any uncaught async error
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[UNCAUGHT ERROR] $error');
    debugPrint('[UNCAUGHT ERROR] stack: $stack');
    return true;
  };

  debugPrint('[MAIN] Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAt20N-J8h-lNBzXcMMFH0xl7NtbXGhwrs',
        appId: '1:1064209159921:android:641b319150a4b5e18dfb50',
        messagingSenderId: '1064209159921',
        projectId: 'glowwise-app',
        storageBucket: 'glowwise-app.firebasestorage.app',
      ),
    );
    debugPrint('[MAIN] Firebase initialized: ${Firebase.app().options.projectId}');
  } catch (e, stack) {
    debugPrint('[MAIN] Firebase initialization FAILED: $e');
    debugPrint('[MAIN] stack: $stack');
  }

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    debugPrint('[AUTH] State changed: ${user == null ? 'signed out' : 'signed in as ${user.email} (uid: ${user.uid})'}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    const GlowWhisePage(),
    const SkincareSchedulePage(),
    const ServicesScreen(),
    const ShopPage(),
    const CartPage(),
  ];

  List<Map<String, dynamic>> navItems = [
    {"icon": "home.png", "label": "Home", "color": const Color(0xFFC1555E)},
    {
      "icon": "calendar.png",
      "label": "Schedule",
      "color": const Color(0xFF6A387A),
    },
    {
      "icon": "support.png",
      "label": "Services",
      "color": const Color(0xFF2E3C45),
    },
    {"icon": "cart.png", "label": "Shop", "color": const Color(0xFF2E3C45)},
    {"icon": "cart.png", "label": "Cart", "color": const Color(0xFFC1555E)},
  ];

  void _onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class GlowWhisePage extends StatefulWidget {
  const GlowWhisePage({super.key});

  @override
  State<GlowWhisePage> createState() => _GlowWhisePageState();
}

class _GlowWhisePageState extends State<GlowWhisePage> {
  final _chatFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  void _showChatDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _chatFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Start a Chat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC1555E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.message),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_chatFormKey.currentState!.validate()) {
                              // Here you would typically send the chat message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Message sent successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC1555E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.group_add,
                    size: 50,
                    color: Color(0xFF6A387A),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A387A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Share this link with your friends to invite them to join Glow Whise!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'https://glowwhise.com/invite/xyz123',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Here you would typically copy the link
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invite link copied to clipboard!',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          color: const Color(0xFF6A387A),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.facebook),
                        onPressed: () {
                          // Share on Facebook
                          Navigator.pop(context);
                        },
                        color: const Color(0xFF1877F2),
                      ),

                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.whatsapp),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.telegram),
                        onPressed: () {
                          // Share on Telegram
                          Navigator.pop(context);
                        },
                        color: const Color(0xFF0088CC),
                      ),
                      IconButton(
                        icon: const Icon(Icons.email),
                        onPressed: () {
                          // Share via email
                          Navigator.pop(context);
                        },
                        color: const Color(0xFF6A387A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showThankYouMessage() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFC1555E),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thank You!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC1555E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We appreciate your interest in chatting with us. Our team will be with you shortly!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC1555E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/header_bg.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(
                          'assets/images/profile_pic.jpg',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 60,
                    child: GestureDetector(
                      onTap: _showThankYouMessage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/icons/messenger.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/icons/cart.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Card
            Card(
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/icons/customer-service.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "glow whise",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF6A387A),
                              ),
                            ),
                            Text(
                              "Perfect Skin, Perfect You",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "1 Member",
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextSpan(text: "  |  "),
                          TextSpan(
                            text: "General Info >",
                            style: TextStyle(color: Colors.brown),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _showInviteDialog,
                          icon: const Icon(Icons.person_add_alt),
                          label: const Text("Invite"),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6A387A)),
                            foregroundColor: Color(0xFF6A387A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _showChatDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC1555E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Chat with Us"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Create Post
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: Color(0xFFC1555E)),
                  SizedBox(width: 8),
                  Text(
                    "Create Post",
                    style: TextStyle(color: Color(0xFFC1555E)),
                  ),
                ],
              ),
            ),

            // Post Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/post_img.jpg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> navItems = [
      {"icon": "home.png", "label": "Home", "color": const Color(0xFFC1555E)},
      {
        "icon": "calendar.png",
        "label": "Schedule",
        "color": const Color(0xFF6A387A),
      },
      {
        "icon": "support.png",
        "label": "Services",
        "color": const Color(0xFF2E3C45),
      },
      {
        "icon": "messenger.png",
        "label": "Blog",
        "color": const Color(0xFF2E3C45),
      },
      {"icon": "cart.png", "label": "Shop", "color": const Color(0xFF2E3C45)},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE5),
        border: const Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == widget.currentIndex;
          return GestureDetector(
            onTap: () {
              // Play animation when tapped
              _animationController.forward().then((_) {
                _animationController.reverse();
              });

              // Provide haptic feedback
              HapticFeedback.lightImpact();

              // Call the onTap callback
              widget.onTap(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 12,
                vertical: isSelected ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: navItems[index]["color"].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      'assets/icons/${navItems[index]["icon"]}',
                      width: 24,
                      height: 24,
                      color:
                          isSelected
                              ? navItems[index]["color"]
                              : const Color(0xFF2E3C45),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      navItems[index]["label"],
                      style: TextStyle(
                        fontSize: 14,
                        color: navItems[index]["color"],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message = 'حدث خطأ أثناء تسجيل الدخول';
        if (e.code == 'user-not-found') {
          message = 'البريد الإلكتروني غير مسجل';
        } else if (e.code == 'wrong-password') {
          message = 'كلمة المرور غير صحيحة';
        }
        ErrorHandler.showError(context, AppError(message: message));
      } catch (error) {
        if (!mounted) return;
        final appError = ErrorHandler.handleException(error);
        ErrorHandler.showError(context, appError);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add your login screen UI here
    return Container();
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الصورة الخلفية المنغوشة
          SizedBox.expand(
            child: Image.asset(
              'assets/images/logo.jpg', // حط اسم الصورة بتاعتك هنا
              fit: BoxFit.cover,
            ),
          ),

          // طبقة التمويه
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // درجة النغشة
              child: Container(
                color: Colors.black.withOpacity(0.1), // تغطية خفيفة شفافة
              ),
            ),
          ),

          // محتوى الشاشة
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'GlowWise',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

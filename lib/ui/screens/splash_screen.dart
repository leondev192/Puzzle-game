import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fill_information.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _navigateAfterDelay(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    // Chờ 3 giây
    await Future.delayed(const Duration(seconds: 2));

    // Điều hướng dựa trên trạng thái
    if (username != null && username.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PuzzleGame()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FillInformation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _navigateAfterDelay(context); // Gọi hàm kiểm tra và điều hướng

    return Scaffold(
      backgroundColor: Colors.white, // Màu nền cho splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc hình ảnh Splash
            Image.asset(
              'assets/images/logo.png', // Đường dẫn hình ảnh
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.deepOrangeAccent,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

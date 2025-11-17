import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Chuyển sang Home sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/home');
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Ảnh giữa màn hình
            Center(
              child: Image.asset("assets/images/logo.png", width: 100,height:100),
            ),

            // Footer cố định dưới cùng
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/logo.png", width: 200),
                  const SizedBox(height: 8),
                  const Text(
                    "Copyright © 2025 MISA JSC",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
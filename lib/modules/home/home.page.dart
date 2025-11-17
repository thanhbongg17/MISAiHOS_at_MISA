import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/login.controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng: ${authController.userEmail.value}',
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Trạng thái đăng nhập: ${authController.isLoggedIn.value}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        )),
      ),
    );
  }
}
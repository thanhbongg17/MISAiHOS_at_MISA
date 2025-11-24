import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/login.controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.put(LoginController());
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final Uri _forgotPasswordUrl = Uri.parse(
    'https://id.misa.vn/account/forgotpassword?returnUrl=%2Fconnect&username=',
  );
  Future<void> _launchUrl() async {
    if (!await launchUrl(_forgotPasswordUrl)) {
      throw Exception('Không thể mở $_forgotPasswordUrl');
    }
  }

  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset("assets/images/logo.png", width: 90), // icon MISA
                const SizedBox(height: 16),
                const Text(
                  "MISA iHOS",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: !showPass,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showPass = !showPass),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF21D4B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      controller.login(
                        context,
                        emailCtrl.text.trim(),
                        passCtrl.text.trim(),
                      );
                    },
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Forgot password
                TextButton(
                  onPressed: _launchUrl,
                  child: const Text(
                    "Quên mật khẩu?",
                    style: TextStyle(color: Color(0xFF5A63D9)),
                  ),
                ),

                const SizedBox(height: 200),
                Image.asset("assets/images/logo.png", width: 150),
                const SizedBox(height: 20),
                const Text(
                  "Copyright © 2025 MISA JSC",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

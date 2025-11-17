import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  var userEmail = ''.obs;

  // Hàm login
  void login(
      BuildContext context,
      String email,
      String password) {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin');
      return;
    }

    // Demo login
    if (email == "thanh.com" && password == "1") {
      isLoggedIn.value = true;
      userEmail.value = email;
      Get.offNamed('/loading'); // chuyển sang màn hình chờ
    } else {
      Get.snackbar('Lỗi', 'Email hoặc mật khẩu không đúng');
    }
  }

  // Logout
  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    Get.offNamed('/'); // quay về LoginPage
  }
}
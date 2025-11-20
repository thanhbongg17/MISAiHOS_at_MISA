import 'package:flutter/material.dart'; // Thay Cupertino bằng Material
import 'package:get/get.dart';
// Import các Service và Model cần thiết cho API
import '../../../data/services/login/login.service.dart';
import '../../../data/models/login/login.model.dart';

class LoginController extends GetxController {
  // Khởi tạo AuthService
  final AuthService _authService = AuthService();

  // State variables
  var isLoggedIn = false.obs;
  var userEmail = ''.obs;
  var accessToken = ''.obs; // Lưu trữ Token nhận được
  var isLoading = false.obs; // Trạng thái loading
  var userContext = Rx<UserContext?>(null); // Lưu thông tin Context người dùng

  // Hàm login (Cần sửa thành async để gọi API)
  Future<void> login(
      BuildContext context,
      String email,
      String password) async {

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true; // Bắt đầu loading

    // GIẢ LẬP DEVICE ID - Cần thay thế bằng giá trị lấy từ thiết bị thực
    const String deviceId = "Android_7010ce7f9eb7116a";

    try {
      final response = await _authService.login(email, password, deviceId);

      if (response.code == 200 && response.data != null) {
        // 1 --- ĐĂNG NHẬP THÀNH CÔNG ---
        isLoggedIn.value = true;
        userEmail.value = response.data!.context.email;
        accessToken.value = response.data!.token;
        userContext.value = response.data!.context;

        // Lưu Token/Context vào bộ nhớ cục bộ (GetStorage) ở đây nếu cần

        // Navigate to named route so route-level bindings run and HomeController is created
        print('[LoginController] login successful, navigating to /maincontent');
        Get.snackbar('Đăng nhập', 'Đăng nhập thành công', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed('/loading');

      }
      //2 -----sai mật khẩu
      else if(response.code == 401 || !response.status){
        Get.snackbar(
          'tên đăng nhập hoặc mật khẩu không đúng',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText:Colors.white,

        );
      }
      else {
        // Xử lý lỗi trả về từ API (nếu code != 200 nhưng không throw exception)
        Get.snackbar('Lỗi Đăng nhập', response.message, snackPosition: SnackPosition.BOTTOM);
      }

    } catch (e) {
      // Xử lý lỗi kết nối, exception từ service
      Get.snackbar('Lỗi Kết nối', e.toString().replaceFirst('Exception:', ''), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Kết thúc loading
    }
  }

  // Logout
  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    accessToken.value = '';
    userContext.value = null;
    Get.offAllNamed('/'); // Chuyển về LoginPage và xóa stack
  }
}
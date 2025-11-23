import 'package:flutter/material.dart'; // Thay Cupertino bằng Material
import 'package:get/get.dart';
// Import các Service và Model cần thiết cho API
import '../../../data/services/login/login.service.dart';
import '../../../data/models/login/login.model.dart';
import '../model/two_factor_arguments.dart';
import '../view/login/otp.two.factor.login.dart';

class LoginController extends GetxController {
  // Khởi tạo AuthService
  final AuthService _authService = AuthService();
  static const String _deviceId = "Android_7010ce7f9eb7116a";

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
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đủ thông tin',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true; // Bắt đầu loading

    try {
      final response = await _authService.login(email, password, _deviceId);

      // Debug: In ra response để kiểm tra
      print('[LoginController] Response code: ${response.code}');
      print('[LoginController] Response status: ${response.status}');
      print('[LoginController] Response message: ${response.message}');
      print(
        '[LoginController] Response data: ${response.data != null ? "có data" : "không có data"}',
      );

      if (response.code == 200 && response.status && response.data != null) {
        handleLoginSuccess(response);
      } else if (response.code == 122) {
        // 2 --- YÊU CẦU NHẬP MÃ OTP (Code 122) ---
        // Đây không phải lỗi mà là bước tiếp theo trong quy trình đăng nhập
        print('[LoginController] OTP required - Code 122');
        isLoading.value = false; // Kết thúc loading
        final args = TwoFactorArguments(
          userName: email,
          deviceId: _deviceId,
          challengeMessage: response.message.isNotEmpty
              ? response.message
              : 'Mã xác nhận đã được gửi. Vui lòng nhập mã vào ô trên.',
        );

        await Future.delayed(const Duration(milliseconds: 100));
        Get.to(
          () => const TwoFactorAuthScreen(),
          arguments: args,
        );
      } else {
        // 3 ----- XỬ LÝ CÁC TRƯỜNG HỢP LỖI
        // Code 101: Email hoặc số điện thoại không đúng định dạng
        // Code 102: Tên đăng nhập hoặc mật khẩu không đúng
        // Code 0: Lỗi không xác định
        print('[LoginController] Login failed - showing error message');
        isLoading.value = false; // Kết thúc loading trước khi hiển thị snackbar

        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Đã xảy ra lỗi. Vui lòng thử lại';

        // Đợi một chút để đảm bảo UI đã cập nhật
        await Future.delayed(const Duration(milliseconds: 100));

        // Sử dụng ScaffoldMessenger với context từ page để đảm bảo hiển thị
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.black,size:20),
                    const SizedBox(width: 12),
                    Expanded(
                      // Text lỗi (Không cần Column, đặt Text trực tiếp vào Expanded)
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        maxLines: 2, // Giới hạn tối đa 2 dòng
                        overflow: TextOverflow.ellipsis, // Thêm dấu "..." khi bị tràn
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        // Đảm bảo nút không bị ẩn
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          color: Colors.teal[800],
                          fontSize: 12, // Đã fix size 12
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       // Text(
                    //       //   errorTitle,
                    //       //   style: const TextStyle(
                    //       //     color: Colors.white,
                    //       //     fontWeight: FontWeight.bold,
                    //       //     fontSize: 16,
                    //       //   ),
                    //       // ),
                    //       // const SizedBox(height: 2),
                    //       Text(
                    //         errorMessage,
                    //         style: const TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //       TextButton(
                    //         onPressed: () {
                    //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    //         },
                    //         style: TextButton.styleFrom(
                    //           padding: EdgeInsets.zero,
                    //           minimumSize: Size.zero,
                    //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //         ),
                    //         child: Text(
                    //           'Đóng',
                    //           style: TextStyle(
                    //             color: Colors.teal[800],
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              backgroundColor: Colors.tealAccent[100],
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(
                // Tính toán để đặt SnackBar ngay dưới Status Bar:
                // Tổng chiều cao - Khoảng cách còn lại từ đáy màn hình
                bottom:
                    MediaQuery.of(context).size.height -
                    // Chiều cao Status Bar + Khoảng cách an toàn
                    (MediaQuery.of(context).padding.top +80),
                right: 30,
                left: 30,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Xử lý lỗi kết nối, exception từ service
      print('[LoginController] Exception caught: $e');
      isLoading.value = false; // Kết thúc loading trước khi hiển thị snackbar

      // Đợi một chút để đảm bảo UI đã cập nhật
      await Future.delayed(const Duration(milliseconds: 100));

      // Sử dụng ScaffoldMessenger với context từ page để đảm bảo hiển thị
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lỗi Kết nối',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.toString().replaceFirst('Exception:', ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      // isLoading đã được set = false ở trên rồi
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

  void handleLoginSuccess(LoginResponse response) {
    if (response.data == null) {
      isLoading.value = false;
      Get.snackbar(
        'Lỗi',
        'Không nhận được dữ liệu đăng nhập hợp lệ.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = false;
    isLoggedIn.value = true;
    userEmail.value = response.data!.context?.email ?? '';
    
    // Lưu token - QUAN TRỌNG: Token phải được lưu trước khi navigate
    accessToken.value = response.data!.token;
    userContext.value = response.data!.context;

    // Log để xác nhận token đã được lưu
    print('[LoginController] ✅ Token saved: ${accessToken.value.isNotEmpty ? "YES (${accessToken.value.length} chars)" : "NO (empty)"}');
    print('[LoginController] ✅ SessionId: ${userContext.value?.sessionId ?? "null"}');
    print('[LoginController] ✅ TenantId: ${userContext.value?.tenantId ?? "null"}');
    print('[LoginController] ✅ UserEmail: ${userEmail.value}');
    
    // Đảm bảo token đã được set trước khi navigate
    if (accessToken.value.isEmpty) {
      print('[LoginController] ❌ ERROR: Token is empty after login!');
      Get.snackbar(
        'Lỗi',
        'Không nhận được token đăng nhập.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print('[LoginController] login successful, navigating to /loading');
    Get.snackbar(
      'Đăng nhập',
      'Đăng nhập thành công',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // Navigate sau khi đảm bảo token đã được set
    Get.offNamed('/loading');
  }
}

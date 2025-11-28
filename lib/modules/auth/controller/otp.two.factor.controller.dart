import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/login/otp.two.factor.service.dart';
import '../model/two_factor_arguments.dart';
import 'login.controller.dart';

class TwoFactorController extends GetxController {
  TwoFactorController({required this.arguments});

  final TwoFactorArguments arguments;
  final TwoFactorAuthService _service = TwoFactorAuthService();

  // Biến để quản lý trạng thái checkbox "Không hỏi lại..."
  final rememberDevice = false.obs;

  // Biến để quản lý mã xác thực nhập vào
  final verificationCode = ''.obs;
  final isVerifying = false.obs;

  String get maskedDestination => arguments.challengeMessage;

  void toggleRememberDevice(bool? value) {
    if (value != null) {
      rememberDevice.value = value;
    }
  }

  void appendCode(String digit) {
    if (verificationCode.value.length < 6) {
      // Giới hạn mã 6 chữ số
      verificationCode.value += digit;
    }
  }

  void deleteLastDigit() {
    if (verificationCode.value.isNotEmpty) {
      verificationCode.value = verificationCode.value.substring(
        0,
        verificationCode.value.length - 1,
      );
    }
  }

  Future<void> verifyAndLogin(BuildContext context) async {
    if (verificationCode.value.length != 6) {
      _showSnackBar(
        context,
        title: 'Thiếu mã',
        message: 'Vui lòng nhập đủ 6 chữ số.',
        isError: true,
      );
      return;
    }

    // Làm sạch mã code: loại bỏ khoảng trắng và chỉ lấy số
    final cleanCode = verificationCode.value.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (cleanCode.length != 6) {
      _showSnackBar(
        context,
        title: 'Mã không hợp lệ',
        message: 'Mã xác thực chỉ được chứa số.',
        isError: true,
      );
      return;
    }

    isVerifying.value = true;
    try {
      final response = await _service.verifyCodeTwoFactor(
        code: cleanCode,
        userName: arguments.userName,
        deviceId: arguments.deviceId,
        rememberDevice: rememberDevice.value,
      );

      // Log response để debug
      debugPrint('[TwoFactorController] Response received:');
      debugPrint('  - Code: ${response.code}');
      debugPrint('  - Status: ${response.status}');
      debugPrint('  - Message: ${response.message}');
      debugPrint('  - Has Data: ${response.data != null}');
      if (response.data != null) {
        debugPrint('  - Token length: ${response.data!.token.length}');
        debugPrint('  - Has Context: ${response.data!.context != null}');
      }

      // Kiểm tra response thành công
      if (response.code == 200 && response.status) {
        // Kiểm tra có data không
        if (response.data != null && response.data!.token.isNotEmpty) {
          debugPrint(
            '[TwoFactorController] Xác thực thành công, xử lý đăng nhập...',
          );

          // Tìm LoginController để xử lý đăng nhập thành công
          LoginController? loginController;
          try {
            if (Get.isRegistered<LoginController>()) {
              loginController = Get.find<LoginController>();
              debugPrint('[TwoFactorController] Tìm thấy LoginController');
            } else {
              debugPrint(
                '[TwoFactorController] LoginController chưa được đăng ký',
              );
            }
          } catch (e) {
            debugPrint('[TwoFactorController] Lỗi khi tìm LoginController: $e');
          }

          if (loginController != null) {
            // Sử dụng LoginController để xử lý đăng nhập thành công
            debugPrint('[TwoFactorController] Gọi handleLoginSuccess...');
            loginController.handleLoginSuccess(response);
          } else {
            // Nếu không có LoginController, tự xử lý navigation
            debugPrint(
              '[TwoFactorController] Không có LoginController, tự chuyển đến /loading',
            );
            Get.offAllNamed('/loading');
          }
        } else {
          // Response code 200 nhưng không có data hoặc token rỗng
          debugPrint(
            '[TwoFactorController] Response code 200 nhưng không có data hoặc token rỗng',
          );
          _showSnackBar(
            context,
            title: 'Lỗi xác thực',
            message: 'Không nhận được thông tin đăng nhập. Vui lòng thử lại.',
            isError: true,
          );
        }
      } else {
        // Response code khác 200 hoặc status = false
        debugPrint(
          '[TwoFactorController] Xác thực thất bại: code=${response.code}, status=${response.status}',
        );
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Mã xác thực không đúng. Vui lòng kiểm tra lại.';

        _showSnackBar(
          context,
          title: 'Mã không hợp lệ',
          message: errorMessage,
          isError: true,
        );
      }
    } catch (e) {
      String errorMessage = 'Đã xảy ra lỗi khi xác thực mã.';

      // Xử lý thông điệp lỗi để hiển thị rõ ràng hơn
      final errorString = e.toString();
      if (errorString.contains('Exception:')) {
        errorMessage = errorString.replaceFirst('Exception:', '').trim();
      } else if (errorString.contains('FormatException')) {
        errorMessage = 'Lỗi định dạng dữ liệu từ server. Vui lòng thử lại sau.';
      } else {
        errorMessage = errorString;
      }

      // Log lỗi chi tiết để debug
      debugPrint('[TwoFactorController] Error: $e');

      _showSnackBar(
        context,
        title: 'Không xác thực được',
        message: errorMessage,
        isError: true,
      );
    } finally {
      isVerifying.value = false;
    }
  }

  void navigateBackToLogin() {
    Get.offAllNamed('/');
  }

  void _showSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
  }) {
    if (!context.mounted) return;
    final background = isError ? Colors.blueGrey[50] : Colors.blueAccent;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: Colors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message, style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: background,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
          // Tính toán để đặt SnackBar ngay dưới Status Bar:
          // Tổng chiều cao - Khoảng cách còn lại từ đáy màn hình
          bottom:
          MediaQuery.of(context).size.height -
              // Chiều cao Status Bar + Khoảng cách an toàn
              (MediaQuery.of(context).padding.top +80),
          right: 35,
          left: 35,
        ),
      ),
    );
  }
}

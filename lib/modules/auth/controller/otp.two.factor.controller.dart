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

    isVerifying.value = true;
    try {
      final response = await _service.verifyCodeTwoFactor(
        code: verificationCode.value,
        userName: arguments.userName,
        deviceId: arguments.deviceId,
        rememberDevice: rememberDevice.value,
      );

      if (response.code == 200 && response.status && response.data != null) {
        final loginController = Get.isRegistered<LoginController>()
            ? Get.find<LoginController>()
            : null;

        if (loginController != null) {
          loginController.handleLoginSuccess(response);
        } else {
          Get.snackbar(
            'Hoàn tất',
            'Xác thực thành công.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed('/loading');
        }
      } else {
        _showSnackBar(
          context,
          title: 'Mã không hợp lệ',
          message: response.message.isNotEmpty
              ? response.message
              : 'Vui lòng kiểm tra lại mã xác thực.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        context,
        title: 'Không xác thực được',
        message: e.toString().replaceFirst('Exception:', '').trim(),
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
    final background = isError ? Colors.redAccent : Colors.blueAccent;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: background,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

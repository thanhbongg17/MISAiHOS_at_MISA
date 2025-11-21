import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/otp.two.factor.controller.dart'; // Import Controller
import '../../model/two_factor_arguments.dart';

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller
    final args = Get.arguments as TwoFactorArguments?;
    final TwoFactorController controller = Get.put(
      TwoFactorController(
        arguments: args ??
            const TwoFactorArguments(
              userName: '',
              deviceId: '',
              challengeMessage:
                  'Mã xác nhận đã được gửi. Vui lòng nhập mã vào ô dưới.',
            ),
      ),
    );

    // Layout chính
    return Scaffold(
      backgroundColor: Colors.white,
      // Xóa AppBar mặc định và thay bằng nút Back
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: controller.navigateBackToLogin,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Nội dung cuộn chính
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo/Icon
                const SizedBox(height: 20),
                const Icon(
                  Icons.add_box, // Giả lập Icon dấu cộng màu xanh
                  color: Color(0xFF1ABC9C),
                  size: 60,
                ),
                const SizedBox(height: 30),

                // Tiêu đề
                const Text(
                  "Xác thực 2 bước",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Mô tả (Đã sử dụng dữ liệu tĩnh vì không có dữ liệu động)
                Text(
                  controller.maskedDestination,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Trường nhập mã xác thực (Chỉ để hiển thị input từ bàn phím tùy chỉnh)
                _buildVerificationInputField(controller),
                const SizedBox(height: 20),

                // Checkbox "Không hỏi lại trên thiết bị này"
                _buildRememberDeviceCheckbox(controller),
                const SizedBox(height: 30),

                // Nút "Vào ứng dụng"
                _buildMainActionButton(context, controller),
                const SizedBox(height: 15),

                // Nút "Thử cách khác" (TextLink)
                TextButton(
                  onPressed: () {
                    Get.snackbar("Thử cách khác", "Chức năng gửi lại mã hoặc gọi điện.");
                  },
                  child: const Text(
                    "Thử cách khác",
                    style: TextStyle(
                      color: Color(0xFF3498DB),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nút "Quay lại..."
                TextButton(
                  onPressed: controller.navigateBackToLogin,
                  child: const Text(
                    "Quay lại...ng nhập",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                // Khoảng trống đệm, tránh nội dung bị che bởi bàn phím
                const SizedBox(height: 350),
              ],
            ),
          ),

          // Bàn phím số tùy chỉnh (Đẩy lên trên cùng)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCustomKeypad(controller),
          ),
        ],
      ),
    );
  }

  // --- Các Widget phụ ---

  Widget _buildVerificationInputField(TwoFactorController controller) {
    return Obx(() => TextField(
      readOnly: true, // Không cho phép keyboard mặc định
      showCursor: true,
      textAlign: TextAlign.center,
      controller: TextEditingController(text: controller.verificationCode.value),
      decoration: InputDecoration(
        hintText: "Nhập mã xác thực",
        counterText: "", // Ẩn bộ đếm ký tự
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      keyboardType: TextInputType.none, // Vô hiệu hóa bàn phím mặc định
    ));
  }

  Widget _buildRememberDeviceCheckbox(TwoFactorController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: controller.rememberDevice.value,
          onChanged: controller.toggleRememberDevice,
          activeColor: const Color(0xFF1ABC9C),
        ),
        const Text(
          "Không hỏi lại trên thiết bị này",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    ));
  }

  Widget _buildMainActionButton(
    BuildContext context,
    TwoFactorController controller,
  ) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isVerifying.value
              ? null
              : () => controller.verifyAndLogin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1ABC9C), // Màu xanh ngọc
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFF9FDCCB),
          ),
          child: controller.isVerifying.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  "Vào ứng dụng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // --- Widget Bàn phím tùy chỉnh (Matching iOS Style) ---
  Widget _buildKey(String label, {String? subLabel, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 28, color: Colors.black87)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.normal, color: Colors.black87),
            ),
            if (subLabel != null)
              Text(
                subLabel,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomKeypad(TwoFactorController controller) {
    // Layout bàn phím số
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Hàng 1, 2, 3, 4
          ...[
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ].map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildKey(
                    key,
                    subLabel: {
                      '2': 'ABC',
                      '3': 'DEF',
                      '5': 'JKL',
                      '6': 'MNO',
                      '8': 'TUV',
                      '9': 'WXYZ',
                      '4': 'GHI',
                      '7': 'PQRS',
                    }[key],
                    onTap: () => controller.appendCode(key),
                  ),
                ),
              )).toList(),
            ),
          )).toList(),

          // Hàng cuối (0 và Xóa)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(), // Ô trống
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildKey('0', onTap: () => controller.appendCode('0')),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildKey('', icon: CupertinoIcons.delete_left_fill, onTap: controller.deleteLastDigit),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
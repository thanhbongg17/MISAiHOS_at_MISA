import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/otp.two.factor.controller.dart'; // Import Controller
import '../../model/two_factor_arguments.dart';


// Chuyển thành StatefulWidget
class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  late final TwoFactorController controller;
  final FocusNode _focusNode = FocusNode();
  final Color _misaGreen = const Color(0xFF27AE60);
  final Color _misaBlue = const Color(0xFF3498DB);
  final verificationCode = ''.obs;
  final textController = TextEditingController();
  bool _isKeypadVisible = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller trong initState
    final args = Get.arguments as TwoFactorArguments?;
    controller = Get.put(
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

    // Lắng nghe sự thay đổi của focus
    _focusNode.addListener(() {
      setState(() {
        _isKeypadVisible = _focusNode.hasFocus;
      });
    });
    // nhập mã xác thực
    textController.addListener(() {
      controller.verificationCode.value = textController.text;
    });
  }


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Hàm để ẩn bàn phím
  void _hideKeypad() {
    if (_isKeypadVisible) {
      _focusNode.unfocus(); // Sẽ trigger listener và ẩn bàn phím
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keypadHeight = 300.0; // Ước tính chiều cao bàn phím

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: controller.navigateBackToLogin,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Dùng GestureDetector để khi nhấn ra ngoài thì ẩn bàn phím
      resizeToAvoidBottomInset: true,//Cho phép giao diện tự co khi bàn phím xuất hiện
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child:Column (
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset("assets/images/logo.png", width: 80,height:80),
                const SizedBox(height: 10),

                // 2. Tiêu đề
                const Text(
                  "Xác thực 2 bước",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // 3. mã xác nhận đã đươợc gửi đến
                Text(
                  controller.maskedDestination,
                  style: const TextStyle(
                    fontSize: 16,

                  ),
                  // textAlign: TextAlign.center,
                ),
                //4 .ô nhập mã
                const SizedBox(height: 15),
                _buildVerificationInputField(controller),

                //5. không hỏi lại
                const SizedBox(height: 5),
                _buildRememberDeviceCheckbox(controller),
                //6.Xacs nhận
                const SizedBox(height: 10),
                _buildMainActionButton(context, controller),
                // quay lại đăng nhập
                TextButton(
                  onPressed: controller.navigateBackToLogin,
                  child: Text(
                    "Quay lại đăng nhập",
                    style: TextStyle(
                      color: _misaBlue,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Các Widget phụ (Không thay đổi nhiều) ---

  Widget _buildVerificationInputField(TwoFactorController controller) {
    return TextField(
      showCursor: true,
      textAlign: TextAlign.center,
      controller: textController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Nhập mã xác thực",
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2.0),
        ),
      ),
    );
  }


  Widget _buildRememberDeviceCheckbox(TwoFactorController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: controller.rememberDevice.value,
          onChanged: (value) {
            _hideKeypad(); // Ẩn bàn phím khi nhấn checkbox
            controller.toggleRememberDevice(value);
          },
          activeColor: const Color(0xFF3498DB),
        ),
        // Bọc Text trong GestureDetector để khi nhấn cũng ẩn bàn phím
        GestureDetector(
          onTap: () {
            _hideKeypad();
            controller.toggleRememberDevice(!controller.rememberDevice.value);
          },
          child: const Text(
            "Không hỏi lại trên thiết bị này",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
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
              : () {
            _hideKeypad(); // Ẩn bàn phím khi nhấn nút
            controller.verifyAndLogin(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27AE60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFF27AE60),
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
            "Xác nhận",
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
}
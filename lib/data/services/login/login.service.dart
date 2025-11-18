// auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/login/login.model.dart'; // Import models vừa tạo

class AuthService {
  final String baseUrl = "https://ihosapp.misa.vn/api/g1/auth/accounts";

  // Các header tĩnh cần thiết
  Map<String, String> get baseHeaders => {
    "x-sessionid": "",
    "AppVersion": "2.2",
    "Content-Type": "application/json",
    "DeviceOS": "Android",
    "DeviceType": "Smartphone",
    "DeviceName": "SM-M556B",
    "AppCode": "System",
    "DeviceId": "Android_7010ce7f9eb7116a", // Cần thay thế bằng DeviceId thực
    "OSVersion": "35",
    "x-culture": "vi",
    "Trace-Id": "c95dbe2a-051a-4beb-8fae-fccef001821b", // Cần tạo Trace-Id mới cho mỗi request
  };

  Future<LoginResponse> login(String username, String password, String deviceId) async {
    final url = Uri.parse('$baseUrl/login-mobile');

    // Cập nhật DeviceId và Trace-Id động
    final headers = Map<String, String>.from(baseHeaders);
    headers['DeviceId'] = deviceId;
    // Tốt nhất là tạo một Trace-Id UUID mới cho mỗi request thực tế

    final body = jsonEncode({
      "DeviceId": deviceId,
      "Password": password,
      "UserName": username,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Phân tích phản hồi
      final jsonMap = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(jsonMap);

      if (loginResponse.code == 200 && loginResponse.status) {
        // Đăng nhập thành công, lưu Token vào bộ nhớ cục bộ (SharedPreferences/GetStorage)
        // và chuyển hướng người dùng
        return loginResponse;
      } else {
        // Đăng nhập thất bại (Message nằm trong loginResponse.message)
        throw Exception(loginResponse.message);
      }
    } catch (e) {
      throw Exception("Lỗi kết nối hoặc xử lý dữ liệu: $e");
    }
  }
}
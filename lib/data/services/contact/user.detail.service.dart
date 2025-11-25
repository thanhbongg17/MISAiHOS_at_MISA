import 'dart:convert'; // 1. Bắt buộc import để dùng jsonDecode
import 'package:http/http.dart' as http;
import '../../models/contact/user.detail.model.dart';
import '../../../../token/token.manager.dart';

// ... class Repository ...
class UserDetailService {
  UserDetailService();
  Future<UserDetailModel?> getUserDetail() async {
    try {
      // 2. Với http phải dùng Uri.parse và điền FULL URL (http không tự nối base url như Dio)
      var url = Uri.parse('https://ihosapp.misa.vn/api/g1/mobile/qlcb/user/detail');

      // Token lấy từ bộ nhớ (SharedPreferences/GetStorage)
      // String token = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6IjY4Y2YwYjIyLWFiZmQtNGYxYS05ZjcxLTY5ODBmODQ1MDZiNyIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MDM5Mjg0LCJleHAiOjE3NjQwNjgwODQsImlhdCI6MTc2NDAzOTI4NCwiaXNzIjoiTUlTQUpTQyJ9.F-zg2g-VHgb-jvRZilffvk-CbzHnJoK_ajBwU77FS0Re0O2KUixCE_E7NtIEEvSke0zZmO3p3CM_cfa0qrsmUEBYEfrO6AwG13jDHvfL8mnMlqgaM0DAPhV3BoZeT-k3iWpnwRY5ozOZu8kQscHlYf_y4yjy7iTS_mwZYy2yWB4";
      String? token = await TokenManager.getToken();
      final response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
            // Các header giả lập thiết bị nếu API Misa yêu cầu chặt
            "AppVersion": "2.2",
          }
      );

      // 3. http trả về .statusCode (không phải status)
      if (response.statusCode == 200) {
        // 4. http trả về .body (String). Phải decode sang Map.
        // Dùng utf8.decode(response.bodyBytes) để CHỮ TIẾNG VIỆT không bị lỗi font
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        return UserDetailModel.fromJson(jsonData);
      } else {
        print("Lỗi tải data: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi lấy thông tin user: $e");
    }
    return null;
  }
}

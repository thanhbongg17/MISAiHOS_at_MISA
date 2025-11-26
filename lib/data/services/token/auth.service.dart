// gọi API refresh token khi token cũ hết hạn
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../token/token.manager.dart';

class AuthService {
  final String _refreshEndpoint = '/api/g1/auth/accounts/refresh-token';

  // Hàm gọi API đổi token
  Future<bool> refreshToken() async {
    try {
      final Uri uri = Uri.https('ihosapp.misa.vn', _refreshEndpoint);

      // Header lấy từ CURL Refresh của bạn
      final headers = {
        'Content-Type': 'application/json',
        'x-sessionid': TokenManager.xSessionId, // Dùng chung session cũ
        'AppCode': 'System',
        'AppVersion': '2.2',
        'DeviceOS': 'Android',
        'x-culture': 'vi',
      };

      // Body: Gửi refresh_token lên
      final body = {
        "refresh_token": TokenManager.refreshTokenValue
      };

      print("🔄 Đang làm mới Token...");

      final response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body)
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        // JSON trả về có key "accessToken" chứa Bearer token mới
        String? newToken = decoded['accessToken'];

        if (newToken != null) {
          // Lưu token mới vào TokenManager
          await TokenManager.saveNewToken(newToken);
          print("✅ Refresh thành công! Token mới: ${newToken.substring(0, 20)}...");
          return true;
        }
      }

      print("❌ Refresh thất bại: ${response.body}");
      return false;

    } catch (e) {
      print("❌ Lỗi Refresh Token: $e");
      return false;
    }
  }
}

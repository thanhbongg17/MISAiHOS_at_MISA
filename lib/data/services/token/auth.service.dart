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

      // Header lấy từ CURL Refresh của
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
        String? newRefresh = decoded['refreshToken'];
        // 2. Lấy Session ID Ngắn (Cookie)
        String? newSessionId = decoded['SessionId'];
        // 3. Lấy Session ID Dài (Header) - Nằm sâu trong AmisLoginInfo
        String? newXSessionId;
        if (decoded['AmisLoginInfo'] != null &&
            decoded['AmisLoginInfo']['User'] != null) {
          newXSessionId = decoded['AmisLoginInfo']['User']['SessionID'];
        }

        if (newToken != null&& newSessionId != null) {
          TokenManager.updateInfos(
            newAccessToken: newToken,
            newRefreshToken: newRefresh ?? TokenManager.refreshTokenValue, // Nếu null thì giữ cũ
            newSessionId: newSessionId,
            newXSessionId: newXSessionId ?? TokenManager.xSessionId, // Nếu null thì giữ cũ
          );

          print("✅ Refresh thành công trọn vẹn!");
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

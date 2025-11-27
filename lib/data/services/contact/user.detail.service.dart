import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/user.detail.model.dart';
import '../../../../token/token.manager.dart';
// 👇 Kiểm tra lại đường dẫn import này cho đúng thư mục của bạn
import '../token/auth.service.dart'; // Import AuthService

class UserDetailService {
  final String _endpoint = '/api/g1/mobile/qlcb/user/detail';

  Future<UserDetailModel?> getUserDetail() async {
    final Uri uri = Uri.https('ihosapp.misa.vn', _endpoint);

    // 1. Lấy token
    String? initialToken = await TokenManager.getToken();
    if (initialToken == null) return null;

    // 2. Hàm tạo Header động
    Map<String, String> createHeaders(String tokenToUse) {
      return {
        'Content-Type': 'application/json',
        "Authorization": tokenToUse.startsWith("Bearer ") ? tokenToUse : "Bearer $tokenToUse",
        "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
        "x-sessionid": TokenManager.xSessionId,
        "AppCode": "System",
        "AppVersion": "2.2",
      };
    }

    // 3. Hàm thực hiện Request (Dùng GET, không phải POST)
    Future<http.Response> performRequest(String currentToken) {
      return http.get(
        uri,
        headers: createHeaders(currentToken),
      );
    }

    try {
      print("API 1: Đang lấy thông tin User...");

      // Gọi lần 1
      var response = await performRequest(initialToken);

      // 4. Tự động Refresh Token nếu lỗi 401
      if (response.statusCode == 401) {
        print("API 1: Token hết hạn (401). Đang thử Refresh...");
        final authService = AuthService();
        bool refreshSuccess = await authService.refreshToken();

        if (refreshSuccess) {
          String? newToken = await TokenManager.getToken();
          if (newToken != null) {
            print("🔄 API 1: Gọi lại với Token mới...");
            response = await performRequest(newToken);
          }
        }
      }

      if (response.statusCode == 200) {
        var decodedBody = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(decodedBody);

        // Xử lý Data Wrapper
        var data = jsonData;
        if (jsonData is Map && jsonData.containsKey('Data')) {
          data = jsonData['Data'];
        }

        print("✅ API 1: Lấy thành công thông tin User");
        return UserDetailModel.fromJson(data);
      } else {
        print("❌ API 1 Lỗi Server: ${response.body}");
      }
    } catch (e) {
      print("❌ API 1 Lỗi Mạng: $e");
    }
    return null;
  }
}

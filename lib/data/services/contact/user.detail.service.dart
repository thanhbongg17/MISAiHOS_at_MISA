import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/user.detail.model.dart';
import '../../../../token/token.manager.dart';

class UserDetailService {
  Future<UserDetailModel?> getUserDetail() async {
    try {
      var url = Uri.parse('https://ihosapp.misa.vn/api/g1/mobile/qlcb/user/detail');
      String? token = await TokenManager.getToken();

      if (token == null) {
        print("❌ API 1 Lỗi: Token rỗng");
        return null;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
        "x-sessionid": TokenManager.xSessionId,
        "AppCode": "System",
        "AppVersion": "2.2",
      };

      print("🚀 Đang gọi API 1 (User Detail)...");
      final response = await http.get(url, headers: headers);

      print("✅ API 1 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // In ra dữ liệu gốc server trả về
        print("📦 API 1 Raw Body: ${utf8.decode(response.bodyBytes)}");

        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        // Logic xử lý Data Wrapper
        var data = jsonData;
        if (jsonData is Map && jsonData.containsKey('Data')) {
          data = jsonData['Data'];
          print("ℹ️ Đã bóc tách lớp 'Data'");
        }

        try {
          // Thử map sang Model
          return UserDetailModel.fromJson(data);
        } catch (e) {
          print("❌ LỖI MODEL: Không map được JSON sang UserDetailModel!");
          print("👉 Lỗi chi tiết: $e");
          print("👉 Hãy kiểm tra file user.detail.model.dart xem tên trường (Key) có khớp với Raw Body ở trên không.");
          return null;
        }
      } else {
        print("❌ API 1 Lỗi Server: ${response.body}");
      }
    } catch (e) {
      print("❌ API 1 Lỗi Mạng/Code: $e");
    }
    return null;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/contact.model.dart';
import '../../../../token/token.manager.dart';
import '../token/auth.service.dart'; // Import AuthService

class ContactService {
  final String _endpoint = '/api/g1/mobile/qlcb/directory/list';

  Future<List<ContactUser>> fetchContactUsers({String? query, String? departmentID}) async {
    final Uri uri = Uri.https('ihosapp.misa.vn', _endpoint);

    // 1. Lấy token hiện tại từ bộ nhớ
    String? initialToken = await TokenManager.getToken();
    if (initialToken == null) return [];

    // 2. Hàm tạo Header động (Đây là chỗ sửa lỗi undefined name)
    // Hàm này nhận vào 'tokenToUse' và trả về Header tương ứng
    Map<String, String> createHeaders(String tokenToUse) {
      return {
        'Content-Type': 'application/json',
        // Kiểm tra nếu token chưa có chữ Bearer thì thêm vào
        "Authorization": tokenToUse.startsWith("Bearer ") ? tokenToUse : "Bearer $tokenToUse",
        "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
        "x-sessionid": TokenManager.xSessionId,
        "AppCode": "System",
        "x-culture": "vi",
      };
    }

    // 3. Logic chọn ID lọc
    String filterID = departmentID ?? TokenManager.rootDepartmentId;

    final Map<String, dynamic> bodyRequest = {
      "OrganizationID": TokenManager.organizationId,
      "UserID": TokenManager.userId,
      "DepartmentID": filterID,
      "PageIndex": 1,
      "PageSize": 50,
      "Skip": 0,
      "Take": 50,
      "QuickSearch": query ?? ""
    };

    // 4. Hàm thực hiện request (Đóng gói để dễ gọi lại khi cần retry)
    Future<http.Response> performRequest(String currentToken) {
      return http.post(
          uri,
          // Gọi hàm createHeaders ở trên, truyền token vào
          headers: createHeaders(currentToken),
          body: json.encode(bodyRequest)
      );
    }

    try {
      print("🚀 API 3 đang lọc theo ID: $filterID");

      // Lần gọi đầu tiên dùng token ban đầu
      var response = await performRequest(initialToken);

      // 5. Xử lý Tự động Refresh nếu gặp lỗi 401
      if (response.statusCode == 401) {
        print("⚠️ Token hết hạn (401). Đang thử Refresh...");
        final authService = AuthService();
        bool refreshSuccess = await authService.refreshToken();

        if (refreshSuccess) {
          // Lấy token mới nhất vừa lưu
          String? newToken = await TokenManager.getToken();
          if (newToken != null) {
            print("🔄 Đang gọi lại API với Token mới...");
            // Gọi lại API lần 2 với Token mới
            response = await performRequest(newToken);
          }
        } else {
          print("❌ Refresh thất bại. Vui lòng đăng nhập lại.");
          return [];
        }
      }

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final decodedJson = json.decode(decodedBody);

        List<dynamic> jsonList = [];
        if (decodedJson is List) {
          jsonList = decodedJson;
        } else if (decodedJson is Map && decodedJson.containsKey('Data')) {
          jsonList = decodedJson['Data'];
        }

        print("✅ API 3 Tìm thấy: ${jsonList.length} nhân viên");

        return jsonList
            .map((json) => ContactUser.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Lỗi API 3: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi mạng API 3: $e');
      return [];
    }
  }
}

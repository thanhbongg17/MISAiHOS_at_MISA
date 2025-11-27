import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/derpartment.model.dart'; // Giữ nguyên tên file derpartment của bạn
import '../../../../token/token.manager.dart';
import '../token/auth.service.dart'; // Import AuthService

class DepartmentService {
  static const String baseUrl = "https://ihosapp.misa.vn/api/g1/mobile";

  Future<List<DepartmentModel>> getListDepartments() async {
    final url = Uri.parse('$baseUrl/qlcb/department/listDepartment/');

    // 1. Lấy token
    String? initialToken = await TokenManager.getToken();
    if (initialToken == null || initialToken.isEmpty) {
      print("[API 2] Lỗi: Token rỗng");
      return [];
    }

    // 2. Hàm tạo Header động (Sửa lỗi tokenToUse)
    Map<String, String> createHeaders(String tokenToUse) {
      return {
        'Content-Type': 'application/json',
        "Authorization": tokenToUse.startsWith("Bearer ") ? tokenToUse : "Bearer $tokenToUse",
        "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
        "x-sessionid": TokenManager.xSessionId,
        "AppCode": "System",
        "AppVersion": "2.2",
        "DeviceOS": "Android",
        "x-culture": "vi",
      };
    }
    // Xử lý từ khóa tìm kiếm (Tránh null)
    //String searchKeyword = query?.trim() ?? "";

    // 3. Body Request
    final bodyData = {
      "OrganizationID": TokenManager.organizationId,
      "UserID": TokenManager.userId,
      "Skip": 0,
      "Take": 20,
      "Active": true,
      "PageSize": 0
    };

    // 4. Hàm thực hiện request (để dễ retry)
    Future<http.Response> performRequest(String currentToken) {
      return http.post(
        url,
        headers: createHeaders(currentToken), // Truyền token vào hàm tạo header
        body: jsonEncode(bodyData),
      );
    }

    try {
      print("API 2: Đang lấy danh sách phòng ban...");

      // Gọi lần 1
      var response = await performRequest(initialToken);

      // 5. Tự động Refresh Token nếu lỗi 401
      if (response.statusCode == 401) {
        print("API 2: Token hết hạn (401). Đang thử Refresh...");
        final authService = AuthService();
        bool refreshSuccess = await authService.refreshToken();

        if (refreshSuccess) {
          String? newToken = await TokenManager.getToken();
          if (newToken != null) {
            print("API 2: Gọi lại với Token mới...");
            response = await performRequest(newToken);
          }
        }
      }

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> listData = [];

        if (decodedData is List) {
          listData = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('Data')) {
          listData = decodedData['Data'];
        }

        print("API 2: Tìm thấy ${listData.length} phòng ban.");
        return listData.map((json) => DepartmentModel.fromJson(json)).toList();
      } else {
        print("API 2 Lỗi Server: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("API 2 Lỗi Mạng: $e");
      return [];
    }
  }
}

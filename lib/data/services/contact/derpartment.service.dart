import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/derpartment.model.dart';
import '../../../../token/token.manager.dart'; // Import file TokenManager vừa tạo

class DepartmentService {
  static const String baseUrl = "https://ihosapp.misa.vn/api/g1/mobile";

  Future<List<DepartmentModel>> getListDepartments() async {
    final url = Uri.parse('$baseUrl/qlcb/department/listDepartment/');
    //1 token login
    String? token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      print("Lỗi: Chưa đăng nhập (Không tìm thấy token)");
      return [];
    }

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",

      // Header bắt buộc từ CURL
      "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
      "x-sessionid": TokenManager.xSessionId,

      "AppCode": "System",
      "AppVersion": "2.2",
      "DeviceOS": "Android",
      "x-culture": "vi",
    };

    // 3. BODY QUAN TRỌNG NHẤT (Thủ phạm gây lỗi [])
    // Server cần biết lấy của Tổ chức nào (OrganizationID) và User nào (UserID)
    final bodyData = {
      "OrganizationID": TokenManager.organizationId, // Lấy từ CURL
      "UserID": TokenManager.userId,        // Lấy từ CURL
      "Skip": 0,
      "Take": 20
    };

    try {
      print("--------------- BẮT ĐẦU GỌI API 2 ---------------");
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodyData),
      );
      print("Status Code: ${response.statusCode}");
      // 👇 IN RA DỮ LIỆU THÔ SERVER TRẢ VỀ (Quan trọng)
      print("Response Body RAW: ${response.body}");

      if (response.statusCode == 200) {
        // Decode UTF8
        var decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        // KIỂM TRA CẤU TRÚC DỮ LIỆU
        List<dynamic> listData = [];

        if (decodedData is List) {
          // Trường hợp 1: Trả về thẳng List [...]
          listData = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('Data')) {
          // Trường hợp 2: Trả về Object { "Data": [...], "Success": true }
          listData = decodedData['Data'];
        } else {
          print("⚠️ Cấu trúc lạ, không phải List cũng không phải Object chứa Data");
          return [];
        }

        print("Tìm thấy ${listData.length} phần tử.");

        // Map sang Model
        return listData.map((json) => DepartmentModel.fromJson(json)).toList();
      }else {
        print("Lỗi server: ${response.statusCode}");
        return [];
      }
    } catch (e, stackTrace) {
      // 👇 IN RA LỖI CHÍNH XÁC
      print("❌ LỖI PARSING DATA: $e");
      print(stackTrace);
      return [];
    }
  }
}
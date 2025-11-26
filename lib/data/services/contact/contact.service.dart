import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/contact/contact.model.dart';
import '../../../../token/token.manager.dart';

class ContactService {
  // Endpoint đúng (có /api)
  final String _endpoint = '/api/g1/mobile/qlcb/directory/list';

  Future<List<ContactUser>> fetchContactUsers({String? query}) async {
    // 1. Tạo URI (Không cần queryParams ở đây)
    final Uri uri = Uri.https('ihosapp.misa.vn', _endpoint);
    String? token = await TokenManager.getToken();

    // 2. Token bạn đã cung cấp
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      //'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6IjY4Y2YwYjIyLWFiZmQtNGYxYS05ZjcxLTY5ODBmODQ1MDZiNyIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MDM5Mjg0LCJleHAiOjE3NjQwNjgwODQsImlhdCI6MTc2NDAzOTI4NCwiaXNzIjoiTUlTQUpTQyJ9.F-zg2g-VHgb-jvRZilffvk-CbzHnJoK_ajBwU77FS0Re0O2KUixCE_E7NtIEEvSke0zZmO3p3CM_cfa0qrsmUEBYEfrO6AwG13jDHvfL8mnMlqgaM0DAPhV3BoZeT-k3iWpnwRY5ozOZu8kQscHlYf_y4yjy7iTS_mwZYy2yWB4',

    };

    // 3. KHAI BÁO bodyRequest (Đây là phần bạn bị thiếu)
    // Các ID này lấy từ hình Postman bạn gửi trước đó
    final Map<String, dynamic> bodyRequest = {
      "DepartmentID": "d01c40b6-6ff0-4290-b350-51534e86afd2",
      "OrganizationID": "c3494373-8e50-4595-bbbc-e3dd1c803972",
      "UserID": "cce607e5-a154-4cb9-a456-0fcc441cf20b",
      "Skip": 0,
      "Take": 50
    };

    // Xử lý tìm kiếm: Thêm vào body thay vì URL
    if (query != null && query.isNotEmpty) {
      bodyRequest['Keyword'] = query; // Hoặc 'FilterValue'
    }

    try {
      // Gọi POST với body đã được encode JSON
      final response = await http.post(
          uri,
          headers: headers,
          body: json.encode(bodyRequest) // Biến bodyRequest giờ đã hợp lệ
      );

      if (response.statusCode == 200) {
        // Giải mã UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonList = json.decode(decodedBody) as List;

        return jsonList
            .map((json) => ContactUser.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to load users. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      rethrow;
    }
  }
}
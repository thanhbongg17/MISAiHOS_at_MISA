import 'package:shared_preferences/shared_preferences.dart';

// class TokenManager {
//   // static const String _keyToken = "ACCESS_TOKEN";
//   static const String _keyToken = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6IjY4Y2YwYjIyLWFiZmQtNGYxYS05ZjcxLTY5ODBmODQ1MDZiNyIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MDM5Mjg0LCJleHAiOjE3NjQwNjgwODQsImlhdCI6MTc2NDAzOTI4NCwiaXNzIjoiTUlTQUpTQyJ9.F-zg2g-VHgb-jvRZilffvk-CbzHnJoK_ajBwU77FS0Re0O2KUixCE_E7NtIEEvSke0zZmO3p3CM_cfa0qrsmUEBYEfrO6AwG13jDHvfL8mnMlqgaM0DAPhV3BoZeT-k3iWpnwRY5ozOZu8kQscHlYf_y4yjy7iTS_mwZYy2yWB4";
//
//   // 1. Hàm lưu token (Gọi khi Đăng nhập thành công)
//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyToken, token);
//     print("Đã lưu token mới: $token");
//   }
//
//   // 2. Hàm lấy token (Gọi ở các Service API)
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_keyToken);
//   }
//
//   // 3. Hàm xóa token (Gọi khi Đăng xuất)
//   static Future<void> removeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyToken);
//   }
// }
class TokenManager {
  // 1 token(động)
  static const String _manualToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6IjY4Y2YwYjIyLWFiZmQtNGYxYS05ZjcxLTY5ODBmODQ1MDZiNyIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MDM5Mjg0LCJleHAiOjE3NjQwNjgwODQsImlhdCI6MTc2NDAzOTI4NCwiaXNzIjoiTUlTQUpTQyJ9.F-zg2g-VHgb-jvRZilffvk-CbzHnJoK_ajBwU77FS0Re0O2KUixCE_E7NtIEEvSke0zZmO3p3CM_cfa0qrsmUEBYEfrO6AwG13jDHvfL8mnMlqgaM0DAPhV3BoZeT-k3iWpnwRY5ozOZu8kQscHlYf_y4yjy7iTS_mwZYy2yWB4";

  // --- 2. SESSION & COOKIE(động)
  static const String sessionId = "x-ihos-sid=0f4fbfdd-114b-443f-b997-c989a98af719";// Lấy từ CURL: x-sessionid
  static const String xSessionId = "2f5fb2ebdc104a78bf5c47d88f622c947745bcffa8234df9b1e8af9537b17e80";// Hàm này giả lập việc lấy token (để sau này có làm Login thật thì không phải sửa Service)

  // --- 3. ID CỐ ĐỊNH (Ít khi phải thay) ---
  static const String organizationId = "c3494373-8e50-4595-bbbc-e3dd1c803972";
  static const String userId = "cce607e5-a154-4cb9-a456-0fcc441cf20b";
  static const String tenantId = "20020008.13";
  static Future<String?> getToken() async {
    return _manualToken;
  }
}
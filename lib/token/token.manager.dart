import 'package:shared_preferences/shared_preferences.dart';
// dùng refresh để quản lý, auto tự động
// class TokenManager {
//   // 1 token(động)
//   static const String _manualToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6ImMwNjA1MjM3LTMwMzItNDYxYS05ODU0LWZiN2U3ZmI0OTNlNiIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MTE5OTY3LCJleHAiOjE3NjQxNDg3NjcsImlhdCI6MTc2NDExOTk2NywiaXNzIjoiTUlTQUpTQyJ9.BUAZDPj5jT2W9YDGPCyIGKk417DJqtuishXnzjUG37N4-lxqtOA1wJkrFGkq1hmwRpDLWiwKuvs-kyJri6Eh_wXV3NIVluofIjQIMMilDiPyXmVD7-zEoqOU91VdDVw6qpp9_D5WdVAPK03FKn1801oDqaaBFtvOSPe44JDRh2M";
//
//   // --- 2. SESSION & COOKIE(động)
//   //static const String sessionId = "x-ihos-sid=0f4fbfdd-114b-443f-b997-c989a98af719";// Lấy từ CURL: x-sessionid
//   static const String sessionId = "0f4fbfdd-114b-443f-b997-c989a98af719";
//   static const String xSessionId = "2f5fb2ebdc104a78bf5c47d88f622c947745bcffa8234df9b1e8af9537b17e80";// Hàm này giả lập việc lấy token (để sau này có làm Login thật thì không phải sửa Service)
//
//   // --- 3. ID CỐ ĐỊNH (Ít khi phải thay) ---
//   static const String organizationId = "c3494373-8e50-4595-bbbc-e3dd1c803972";
//   static const String userId = "cce607e5-a154-4cb9-a456-0fcc441cf20b";
//   static const String tenantId = "20020008.13";
//   static const String rootDepartmentId = "d01c40b6-6ff0-4290-b350-51534e86afd2";
//   static Future<String?> getToken() async {
//     return _manualToken;
//   }
// }
class TokenManager {
  // Key lưu trong bộ nhớ máy
  static const String _kAccessToken = "ACCESS_TOKEN";

  // 1. ĐIỀN CỨNG CÁC THÔNG TIN BAN ĐẦU (Lấy từ CURL mới nhất của bạn)
  // Access Token (Cái Bearer...)
  static String _currentAccessToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6ImNlODZjYzMxLTczZjItNGEzMC04N2ZhLTFmNGU4ODIzNmViYiIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsImJjbyI6IjIwMDIwMDA4LjEzIiwidG5uIjoiQuG7h25oIHZp4buHbiDEkWEga2hvYSB04buJbmggTWlzYSAyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MTM5OTc4LCJleHAiOjE3NjQxNjg3NzgsImlhdCI6MTc2NDEzOTk3OCwiaXNzIjoiTUlTQUpTQyJ9.fhcR069hGEEnuHHhYo_tyAIWeaClrvH8s-ty2we8ju79DlEslmHi0OdeAZSMyLWuRoVNog3JFTi8FoDYS43yp9xoGKBf3ADxEEeoxh6Lnj8lQ2G6U9ttspQR-FUXSID4pbsCqGhL3bTVNkke6cNDhxQPLjusuzg3EyXIif0Vp8s";

  // Refresh Token (Cái chuỗi 4SXzXD... trong JSON Refresh Token)
  static const String refreshTokenValue = "4SXzXDIO3QL/504EDZIE5Iv3Zj2Jp04GvdANOPKwHo7bO5fHrH2UzgppT0l4sO88F9R+DxfRY1WH/q2I4u6xEFaJpdSFyh3DruWRGcX6ga/63ANsZv338IM/C/PTR3PUXkPctR0pryVM2Y8ySTYopviiwzOt9NHWm6dD3b5bQDo=";

  // Session & Cookie (Cố định trong phiên này)
  // Lấy từ CURL Refresh Token hoặc JSON login
  static const String sessionId = "2f5fb2ebdc104a78bf5c47d88f622c94afbb38134d494bb09924fe8119c7080f"; // Lấy từ JSON: SessionID
  static const String xSessionId = "2f5fb2ebdc104a78bf5c47d88f622c94dee715da78a04ad9b232bf11e3fb4eb8"; // Lấy từ CURL: x-sessionid

  // ID Cố định
  static const String organizationId = "c3494373-8e50-4595-bbbc-e3dd1c803972";
  static const String userId = "aeeb148c-7840-4f66-aee4-a579c6a404d9"; // Lấy từ JSON: UserID
  static const String tenantId = "20020008.13";
  static const String rootDepartmentId = "d01c40b6-6ff0-4290-b350-51534e86afd2";

  // --- HÀM QUẢN LÝ TOKEN ---

  // 1. Lấy Token (Ưu tiên lấy từ biến chạy, sau này nâng cấp lên SharedPreferences)
  static Future<String?> getToken() async {
    return _currentAccessToken;
  }

  // 2. Cập nhật Token mới (Gọi khi Refresh thành công)
  static Future<void> saveNewToken(String newToken) async {
    _currentAccessToken = newToken;
    // Nếu muốn lưu vĩnh viễn:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(_kAccessToken, newToken);
    print("✅ Đã cập nhật Token mới vào hệ thống!");
  }
}
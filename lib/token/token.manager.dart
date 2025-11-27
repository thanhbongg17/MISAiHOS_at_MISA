import 'package:shared_preferences/shared_preferences.dart';
class TokenManager {
  // Key lưu trong bộ nhớ máy
  static const String _kAccessToken = "ACCESS_TOKEN";

  // 1. ĐIỀN CỨNG CÁC THÔNG TIN BAN ĐẦU (Lấy từ CURL mới nhất của bạn)
  // Access Token (Cái Bearer...) CẬP NHẬP
  static String _currentAccessToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6Imlob3NwaXRhbC1wbGF0Zm9ybS1rZXktMDEiLCJ0eXAiOiJKV1QifQ.eyJ1bmEiOiJpaG9zcWMxM0B5b3BtYWlsLmNvbSIsInVpZCI6IjZlNzQ0ZThlLWQ5Y2MtNGMxYS1hZWU3LTAzZTllOGRkOWQ1NSIsInNpZCI6Ijc2ZGI1ZGQ1LWRmM2UtNDYxMy04ZGEwLTcwNjVmOTlhY2M3NCIsInRpZCI6ImU0OWU5ZDU1LWE3NmYtNDlhNi04YWM1LTNiMmFlNDNmYzQ4MyIsInRubiI6IkLhu4duaCB2aeG7h24gxJFhIGtob2EgdOG7iW5oIE1pc2EgMjAwMjAwMDguMTMiLCJiY28iOiIyMDAyMDAwOC4xMyIsInNjb3BlIjoibW9iaWxlX2dhdGV3YXk6YWNjZXNzIiwibmJmIjoxNzY0MjM0NTQxLCJleHAiOjE3NjQyNjMzNDEsImlhdCI6MTc2NDIzNDU0MSwiaXNzIjoiTUlTQUpTQyJ9.ShRfFzIH7hT5GtIGu7hhC3LCdmnfunf-YJ_zYPrpWJfXDFRICyDcSlsX-Ic2DBsdGzyC5GFNx3xYlt_O1YdPVHHg5qnVFBUWbrcAyG4bzdCJpKT2uQhY8BTu6b6B1w0ZXGjicLn9raDNyrMomP-olR8MG4ps4ujEZgNamZPMiLA";

  // Refresh Token CẬP NHẬP
  static String refreshTokenValue = "/b47zIzjhTcccERhBIuLRJvP0OTGn0Z7ve31pZVMdOyoj+DzfqYV1h4WY+0+Q4MKGcFpyFp1CCPKNXBxIA8ARERodqkpXA0jLrhDfBBII/6zFJE/A0ARqXdzfM9lvNBBll8c05f3VYK1GErEAYj8UAG/Lugb5IDP/C+Z5WxpQII=";
  // Session & Cookie (Cố định trong phiên này)
  // Lấy từ CURL Refresh Token hoặc JSON login
  //CẬP NHẬP
  static String sessionId = "253611a5-f472-4ea4-aa96-d20fb375e2d3";
  //CẬP NHẬP
  static String xSessionId = "2f5fb2ebdc104a78bf5c47d88f622c9415f9d96de1964476a50edf042ba84735"; // Lấy từ CURL: x-sessionid
  //CẬP NHẬP
  static const String userId = "482f8b5f-eaaa-4a1a-a852-2a38f71fad49"; // Lấy từ JSON: UserID
  static const String organizationId = "c3494373-8e50-4595-bbbc-e3dd1c803972";
  // ID Cố định

  static const String tenantId = "20020008.13";
  static const String rootDepartmentId = "d01c40b6-6ff0-4290-b350-51534e86afd2";

  // --- HÀM QUẢN LÝ TOKEN ---

  // 1. Lấy Token (Ưu tiên lấy từ biến chạy, sau này nâng cấp lên SharedPreferences)
  static Future<String?> getToken() async {
    return _currentAccessToken;
  }
  static String getManualTokenForImage() {
    return _currentAccessToken;
  }

  static void updateInfos({
    required String newAccessToken,
    required String newRefreshToken,
    required String newSessionId,
    required String newXSessionId,
  }) {
    // Cập nhật giá trị mới vào biến static
    _currentAccessToken = "Bearer " + newAccessToken.replaceAll("Bearer ", ""); // Đảm bảo format chuẩn
    refreshTokenValue = newRefreshToken;
    sessionId = newSessionId;
    xSessionId = newXSessionId;

    print("💾 [TokenManager] Đã lưu toàn bộ thông tin phiên làm việc mới!");
    print("👉 Token mới: ${_currentAccessToken.substring(0, 20)}...");
    print("👉 SessionID mới: $sessionId");
  }
}
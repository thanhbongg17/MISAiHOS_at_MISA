import '../../models/newsfeed/newsfeed.model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsFeedService {
  Future<NewsFeedResponse> getNewsFeed(
    String token, {
    String? sessionId,
    String? tenantId,
    DateTime? modifiedDate,
  }) async {
    // Xây dựng URL với modifiedDate để lấy dữ liệu mới nhất
    String modifiedDateStr = '';
    if (modifiedDate != null) {
      // Format: yyyy-MM-ddTHH:mm:ss.fff+07:00
      modifiedDateStr = modifiedDate.toIso8601String();
    }

    final url = Uri.parse(
      "https://ihosapp.misa.vn/api/g1/mobile/mxh/Post/GetNewsFeed"
      "?modifiedDate=$modifiedDateStr"
      "&postType=0"
      "&loadPinPost=true"
      "&pageSize=20", // Tăng pageSize để lấy nhiều posts hơn
    );

    // Sử dụng sessionId và tenantId từ LoginController, fallback về giá trị mặc định nếu không có
    final finalSessionId = sessionId ?? "7f97a937-f3c4-4814-9416-9cd62b6d7437";
    final budgetCode = tenantId ?? ""; // Có thể cần điều chỉnh logic này

    print("=== NEWSFEED API URL: $url");
    print("=== NEWSFEED API SessionId: $finalSessionId");
    print("=== NEWSFEED API ModifiedDate: $modifiedDateStr");

    final response = await http.get(
      url,
      headers: {
        "Authorization": token,
        "x-sessionid": finalSessionId,
        "Cookie": "x-ihos-tid=$budgetCode; x-ihos-sid=$finalSessionId",
        "AppVersion": "2.2",
        "Content-Type": "application/json",
        "DeviceOS": "Android",
        "DeviceType": "Smartphone",
        "DeviceName": "SM-M556B",
        "AppCode": "System",
        "DeviceId": "Android_7010ce7f9eb7116a",
        "OSVersion": "35",
        "x-culture": "vi",
      },
    );
    print("=== USED TOKEN: Bearer $token");
    print("=== USED SESSION ID: $sessionId");
    print("=== USED TENANT ID (budgetCode): $tenantId");
    print("=== API RAW BODY: ${response.body}");

    print("=== NEWSFEED API STATUS: ${response.statusCode}");
    if (response.statusCode != 200) {
      print("=== NEWSFEED API ERROR BODY: ${response.body}");
      throw Exception("API lỗi: ${response.statusCode}");
    }

    final jsonData = json.decode(response.body);
    print(
      "=== NEWSFEED API SUCCESS - Posts count: ${(jsonData['Data'] as List?)?.length ?? 0}",
    );

    return NewsFeedResponse.fromJson(jsonData);
  }
}

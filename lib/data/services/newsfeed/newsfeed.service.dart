import '../../models/newsfeed/newsfeed.model.dart';
import 'dart:convert';
import 'dart:io'; // Import để bắt lỗi mạng (SocketException)
import 'package:http/http.dart' as http;

class NewsFeedService {
  // Base URL gốc
  static const String _baseUrl = "https://ihosapp.misa.vn/api/g1/mobile/mxh/Post/GetNewsFeed";

  Future<NewsFeedResponse> getNewsFeed(
      String token, {
        String? sessionId,
        String? tenantId,
        DateTime? modifiedDate,
        int pageSize = 20,
      }) async {
    try {
      // 1. [QUAN TRỌNG] Xử lý Token: Tự động thêm Bearer nếu thiếu
      final String authToken = token.startsWith("Bearer ") ? token : "Bearer $token";

      // 2. Xử lý tham số ngày tháng
      String modifiedDateStr = '';
      if (modifiedDate != null) {
        modifiedDateStr = modifiedDate.toIso8601String();
      }

      // 3. Xây dựng URL an toàn bằng Uri.parse và replace queryParameters
      // Cách này an toàn hơn cộng chuỗi thủ công
      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'modifiedDate': modifiedDateStr,
        'postType': '0',
        'loadPinPost': 'true',
        'pageSize': pageSize.toString(),
      });

      // Lấy Session & Tenant (Fallback data giả lập nếu null để test)
      final finalSessionId = sessionId ?? "7f97a937-f3c4-4814-9416-9cd62b6d7437";
      final budgetCode = tenantId ?? "";

      print("=== [NewsFeedService] Requesting: $url");

      // 4. Gọi API
      final response = await http.get(
        url,
        headers: {
          "Authorization": authToken, // Sử dụng token đã xử lý Bearer
          "x-sessionid": finalSessionId,
          "Cookie": "x-ihos-tid=$budgetCode; x-ihos-sid=$finalSessionId",
          // Các header giả lập thiết bị
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

      print("=== [NewsFeedService] Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("=== [NewsFeedService] Success. Posts count: ${(jsonData['Data'] as List?)?.length ?? 0}");
        return NewsFeedResponse.fromJson(jsonData);
      } else {
        print("=== [NewsFeedService] Error Body: ${response.body}");
        throw Exception("API Error: ${response.statusCode}");
      }
    } on SocketException {
      // Bắt lỗi mất mạng
      print("=== [NewsFeedService] No Internet Connection");
      throw Exception("Không có kết nối mạng");
    } catch (e) {
      print("=== [NewsFeedService] Exception: $e");
      rethrow;
    }
  }
}
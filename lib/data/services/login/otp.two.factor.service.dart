// lib/data/services/otp.two.factor.service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/login/login.model.dart';

class TwoFactorAuthService {
  final String baseUrl = "https://ihosapp.misa.vn/api/g1/auth/accounts";

  Map<String, String> get baseHeaders => {
    "x-sessionid": "",
    "AppVersion": "2.2",
    "Content-Type": "application/json",
    "DeviceOS": "Android",
    "DeviceType": "Smartphone",
    "DeviceName": "SM-M556B",
    "AppCode": "System",
    "DeviceId": "Android_7010ce7f9eb7116a",
    "OSVersion": "35",
    "x-culture": "vi",
    "Trace-Id": "c95dbe2a-051a-4beb-8fae-fccef001821b",
  };

  Future<LoginResponse> verifyCodeTwoFactor({
    required String code,
    required String userName,
    required String deviceId,
    bool rememberDevice = false,
  }) async {
    final url = Uri.parse('$baseUrl/VerifyCodeTwoFactor');

    final headers = Map<String, String>.from(baseHeaders);
    headers['DeviceId'] = deviceId;

    final body = jsonEncode({
      "DeviceId": deviceId,
      "Code": code,
      "UserName": userName,
      "RememberDevice": rememberDevice,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Decode response body và loại bỏ BOM (Byte Order Mark) nếu có
      String rawBody;
      try {
        rawBody = utf8.decode(response.bodyBytes, allowMalformed: false);
        // Loại bỏ BOM và các ký tự đặc biệt ở đầu
        rawBody = rawBody.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      } catch (e) {
        throw Exception('Không thể decode response body: ${e.toString()}');
      }

      if (kDebugMode) {
        debugPrint('[TwoFactorAuthService] status=${response.statusCode}');
        debugPrint('[TwoFactorAuthService] body length=${rawBody.length}');
        debugPrint(
          '[TwoFactorAuthService] body preview=${rawBody.length > 500 ? rawBody.substring(0, 500) + "..." : rawBody}',
        );
      }

      // Kiểm tra response body có rỗng không
      if (rawBody.isEmpty) {
        throw Exception('Response body rỗng. Mã lỗi: ${response.statusCode}');
      }

      // Parse JSON - xử lý cẩn thận để tránh FormatException
      Map<String, dynamic> jsonMap;
      try {
        // Kiểm tra xem có phải JSON hợp lệ không (bắt đầu bằng { hoặc [)
        final trimmedBody = rawBody.trim();
        if (!trimmedBody.startsWith('{') && !trimmedBody.startsWith('[')) {
          throw FormatException(
            'Response không phải JSON hợp lệ. '
            'Bắt đầu bằng: ${trimmedBody.length > 50 ? trimmedBody.substring(0, 50) : trimmedBody}',
          );
        }

        jsonMap = jsonDecode(trimmedBody) as Map<String, dynamic>;
      } on FormatException catch (formatError) {
        // Lỗi format JSON
        if (kDebugMode) {
          debugPrint(
            '[TwoFactorAuthService] FormatException: ${formatError.message}',
          );
          debugPrint('[TwoFactorAuthService] Source: ${formatError.source}');
          debugPrint('[TwoFactorAuthService] Offset: ${formatError.offset}');
        }
        throw Exception(
          'Lỗi định dạng JSON từ server. '
          'Status: ${response.statusCode}. '
          'Vui lòng thử lại sau.',
        );
      } catch (e) {
        // Các lỗi khác khi parse JSON
        throw Exception(
          'Không thể parse response từ server. '
          'Status: ${response.statusCode}. '
          'Lỗi: ${e.toString()}',
        );
      }

      // Parse response thành LoginResponse
      final loginResponse = LoginResponse.fromJson(jsonMap);

      // Kiểm tra status code HTTP
      if (response.statusCode != 200) {
        final message = loginResponse.message.isNotEmpty
            ? loginResponse.message
            : 'Không xác thực được mã. Mã lỗi ${response.statusCode}';
        throw Exception(message);
      }

      return loginResponse;
    } on Exception {
      // Re-throw Exception đã được tạo
      rethrow;
    } catch (e) {
      // Wrap các lỗi khác vào Exception
      throw Exception("Lỗi xác thực 2 yếu tố: ${e.toString()}");
    }
  }
}

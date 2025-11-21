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
    final url = Uri.parse('$baseUrl/login-two-factor');

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
      final rawBody = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        debugPrint('[TwoFactorAuthService] status=${response.statusCode}');
        debugPrint('[TwoFactorAuthService] body=$rawBody');
      }

      final jsonMap = jsonDecode(rawBody) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final message =
            jsonMap['Message'] as String? ??
            'Không xác thực được mã. Mã lỗi ${response.statusCode}';
        throw Exception(message);
      }

      return LoginResponse.fromJson(jsonMap);
    } catch (e) {
      throw Exception("Lỗi xác thực 2 yếu tố: ${e.toString()}");
    }
  }
}

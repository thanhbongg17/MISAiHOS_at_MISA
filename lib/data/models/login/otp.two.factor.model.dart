import 'package:flutter/material.dart';
class UserContext {
  final String userId;
  final String userName;
  final String sessionId;
  final String fullName;
  final String avatar;
  // ... thêm các trường khác nếu cần

  UserContext.fromJson(Map<String, dynamic> json)
      : userId = json['UserId'] ?? '',
        userName = json['UserName'] ?? '',
        sessionId = json['SessionId'] ?? '',
        fullName = json['FullName'] ?? '',
        avatar = json['Avatar'] ?? '';
}

class LoginData {
  final String token;
  final String refreshToken;
  final UserContext context;

  LoginData.fromJson(Map<String, dynamic> json)
      : token = json['Token'] ?? '',
        refreshToken = json['RefreshToken'] ?? '',
        context = UserContext.fromJson(json['Context'] ?? {});
}

class LoginResponse {
  final int code;
  final String message;
  final bool status;
  final LoginData? data;

  LoginResponse.fromJson(Map<String, dynamic> json)
      : code = json['Code'] ?? 0,
        message = json['Message'] ?? 'Lỗi không xác định',
        status = json['Status'] ?? false,
        data = json['Data'] != null ? LoginData.fromJson(json['Data']) : null;
}

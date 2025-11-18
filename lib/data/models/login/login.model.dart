import 'dart:convert';

// --- Base Response Model ---
class LoginResponse {
  final int code;
  final String message;
  final LoginData? data;
  final bool status;

  LoginResponse({
    required this.code,
    required this.message,
    this.data,
    required this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['Code'] as int,
      message: json['Message'] as String,
      data: json['Data'] != null ? LoginData.fromJson(json['Data'] as Map<String, dynamic>) : null,
      status: json['Status'] as bool,
    );
  }
}

// --- Data Payload Model ---
class LoginData {
  final String token;
  final String refreshToken;
  final int tokenTimeout;
  final UserContext context;

  LoginData({
    required this.token,
    required this.refreshToken,
    required this.tokenTimeout,
    required this.context,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['Token'] as String,
      refreshToken: json['RefreshToken'] as String,
      tokenTimeout: json['TokenTimeout'] as int,
      context: UserContext.fromJson(json['Context'] as Map<String, dynamic>),
    );
  }
}

// --- User Context Model (Thông tin người dùng) ---
class UserContext {
  final String userId;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String jobPositionName;
  final String departmentName;
  // Bạn có thể thêm nhiều trường khác nếu cần (như RoleApps)

  UserContext({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.jobPositionName,
    required this.departmentName,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      userId: json['UserId'] as String,
      fullName: json['FullName'] as String,
      email: json['Email'] as String,
      avatarUrl: json['Avatar'] as String,
      jobPositionName: json['JobPositionName'] as String,
      departmentName: json['DepartmentName'] as String,
    );
  }
}
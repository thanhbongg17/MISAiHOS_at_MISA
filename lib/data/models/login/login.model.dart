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
      code: json['Code'] is int ? json['Code'] as int : int.tryParse('${json['Code']}') ?? 0,
      message: json['Message'] as String? ?? '',
      data: json['Data'] != null
          ? LoginData.fromJson(json['Data'] as Map<String, dynamic>)
          : null,
      status: json['Status'] as bool? ?? false,
    );
  }
}

// --- Data Payload Model ---
class LoginData {
  final String token;
  final String refreshToken;
  final int tokenTimeout;
  final UserContext? context;

  LoginData({
    required this.token,
    required this.refreshToken,
    required this.tokenTimeout,
    required this.context,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['Token'] as String? ?? '',
      refreshToken: json['RefreshToken'] as String? ?? '',
      tokenTimeout: json['TokenTimeout'] is int
          ? json['TokenTimeout'] as int
          : int.tryParse('${json['TokenTimeout']}') ?? 0,
      context: json['Context'] != null
          ? UserContext.fromJson(json['Context'] as Map<String, dynamic>)
          : null,
    );
  }
}

// --- User Context Model (Thông tin người dùng) ---
class UserContext {
  final String userId;
  final String userName;
  final String tenantId;
  final String tenantName;
  final String sessionId;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String avatarId;
  final String jobPositionName;
  final String departmentName;
  final List<dynamic> roleApps;
  final bool useQLCB;
  final int gender;

  UserContext({
    required this.userId,
    required this.userName,
    required this.tenantId,
    required this.tenantName,
    required this.sessionId,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.avatarId,
    required this.jobPositionName,
    required this.departmentName,
    required this.roleApps,
    required this.useQLCB,
    required this.gender,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      userId: json['UserId'] as String? ?? '',
      userName: json['UserName'] as String? ?? '',
      tenantId: json['TenantId'] as String? ?? '',
      tenantName: json['TenantName'] as String? ?? '',
      sessionId: json['SessionId'] as String? ?? '',
      fullName: json['FullName'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      avatarUrl: json['Avatar'] as String? ?? '',
      avatarId: json['AvatarId'] as String? ?? '',
      jobPositionName: json['JobPositionName'] as String? ?? '',
      departmentName: json['DepartmentName'] as String? ?? '',
      roleApps: (json['RoleApps'] as List<dynamic>? ?? <dynamic>[]),
      useQLCB: json['UseQLCB'] as bool? ?? false,
      gender: json['Gender'] is int ? json['Gender'] as int : int.tryParse('${json['Gender']}') ?? 0,
    );
  }
}

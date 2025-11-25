class UserDetailModel {
  final String userId;
  final String fullName;
  final String email;
  final String organizationName; // Hiển thị dòng to: Bệnh viện đa khoa...
  final String budgetCode;       // Hiển thị dòng nhỏ: 20020008.13
  final String organizationId;// ID dùng để gọi API khác sau này

  UserDetailModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.organizationName,
    required this.budgetCode,
    required this.organizationId,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      userId: json['UserId'] ?? '',
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      // Map đúng 2 trường quan trọng để hiển thị Header
      organizationName: json['OrganizationName'] ?? '',
      budgetCode: json['BudgetCode'] ?? '',
      organizationId: json['OrganizationID'] ?? '',
    );
  }
}
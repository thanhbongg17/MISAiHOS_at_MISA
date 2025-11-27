// File: lib/data/models/directory_user.model.dart

class ContactUser {
  final String employeeId;
  final String fullName;
  final String departmentName; // Khoa Ngoại tổng hợp, Khoa Tim mạch
  //final String positionName;
  final String? mobilePhone;
  final String? email;
  final String? avatarUrl;
  final String? jobTitleName;

  ContactUser({
    required this.employeeId,
    required this.fullName,
    required this.departmentName,
    //required this.positionName,
    this.email,
    this.mobilePhone,
    this.avatarUrl,
    this.jobTitleName,
  });

  // Phương thức chuyển đổi từ JSON (từ API) sang Model
  factory ContactUser.fromJson(Map<String, dynamic> json) {
    // final String position = json['JobPositionName'] as String? ?? json['PositionName'] as String? ??
    //     '';
    return ContactUser(
        employeeId: json['EmployeeID'] as String,
        fullName: json['FullName'] as String,
        departmentName: json['DepartmentName'] as String,
        jobTitleName: json['JobPositionName'] ?? json['JobTitleName'],
        mobilePhone: json['MobilePhone'] as String?,
        avatarUrl: null, // API hiện tại không có, có thể thêm sau
    );
  }
}
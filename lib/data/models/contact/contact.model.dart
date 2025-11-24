// File: lib/data/models/directory_user.model.dart

class ContactUser {
  final String employeeId;
  final String fullName;
  final String departmentName; // Khoa Ngoại tổng hợp, Khoa Tim mạch
  final String positionName;
  final String? mobilePhone;
  final String? avatarUrl;

  ContactUser({
    required this.employeeId,
    required this.fullName,
    required this.departmentName,
    required this.positionName,
    this.mobilePhone,
    this.avatarUrl,
  });

  // Phương thức chuyển đổi từ JSON (từ API) sang Model
  factory ContactUser.fromJson(Map<String, dynamic> json) {
    // Logic kết hợp chức danh/vị trí công việc:
    // Ưu tiên JobPositionName, nếu không có thì lấy PositionName
    // mac dinh la rong
    final String position = json['JobPositionName'] as String? ?? json['PositionName'] as String? ??
        '';
    return ContactUser(
        employeeId: json['EmployeeID'] as String,
        fullName: json['FullName'] as String,
        departmentName: json['DepartmentName'] as String,
        positionName: position,
        mobilePhone: json['MobilePhone'] as String?,
        avatarUrl: null, // API hiện tại không có, có thể thêm sau
    );
  }
}
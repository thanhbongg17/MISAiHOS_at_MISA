class DepartmentModel {
  final String departmentID;
  final String departmentName;
  final String departmentCode;
  final String? parentID; // Có thể null nếu là Bệnh viện (Root)
  final bool isParent;    // Dùng để hiện mũi tên >
  final String? misaCodeID;

  DepartmentModel({
    required this.departmentID,
    required this.departmentName,
    required this.departmentCode,
    this.parentID,
    this.isParent = false, // Mặc định là false nếu null
    this.misaCodeID,
  });

  // Factory để parse JSON
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      departmentID: json['DepartmentID'] ?? '',
      departmentName: json['DepartmentName'] ?? '',
      departmentCode: json['DepartmentCode'] ?? '',
      parentID: json['ParentID'], // Giữ nguyên null nếu json là null
      isParent: json['IsParent'] ?? false,
      misaCodeID: json['MISACodeID'],
    );
  }
}
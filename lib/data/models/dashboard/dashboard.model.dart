// dashboard_models.dart

class SummaryItem {
  final String title;
  final String iconPath; // Hoặc IconData
  final String colorHex;

  SummaryItem({
    required this.title,
    required this.iconPath,
    required this.colorHex,
  });
}

class BudgetReport {
  final String title;
  final String dateContext; // Ví dụ: "Đến ngày: 19/11/2025"
  final String unit; // Ví dụ: "Triệu đồng"
  final double dataValue; // Giá trị thực tế của báo cáo (giả lập)

  BudgetReport({
    required this.title,
    required this.dateContext,
    required this.unit,
    required this.dataValue,
  });
}
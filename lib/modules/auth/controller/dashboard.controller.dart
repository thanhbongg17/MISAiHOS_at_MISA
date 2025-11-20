// dashboard_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/dashboard/dashboard.model.dart'; // Thay đổi đường dẫn cho phù hợp

class DashboardController extends GetxController {

  // Trạng thái Loading chung cho toàn bộ màn hình
  var isLoading = true.obs;

  // Dữ liệu menu chức năng (Tài chính/NS, Tài sản, Nhân sự)
  final RxList<SummaryItem> summaryItems = <SummaryItem>[].obs;

  // Dữ liệu cho báo cáo ngân sách 1
  var budgetExecutionReport = Rx<BudgetReport?>(null);

  // Dữ liệu cho báo cáo ngân sách 2
  var budgetUsageReport = Rx<BudgetReport?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchSummaryItems();
    fetchBudgetReports();
  }

  void fetchSummaryItems() {
    // Dữ liệu giả lập cho menu trên cùng
    summaryItems.value = [
      SummaryItem(title: "Tài chính/NS", iconPath: "assets/icon_finance.png", colorHex: "#4CAF50"),
      SummaryItem(title: "Tài sản", iconPath: "assets/icon_asset.png", colorHex: "#9E9E9E"),
      SummaryItem(title: "Nhân sự", iconPath: "assets/icon_hr.png", colorHex: "#795548"),
    ];
  }

  // Hàm sẵn sàng cho việc call API
  void fetchBudgetReports() async {
    isLoading.value = true;

    // Giả lập thời gian tải API
    await Future.delayed(const Duration(seconds: 2));

    // Dữ liệu giả lập cho báo cáo 1
    budgetExecutionReport.value = BudgetReport(
      title: "TÌNH HÌNH THỰC HIỆN KẾ HOẠCH NGÂN SÁCH THÀNH",
      dateContext: "Đến ngày: 19/11/2025",
      unit: "Triệu đồng",
      dataValue: 45.7,
    );

    // Dữ liệu giả lập cho báo cáo 2
    budgetUsageReport.value = BudgetReport(
      title: "TÌNH HÌNH SỬ DỤNG NGÂN SÁCH",
      dateContext: "Kỳ: Năm nay",
      unit: "Triệu đồng",
      dataValue: 90.5,
    );
    budgetUsageReport.value = BudgetReport(
      title: "TÌNH HÌNH SỬ DỤNG NGÂN SÁCH",
      dateContext: "Kỳ: Năm nay",
      unit: "Triệu đồng",
      dataValue: 90.5,
    );budgetUsageReport.value = BudgetReport(
      title: "TÌNH HÌNH SỬ DỤNG NGÂN SÁCH",
      dateContext: "Kỳ: Năm nay",
      unit: "Triệu đồng",
      dataValue: 90.5,
    );budgetUsageReport.value = BudgetReport(
      title: "TÌNH HÌNH SỬ DỤNG NGÂN SÁCH",
      dateContext: "Kỳ: Năm nay",
      unit: "Triệu đồng",
      dataValue: 90.5,
    );budgetUsageReport.value = BudgetReport(
      title: "TÌNH HÌNH SỬ DỤNG NGÂN SÁCH",
      dateContext: "Kỳ: Năm nay",
      unit: "Triệu đồng",
      dataValue: 90.5,
    );

    isLoading.value = false;
  }

  // Hàm xử lý sự kiện làm mới
  void refreshData() {
    fetchBudgetReports();
  }

  // Hàm xử lý sự kiện menu
  void showMoreOptions() {
    Get.bottomSheet(
      Container(
        height: 150,
        color: Colors.white,
        child: const Center(child: Text('Hiển thị thêm tùy chọn...')),
      ),
      backgroundColor: Colors.white,
    );
  }
}
// dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dashboard.controller.dart'; // Thay đổi đường dẫn
import '../../../../data/models/dashboard/dashboard.model.dart'; // Thay đổi đường dẫn


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller
    final controller = Get.put(DashboardController());

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan[50],
        automaticallyImplyLeading: false, // Bỏ nút back
        centerTitle: false,// bắt buộc sang trái
        titleSpacing: 40,
        title: const Text(
          'Tổng quan',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.cyan[50],
        //color: Colors.green,
        child: Container(
          width: double.infinity, // Mở rộng full chiều ngang
          height: double.infinity, // Mở rộng full chiều cao (để che màu xanh ở dưới chân)
          decoration: BoxDecoration(
            color: Colors.white, // Nền nội dung màu trắng
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30), // Bo góc trên
            ),
          ),
          // ⚠QUAN TRỌNG: Cắt nội dung khi cuộn để không bị chờm ra khỏi góc bo
          clipBehavior: Clip.hardEdge,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Thêm chút khoảng cách ở trên cùng cho đẹp

                // --- Phần Menu Chức năng (Tài chính, Tài sản, Nhân sự) ---
                _buildSummaryMenu(controller),

                const SizedBox(height: 20),

                // --- Phần 1: TÌNH HÌNH THỰC HIỆN KẾ HOẠCH NGÂN SÁCH ---
                Obx(() => _buildReportCard(
                  controller: controller,
                  report: controller.budgetExecutionReport.value,
                  isLoading: controller.isLoading.value,
                )),

                const SizedBox(height: 20),

                // --- Phần 2: TÌNH HÌNH SỬ DỤNG NGÂN SÁCH ---
                Obx(() => _buildReportCard(
                  controller: controller,
                  report: controller.budgetUsageReport.value,
                  isLoading: controller.isLoading.value,
                )),

                Obx(() => _buildReportCard(
                  controller: controller,
                  report: controller.budgetUsageReport.value,
                  isLoading: controller.isLoading.value,
                )),

                Obx(() => _buildReportCard(
                  controller: controller,
                  report: controller.budgetUsageReport.value,
                  isLoading: controller.isLoading.value,
                )),

                const SizedBox(height: 20), // Khoảng đệm dưới cùng
              ],
            ),
          ),
        ),
      ),
      // Giả lập Bottom Navigation Bar (Nếu cần thiết)
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Widget Functions ---

  Widget _buildSummaryMenu(DashboardController controller) {
    // Sử dụng Obx để lắng nghe dữ liệu summaryItems
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.summaryItems.map((item) {
          // Lấy màu từ hex code (Giả lập)
          Color color = Color(int.parse(item.colorHex.substring(1, 7), radix: 16) + 0xFF000000);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    item.title == 'Tài chính/NS' ? Icons.account_balance_wallet :
                    item.title == 'Tài sản' ? Icons.home_work : Icons.people,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  // Text
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildReportCard({
    required DashboardController controller,
    required BudgetReport? report,
    required bool isLoading,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Báo cáo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report?.title ?? 'Đang tải...',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Row(
                children: [
                  // Nút Refresh
                  GestureDetector(
                    onTap: controller.refreshData,
                    child: Icon(Icons.refresh, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  // Nút Menu
                  GestureDetector(
                    onTap: controller.showMoreOptions,
                    child: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Context và ĐVT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report?.dateContext ?? '...',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                'ĐVT: ${report?.unit ?? ''}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nơi hiển thị Biểu đồ hoặc Dữ liệu chính
          Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(
              // Giả lập hiển thị dữ liệu đã tải
              '${report!.dataValue}% đã thực hiện',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
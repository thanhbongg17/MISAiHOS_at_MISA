// File: department_selection.view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/contact.controller.dart';
// Import Model để dùng cho màn hình chọn phòng ban
import '../../../../data/models/contact/derpartment.model.dart';


class DepartmentSelectionView extends StatelessWidget {
  final DepartmentModel currentNode; // Node hiện tại đang xem
  final ContactController controller = Get.find<ContactController>();

  DepartmentSelectionView({super.key, required this.currentNode});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách con của node hiện tại
    List<DepartmentModel> children = controller.getChildren(currentNode.departmentID);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cơ cấu tổ chức", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 1. Ô Tìm kiếm (Giống ảnh)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              // GẮN HÀM TÌM KIẾM
              onChanged: (value) => controller.searchDepartments(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Dùng Obx để chuyển đổi giữa List tìm kiếm và Cây thư mục
          Expanded(
            child: Obx(() {
              // A. TRƯỜNG HỢP ĐANG TÌM KIẾM
              if (controller.departmentSearchQuery.isNotEmpty) {
                if (controller.filteredDepartments.isEmpty) {
                  return const Center(child: Text("Không tìm thấy kết quả"));
                }
                return ListView.builder(
                  itemCount: controller.filteredDepartments.length,
                  itemBuilder: (context, index) {
                    final dept = controller.filteredDepartments[index];
                    return ListTile(
                      title: Text(dept.departmentName, style: const TextStyle()),
                      onTap: () {
                        if (context.mounted) Navigator.of(context).pop(dept);
                      },
                    );
                  },
                );
              }

              // B. TRƯỜNG HỢP HIỂN THỊ CÂY BÌNH THƯỜNG
              List<DepartmentModel> children = controller.getChildren(currentNode.departmentID);

              return Column(
                children: [
                  // Header chọn chính node hiện tại
                  InkWell(
                    onTap: () => Navigator.of(context).pop(currentNode),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.blue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentNode.departmentName,
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //const Divider(height: 1, thickness: 1, color: Colors.black12),

                  // Danh sách con
                  Expanded(
                    child: children.isEmpty
                        ? const Center(child: Text("Không có đơn vị trực thuộc", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return Column(
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -3), // Thu gọn chiều cao
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),

                              title: Text(
                                child.departmentName,
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),

                              trailing: child.isParent
                                  ? const Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20)
                                  : null,

                              onTap: () async {
                                if (child.isParent) {
                                  // --- ĐỆ QUY ---
                                  var result = await Get.to(
                                          () => DepartmentSelectionView(currentNode: child),
                                      preventDuplicates: false // Quan trọng để mở được màn hình giống nhau
                                  );

                                  // Trả kết quả ngược lên trên
                                  if (result != null && context.mounted) {
                                    Navigator.of(context).pop(result);
                                  }
                                } else {
                                  // --- CHỌN LUÔN ---
                                  Navigator.of(context).pop(child);
                                }
                              },
                            ),
                            //const Divider(height: 1, indent: 16, color: Colors.black12),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}


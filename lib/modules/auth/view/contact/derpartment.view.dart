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
        title: const Text("Cơ cấu tổ chức", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

          // 2. Dòng Header chọn chính nó (Màu xanh, tích xanh)
          InkWell(
            onTap: () {
              // Chọn dòng này nghĩa là chọn "Tất cả" của node này -> Trả về kết quả
              Navigator.of(context).pop(currentNode);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              // Màu nền xanh nhạt giống header trong ảnh
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${currentNode.departmentName} ", // Tên + Mã
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const Divider(height: 1, thickness: 1, color: Colors.black12),// Dòng kẻ mờ ngăn cách
          // 3. Danh sách các phòng ban con
          Expanded(
            child: children.isEmpty
                ? const Center(child: Text("Không có đơn vị trực thuộc", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Column(
                  children: [
                    ListTile(
                      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                      dense:true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      title: Text(
                        child.departmentName,
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      // Nếu là Parent -> Hiện mũi tên >
                      trailing: child.isParent
                          ? const Icon(Icons.keyboard_arrow_right, color: Colors.grey)
                          : null,

                      onTap: () async {
                        print("Bấm vào: ${child.departmentName} (Có con: ${child.isParent})");
                        if (child.isParent) {
                          // --- SỬA ĐOẠN NÀY ---
                          var result = await Get.to(
                                  () => DepartmentSelectionView(currentNode: child),

                              // Cho phép mở đệ quy màn hình giống nhau
                              preventDuplicates: false
                          );

                          // Logic trả kết quả về (giữ nguyên)
                          if (result != null) {
                            if (context.mounted) {
                              Navigator.of(context).pop(result);
                            }
                          }
                        }else {
                          // --- LÁ (HẾT CON) ---
                          // Chọn luôn và quay về màn hình chính
                          Navigator.of(context).pop(child);
                        }
                      },
                    ),
                    // Đường kẻ mờ giữa các dòng (thụt vào 1 chút cho đẹp)
                    //const Divider(height: 1, indent: 14, color: Colors.black12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


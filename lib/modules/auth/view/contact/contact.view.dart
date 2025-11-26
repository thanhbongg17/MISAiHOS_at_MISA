// File: lib/modules/auth/view/contact/contact.view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/contact.controller.dart';
import 'user.list.title.dart';
// Import Model để dùng cho màn hình chọn phòng ban
import '../../../../data/models/contact/derpartment.model.dart';
import 'derpartment.view.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📝 Cấu hình AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,   //  Tắt nút back khi trong tab
        centerTitle: false,// bắt buộc sang trái
        titleSpacing: 50,
        title: const Text(
          'Danh bạ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        //backgroundColor: Colors.red,
        backgroundColor: Colors.cyan[50],
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:20.0),
            child:IconButton(
              icon: const Icon(Icons.star_border, color: Colors.red),
              onPressed: () {},
            ),
          ),

        ],
      ),

      // <body> Phần thân chính
      body: Container(
        color: Colors.cyan[50],
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, // Chuyển màu nền vào đây

              // ▶️ Cấu hình Border
              border: Border(
                  top : BorderSide(
                    color: Colors.cyan[50]!,
                    width: 1.0,
                  )
                // color: Colors.cyan[50]!, // Màu đường viền (ví dụ màu xám nhạt)
                // width: 0.0,                  // Độ dày đường viền
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(32),
              )
          ),
          child: SafeArea(
            child: Column(
              children: [
                //  Phần chọn Bệnh viện
                _buildHospitalSelector(),

                //  2 Ô tìm kiếm
                _buildSearchBar(),

                // 3 : Danh sách Người dùng (Sử dụng Obx để theo dõi trạng thái Controller)
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.isTrue) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.errorMessage.isNotEmpty) {
                      return _buildErrorState();
                    }

                    if (controller.users.isEmpty) {
                      return const Center(child: Text('Không tìm thấy người dùng nào.'));
                    }

                    return ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: controller.users.length,
                      itemBuilder: (context, index) {
                        final user = controller.users[index];
                        return UserListTile(user: user);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),


      ),


    );
  }

  // --- Các Widget phụ trợ ---

  // 1. Widget chọn bệnh viện
  Widget _buildHospitalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: InkWell(
          // 👇 SỰ KIỆN QUAN TRỌNG NHẤT: Bấm vào là mở màn hình cây thư mục
          onTap: () async {
            var root = controller.getRootNode(); // Lấy node gốc (Bệnh viện)
            if (root != null) {
              // Mở màn hình số 2
              var result = await Get.to(() => DepartmentSelectionView(currentNode: root));

              // Nhận kết quả trả về
              if (result != null) controller.onDepartmentSelected(result);
            } else {
              controller.fetchDepartments(); // Tải lại nếu chưa có
            }
          },
          child: Row(
            children: [
              const Icon(Icons.business_outlined, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.hospitalName.value,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 4),
                    // Mã đơn vị / BudgetCode (Đã thay text cứng bằng Obx)
                    Obx(() => Text(
                      controller.budgetCode.value, // <-- Dữ liệu từ API 1
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    )),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              const SizedBox(width: 24),
              // Nút Chọn
              ElevatedButton(
                onPressed: () {
                  print("Bấm nút chọn đơn vị");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.blue, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                    elevation: 0),
                child: const Text('Chọn', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),

    );
  }

  // 2. Widget ô tìm kiếm
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo Họ tên/SĐT/Email/Đơn vị',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }

  // 3. Widget hiển thị lỗi
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.fetchUsers(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }



}
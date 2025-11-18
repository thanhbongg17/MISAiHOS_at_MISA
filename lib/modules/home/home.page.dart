import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/login.controller.dart';
import '../auth/controller/home.controller.dart';
import '../../data/models/home/home.model.dart';
import '../../data/models/user/user.model.dart';


class MainFeedContent extends StatelessWidget {
  const MainFeedContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller và đưa vào bộ nhớ
    final HomeController controller = Get.put(HomeController());

    return Scaffold(

      body: Obx(
            () {
          return controller.pages[controller.currentPage.value];
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(controller),
    );
  }
  Widget _buildBottomNavBar(HomeController controller) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      // 🌟 BỌC BẰNG Obx ĐỂ THEO DÕI TRẠNG THÁI currentIndex
      child: Obx(
            () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal, // Màu theo ảnh
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,

          // 🌟 LẤY GIÁ TRỊ INDEX HIỆN TẠI TỪ CONTROLLER
          currentIndex: controller.currentPage.value,

          // 🌟 THÊM SỰ KIỆN TAP ĐỂ THAY ĐỔI TRANG
          onTap: controller.changePage,

          items: [
            _navBarItem(Icons.home, 'Bảng tin'),
            _navBarItem(Icons.group, 'Danh bạ'),
            _navBarItem(Icons.bar_chart, 'Báo cáo'),

            // Icon Chat với Badge (Sử dụng Obx)
            BottomNavigationBarItem(
              icon: Obx(() => Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  if (controller.notificationCount.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                      ),
                    ),
                ],
              )),
              label: 'Chat',
            ),
            _navBarItem(Icons.more_horiz, 'Thêm'),
          ],
        ),
      ),
    );
  }

  // Widget phụ cho BottomNavigationBar
  BottomNavigationBarItem _navBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

}
//HomePage
//MainFeedContent
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller và đưa vào bộ nhớ
    //final HomeController controller = Get.put(HomeController());
    final HomeController controller = Get.find<HomeController>();


    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            // --- Phần 1: App Bar (Bảng tin và Icons) ---
            _buildAppBar(controller),

            // --- Phần 2: Menu Chức năng (Lấy từ Controller) ---
            _buildFunctionMenu(controller), // Truyền controller vào đây

            // --- Phần 3: Danh sách người dùng Tùng, Linh, Tất cả (Static) ---
            _buildUserList(controller),

            // --- Phần 4: Banner Gửi lời chúc (Static) ---
            _buildBirthdayBanner(controller),

            // --- Divider (Tách biệt banner và feed) ---
            const Divider(height: 1, color: Colors.grey),

            // --- Phần 5: Feed Post (Sử dụng Obx cho danh sách) ---
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Nếu không có bài post nào
                if (controller.feedPosts.isEmpty) {
                  return const Center(child: Text("Không có bài đăng nào."));
                }
                // Hiển thị danh sách bài post
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.feedPosts.length,
                  itemBuilder: (context, index) {
                    final post = controller.feedPosts[index];
                    // Truyền index để Controller biết phải cập nhật Post nào khi click Like
                    return _buildFeedPost(controller, post, index);
                  },
                );

              }),
            ),
          ],
        ),
      ),
      // --- Phần 6: Bottom Navigation Bar ---
      //bottomNavigationBar: _buildBottomNavBar(controller),
    );
  }

  // --- Widget Functions ---

  Widget _buildAppBar(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text(
                'Bảng tin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
          Row(
            children: [
              // Icon Gửi
              const Icon(Icons.star, color: Colors.orange, size: 28),
              const SizedBox(width: 15),
              // Icon Chat
              const Icon(Icons.chat_bubble_outline, color: Colors.blueGrey, size: 28),
              const SizedBox(width: 15),
              // Icon Thông báo (Sử dụng Obx để theo dõi notificationCount)
              Obx(() => Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.blueGrey, size: 28),
                  if (controller.notificationCount.value > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionMenu(HomeController controller) {
    // Khởi tạo PageController ngoài Obx để tránh tạo lại
    final PageController pageController = PageController();

    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.fromLTRB(6, 15, 6, 6),
      decoration:  BoxDecoration(
        color: Color.fromARGB(255, 230, 245, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.lightBlue,
          width: 0.5,
        ),
      ),

      child: Column(
        children: [
          // --- PHẦN NÀY ĐÃ ĐƯỢC THAY THẾ BẰNG PAGEVIEW ---
          SizedBox(
            height: 75, // Đặt chiều cao cố định cho PageView
            // PageView sẽ chiếm toàn bộ chiều rộng có sẵn
            child: PageView.builder(
              controller: pageController,
              itemCount: controller.totalPages, // Số lượng trang
              onPageChanged: controller.updatePage, // Cập nhật trạng thái trang
              itemBuilder: (context, pageIndex) {
                // Logic tính toán các mục cho trang hiện tại
                final itemsPerPage = 4;
                final start = pageIndex * itemsPerPage;
                final end = (pageIndex * itemsPerPage) + itemsPerPage;

                // Lấy các mục (items) cho trang này
                final pageItems = controller.functionItems.sublist(
                    start,
                    end > controller.functionItems.length ? controller.functionItems.length : end
                );

                // Hiển thị các mục trong một Row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: pageItems.map((item) {
                    return _menuItem(item.title, item.icon, item.color);
                  }).toList(),
                );
              },
            ),
          ),
          // --- KẾT THÚC PAGEVIEW ---

          const SizedBox(height: 10),

          // Dấu chấm trang động (Logic này đã đúng)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.totalPages,
                  (index) => Obx(() => _pageDot(
                  controller.currentPage.value == index,
                  // Đây là hàm onTap được truyền vào:
                      () {
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
              )),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    ));
  }

  // --- HÀM SỬA ĐỔI ĐỂ SỬ DỤNG DỮ LIỆU ĐỘNG VÀ LOGIC LIKE THEO INDEX ---
  Widget _buildFeedPost(HomeController controller, FeedPost post, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Post
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                // Giả lập avatar
                backgroundColor: Colors.blueGrey,
                child: Text('NV', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(post.timeAgo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 10),
          // Nội dung Post
          Text(post.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),

          // Tệp đính kèm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attachment, size: 18, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                  'Tệp đính kèm (1)',
                  style: TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              post.attachmentName, // Sử dụng dữ liệu từ Model
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 15),

          // Thao tác (Like, Comment, Chat)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Thích (Sử dụng dữ liệu post.isLiked và gọi controller.toggleLike(index))
              GestureDetector(
                onTap: () => controller.toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: post.isLiked ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Thích ${post.initialLikes > 0 ? post.initialLikes : ''}',
                      style: TextStyle(
                          color: post.isLiked ? Colors.blue : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
              ),

              _postActionItem('Bình luận', Icons.chat_bubble_outline),
              _postActionItem('Chat', Icons.message_outlined),
            ],
          ),
          const SizedBox(height: 10),
          const Text('4 người xem', style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  // ... (Giữ nguyên các hàm phụ còn lại)

  // Widget phụ cho _buildFunctionMenu
  // home_page.dart (Sửa _menuItem)

  Widget _menuItem(String title, IconData icon, Color color) {
    return Material( // 1. Bọc bằng Material
      color: Colors.transparent,
      child: InkWell( // 2. Sử dụng InkWell để có hiệu ứng chạm
        onTap: () {
          // LOGIC KHI NHẤN VÀO ICON
          Get.snackbar(
            'Nhấn thành công',
            'Bạn đã chọn chức năng: $title',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: color.withOpacity(0.8),
            colorText: Colors.white,
          );
        },
        // Đặt bo góc cho hiệu ứng ripple
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),

        child: Padding( // 3. Thêm Padding để nới rộng khu vực chạm
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget phụ cho _buildFunctionMenu
  // home_page.dart (Sửa _pageDot)
  // home_page.dart (Sửa _pageDot)

  Widget _pageDot(bool isActive, VoidCallback onTap) {
    return Material( // Bọc bằng Material để InkWell hoạt động
      color: Colors.transparent, // Nền trong suốt
      child: InkWell( // Sử dụng InkWell để có hiệu ứng ripple
        onTap: onTap,
        borderRadius: BorderRadius.circular(10), // Bo góc cho hiệu ứng ripple
        splashColor: Colors.grey.withOpacity(0.3), // Màu hiệu ứng khi chạm
        highlightColor: Colors.grey.withOpacity(0.1), // Màu khi giữ chạm
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }


  Widget _buildUserList(HomeController controller) {
    return Obx(() {
      // 1. ẨN KHỐI NẾU KHÔNG CÓ AI SINH NHẬT
      if (controller.todayPriorityBirthdays.isEmpty) {
        return const SizedBox.shrink();
      }

      // 2. HIỂN THỊ KHỐI VÀ LẶP QUA DANH SÁCH SINH NHẬT ƯU TIÊN
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Lặp qua danh sách sinh nhật ƯU TIÊN (tối đa 2 người)
            ...controller.todayPriorityBirthdays.map((user) {
              return _userAvatar(user.name, user.initials, user.color);
            }).toList(),

            // Mục "Tất cả" (Thêm logic onTap)
            GestureDetector(
              onTap: controller.navigateToAllUsers,
              child: _userAvatar('Tất cả', '...', Colors.blue),
            ),
          ],
        ),
      );
    });
  }

  // Widget phụ cho _buildUserList
  Widget _userAvatar(String name, String initial, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  // Giả định đang ở trong một Widget sử dụng Controller có chứa các biến RxList trên
// Ví dụ: final MyController controller = Get.find();

  Widget _buildBirthdayBanner(HomeController controller) {
    // Lấy Controller của  (ví dụ: MyController)
    // Nếu  đang ở trong Controller, sẽ truy cập trực tiếp các biến
    // Nếu  đang ở View (Widget), cần Get.find() hoặc truyền Controller vào.
    // Giả định: final MyController controller = Get.find();
    // KHÔNG CÓ CONTROLLER: Dùng dữ liệu giả lập để minh họa
    // Giả sử, chúng ta truy cập Controller để lấy dữ liệu.

    // 1. Bọc bằng Obx để theo dõi sự thay đổi của todayPriorityBirthdays
    return Obx(() {
      // 2. Lấy dữ liệu người sinh nhật đầu tiên
      final List<User> birthdays = controller.AlltodayPriorityBirthdays.value;

      // 3. Kiểm tra: Nếu danh sách rỗng, ẩn toàn bộ khối bằng SizedBox.shrink()
      if (birthdays.isEmpty) {
        return const SizedBox.shrink();
      }

      // Lấy người sinh nhật đầu tiên để hiển thị banner chính
      final User birthdayPerson = birthdays.first;

      // (Optional) Kiểm tra xem có nhiều người sinh nhật không
      final bool hasMultipleBirthdays = birthdays.length > 1;


      // 4. Nếu có người sinh nhật, hiển thị khối Banner
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Giả lập màu nền gradient lớn
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.lightGreen.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bên trái: Quà tặng và Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar và Tên (Sử dụng dữ liệu động)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        // Lấy màu từ model
                        backgroundColor: birthdayPerson.color,
                        // Lấy initials từ model
                        child: Text(
                            birthdayPerson.initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lấy tên từ model
                          Text(
                              birthdayPerson.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          // Thêm thông báo nếu có nhiều hơn 1 người sinh nhật
                          if (hasMultipleBirthdays)
                            Text(
                                '+ ${birthdays.length - 1} người khác cùng ngày',
                                style: const TextStyle(fontSize: 12, color: Colors.black)
                            )
                          else
                            const Text('Sinh nhật hôm nay!', style: TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Button Gửi lời chúc (đã có InkWell)
                  InkWell(
                    onTap: () {
                      // Logic: Mở danh sách sinh nhật chi tiết (sử dụng AlltodayPriorityBirthdays)
                      print('Mở danh sách sinh nhật để gửi lời chúc!');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: const Text(
                        'Gửi lời chúc',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bên phải: Ảnh quà tặng trang trí (Giả lập)
            const Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.cake, color: Colors.pink, size: 40),
            )
          ],
        ),
      );
    });
  }

  // Widget phụ cho _buildFeedPost
  Widget _postActionItem(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 5),
        Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }


}
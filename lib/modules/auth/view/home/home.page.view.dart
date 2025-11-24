import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:misa_ihos_thanh/modules/auth/controller/newsfeed.controller.dart';
import '../../controller/home.controller.dart';
import '../../../../data/models/user/user.model.dart';
import '../../../../data/models/newsfeed/newsfeed.model.dart';
import '../../controller/login.controller.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller và đưa vào bộ nhớ
    final HomeController controller = Get.put(HomeController());
    // Sử dụng Get.find nếu đã tồn tại, nếu không thì tạo mới
    final NewsFeedController newsfeedcontroller =
        Get.isRegistered<NewsFeedController>()
        ? Get.find<NewsFeedController>()
        : Get.put(NewsFeedController());

    // KHÔNG gọi API ở đây nữa - để onInit của NewsFeedController tự động load
    // Tránh gọi API nhiều lần đồng thời
    print(
      "[HomePageView] build called - feedPosts.length: ${newsfeedcontroller.feedPosts.length}",
    );

    // Debug status và đảm bảo load dữ liệu khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đợi một chút để đảm bảo controller đã được khởi tạo hoàn toàn
      Future.delayed(const Duration(milliseconds: 800), () {
        newsfeedcontroller.debugStatus();

        // QUAN TRỌNG: Đảm bảo dữ liệu được load
        // Sử dụng ensureDataLoaded() thay vì refreshFeed() để tránh conflict
        if (newsfeedcontroller.feedPosts.isEmpty &&
            !newsfeedcontroller.isLoading.value &&
            !newsfeedcontroller.isRefreshing.value) {
          print("[HomePageView] ⚠️ No posts found, ensuring data is loaded...");
          newsfeedcontroller.ensureDataLoaded();
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.cyan[50],
      //backgroundColor: Colors.red,
      body: SafeArea(
        bottom: false,// tránh ăn màu xuống bên đưới
        child: Container(
          //color: Colors.red,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan[50]!,      // Phần 1
                Colors.cyan[100]!,               // Phần 2 (Ở giữa)
                Colors.white,  // Phần 3
              ],
              // Định vị 3 điểm chốt để chia đều màu
              stops: const [0.1,0.2,0.38],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(controller),
              Expanded(
                child: Obx(() {
                  // Đảm bảo reactive với cả isLoading và feedPosts
                  // QUAN TRỌNG: Đọc tất cả observables để trigger reactive update
                  final isLoading = newsfeedcontroller.isLoading.value;
                  final isRefreshing = newsfeedcontroller.isRefreshing.value;
                  // QUAN TRỌNG: Đọc feedPosts trực tiếp để trigger reactive update
                  // GetX sẽ tự động track changes khi đọc .length hoặc truy cập list
                  final feedPostsList = newsfeedcontroller.feedPosts;
                  final postsLength = feedPostsList.length;
                  // Đọc isEmpty để trigger update khi list thay đổi
                  final isEmpty = feedPostsList.isEmpty;

                  print(
                    "[HomePageView] Obx rebuild - isLoading: $isLoading, isRefreshing: $isRefreshing, posts.length: $postsLength, isEmpty: $isEmpty",
                  );

                  // Header cuộn: menu + user list + birthday banner + divider
                  final header = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Phần 2: Menu Chức năng (Lấy từ Controller) ---
                      _buildFunctionMenu(controller, newsfeedcontroller),
                      // --- Phần 3: Danh sách người dùng Tùng, Linh, Tất cả (Static) ---
                      _buildUserList(controller),
                      // --- Phần 4: Banner Gửi lời chúc (Static) ---
                      _buildBirthdayBanner(controller),
                      const Divider(
                          height: 10,
                          thickness :10.0,
                          color: Color(0xFFEEEEEE)),

                    ],
                  );
                  // --- Phần 5: Feed Post (Sử dụng Obx cho danh sách) ---
                  // QUAN TRỌNG: Kiểm tra isLoading TRƯỚC, sau đó mới kiểm tra posts
                  if (isLoading && !isRefreshing) {
                    print(
                      "[HomePageView] Showing loading indicator - isLoading: $isLoading",
                    );
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: header),
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }

                  // Nếu không có bài post nào và đã load xong (KHÔNG đang loading và KHÔNG đang refreshing)
                  // QUAN TRỌNG: Kiểm tra cả isEmpty và postsLength để đảm bảo chính xác
                  if (isEmpty &&
                      postsLength == 0 &&
                      !isLoading &&
                      !isRefreshing) {
                    print(
                      "[HomePageView] Showing empty state - postsLength: $postsLength, isEmpty: $isEmpty, isLoading: $isLoading, isRefreshing: $isRefreshing",
                    );
                    return RefreshIndicator(
                      onRefresh: () => newsfeedcontroller.refreshFeed(),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: header),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Chưa có bài viết nào',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hãy thử kéo xuống để làm mới',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Hiển thị danh sách bài post với pull-to-refresh
                  // ✅ Có bài: header + feed cùng CUỘN, AppBar đứng im
                  print(
                    "[HomePageView] ✅ Showing posts list - postsLength: $postsLength",
                  );

                  // Đảm bảo postsLength > 0 trước khi render
                  // QUAN TRỌNG: Kiểm tra cả isEmpty và postsLength
                  if (isEmpty || postsLength == 0) {
                    print(
                      "[HomePageView] ⚠️ WARNING: postsLength is 0 or isEmpty is true but reached render section!",
                    );
                    // Fallback: hiển thị empty state
                    return RefreshIndicator(
                      onRefresh: () {
                        print("[HomePageView] Pull-to-refresh from empty state");
                        return newsfeedcontroller.refreshFeed();
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: header),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Chưa có bài viết nào',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hãy thử kéo xuống để làm mới',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () {
                      print("[HomePageView] Pull-to-refresh triggered");
                      return newsfeedcontroller.refreshFeed();
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: header),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              // Đảm bảo index hợp lệ
                              if (index >= postsLength) {
                                print(
                                  "[HomePageView] ERROR: index $index >= postsLength $postsLength",
                                );
                                return const SizedBox.shrink();
                              }
                              // Đọc trực tiếp từ list đã được reactive
                              final post = feedPostsList[index];
                              return _buildFeedPost(
                                controller,
                                newsfeedcontroller,
                                post,
                                index,
                              );
                            },
                            childCount:
                            postsLength, // Sử dụng postsLength thay vì posts.length
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        )

      ),
    );
  }

  // --- Widget Functions ---

  Widget _buildAppBar(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      //color: Colors.cyan[50],
      color:Colors.transparent,
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
              //const Icon(Icons.star, color: Colors.orange, size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 15),
              // Icon Chat
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.blueGrey,
                size: 28,
              ),
              const SizedBox(width: 15),
              // Icon Thông báo (Sử dụng Obx để theo dõi notificationCount)
              Obx(
                () => Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionMenu(
    HomeController controller,
    NewsFeedController newsfeedcontroller,
  ) {
    // Khởi tạo PageController ngoài Obx để tránh tạo lại
    final PageController pageController = PageController();

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.fromLTRB(6, 15, 6, 6),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 230, 245, 255),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.lightBlue, width: 0.5),
        ),

        child: Column(
          children: [
            // --- PHẦN NÀY ĐÃ ĐƯỢC THAY THẾ BẰNG PAGEVIEW ---
            SizedBox(
              height: 75, // Đặt chiều cao cố định cho PageView
              // PageView sẽ chiếm toàn bộ chiều rộng có sẵn
              child: PageView.builder(
                controller: pageController,
                itemCount: newsfeedcontroller.totalPages, // Số lượng trang
                onPageChanged:
                    newsfeedcontroller.updatePage, // Cập nhật trạng thái trang
                itemBuilder: (context, pageIndex) {
                  // Logic tính toán các mục cho trang hiện tại
                  final itemsPerPage = 4;
                  final start = pageIndex * itemsPerPage;
                  final end = (pageIndex * itemsPerPage) + itemsPerPage;

                  // Lấy các mục (items) cho trang này
                  final pageItems = controller.functionItems.sublist(
                    start,
                    end > controller.functionItems.length
                        ? controller.functionItems.length
                        : end,
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
                newsfeedcontroller.totalPages,
                (index) => Obx(
                  () => _pageDot(
                    controller.currentPage.value == index,
                    // Đây là hàm onTap được truyền vào:
                    () {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // --- HÀM SỬA ĐỔI ĐỂ SỬ DỤNG DỮ LIỆU ĐỘNG VÀ LOGIC LIKE THEO INDEX ---
  Widget _buildFeedPost(
    HomeController controller,
    NewsFeedController newsfeedcontroller,
    FeedPost post,
    int index,
  ) {
    // --- LẤY ẢNH AN TOÀN ---
    final imageFileName =
    (post.listImageDetail != null && post.listImageDetail!.isNotEmpty)
        ? post.listImageDetail!.first.fileName
        : (post.images.isNotEmpty
        ? post.images.first.replaceAll(".jpg", "")
        .replaceAll(".png", "")
        .replaceAll(".jpeg", "")
        : null);
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
                  Text(
                    post.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    post.publishDate.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 10),
          // Nội dung Post
          Text(
            (post.contentPlainText?.trim().isNotEmpty == true)
                ? post.contentPlainText ?? ""
                : (post.summary ?? ""),
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 10),

          if (imageFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://ihosapp.misa.vn/system/api/g1/file/Files/image/$imageFileName",
                  headers: {
                    "Authorization":
                    "Bearer ${Get.find<LoginController>().accessToken.value}",
                    "x-sessionid": Get.find<LoginController>().userContext.value?.sessionId ?? "",
                    "Cookie":
                    "x-ihos-tid=${Get.find<LoginController>().userContext.value?.tenantId}; "
                        "x-ihos-sid=${Get.find<LoginController>().userContext.value?.sessionId}",
                  },
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 15),

          // Thao tác (Like, Comment, Chat)
          // --- ACTIONS LIKE | COMMENT | CHAT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => newsfeedcontroller.toggleLike(index),
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Thích (${post.postLikes?.length ?? 0})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              _postActionItem("Bình luận", Icons.chat_bubble_outline),
              _postActionItem("Chat", Icons.message_outlined),
            ],
          ),
        ],
      ),
    );
  }

  // ... (Giữ nguyên các hàm phụ còn lại)

  // Widget phụ cho _buildFunctionMenu
  // home_page.dart (Sửa _menuItem)

  Widget _menuItem(String title, IconData icon, Color color) {
    return Material(
      // 1. Bọc bằng Material
      color: Colors.transparent,
      child: InkWell(
        // 2. Sử dụng InkWell để có hiệu ứng chạm
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

        child: Padding(
          // 3. Thêm Padding để nới rộng khu vực chạm
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
    return Material(
      // Bọc bằng Material để InkWell hoạt động
      color: Colors.transparent, // Nền trong suốt
      child: InkWell(
        // Sử dụng InkWell để có hiệu ứng ripple
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
            }),

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
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  // Giả định đang ở trong một Widget sử dụng Controller có chứa các biến RxList trên
  // Ví dụ: final MyController controller = Get.find();

  Widget _buildBirthdayBanner(HomeController controller) {

    // 1. Bọc bằng Obx để theo dõi sự thay đổi của todayPriorityBirthdays
    return Obx(() {
      // 2. Lấy dữ liệu người sinh nhật đầu tiên
      final List<User> birthdays = controller.AlltodayPriorityBirthdays;

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
        height: 130,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lấy tên từ model
                          Text(
                            birthdayPerson.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          // Thêm thông báo nếu có nhiều hơn 1 người sinh nhật
                          if (hasMultipleBirthdays)
                            Text(
                              '+ ${birthdays.length - 1} người khác cùng ngày',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            )
                          else
                            const Text(
                              'Sinh nhật hôm nay!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: const Text(
                        'Gửi lời chúc',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
            ),
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
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

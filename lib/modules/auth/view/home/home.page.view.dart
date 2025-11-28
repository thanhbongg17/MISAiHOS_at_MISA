import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- Imports (Đảm bảo đường dẫn đúng với project của bạn) ---
import '../../../../data/models/newsfeed/newsfeed.model.dart';
import '../../controller/home.controller.dart';
import '../../controller/login.controller.dart';
import '../../../../data/models/user/user.model.dart';
import '../../controller/newsfeed.controller.dart';
// Thêm dòng này trên đầu file
import '../../widgets/custom.network.image.dart'; // Đường dẫn tùy vào nơi bạn tạo file

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Init Controllers
    final HomeController homeController = Get.put(HomeController());

    // Tìm hoặc tạo NewsFeedController
    final NewsFeedController newsFeedController = Get.isRegistered<NewsFeedController>()
        ? Get.find<NewsFeedController>()
        : Get.put(NewsFeedController());

    return Scaffold(
      backgroundColor: Colors.cyan[50],
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan[50]!, Colors.cyan[100]!, Colors.white],
              stops: const [0.1, 0.2, 0.38],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(homeController),

              // --- PHẦN NỘI DUNG CHÍNH ---
              Expanded(
                child: Obx(() {
                  // Lấy state từ controller
                  final isLoading = newsFeedController.isLoading.value;
                  final isRefreshing = newsFeedController.isRefreshing.value;
                  final posts = newsFeedController.feedPosts;
                  final isEmpty = posts.isEmpty;

                  // Header chung (Menu + Birthday)
                  final header = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFunctionMenu(homeController, newsFeedController),
                      _buildUserList(homeController),
                      _buildBirthdayBanner(homeController),
                      Divider(height: 10, thickness: 10.0, color: Colors.cyan[50]),
                    ],
                  );

                  // 1. Loading lần đầu
                  if (isLoading && !isRefreshing && isEmpty) {
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: header),
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }

                  // 2. Empty State (Không có bài viết)
                  if (isEmpty && !isLoading && !isRefreshing) {
                    return RefreshIndicator(
                      onRefresh: newsFeedController.onRefresh,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: header),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Danh sách bài viết
                  return RefreshIndicator(
                    onRefresh: newsFeedController.onRefresh,
                    child: CustomScrollView(
                      controller: newsFeedController.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: header),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index >= posts.length) return const SizedBox.shrink();
                              return _buildFeedPost(
                                homeController,
                                newsFeedController,
                                posts[index],
                                index,
                              );
                            },
                            childCount: posts.length,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET FEED POST (ĐÃ FIX LỖI NULL Ở PHẦN ẢNH) ---
  Widget _buildFeedPost(
      HomeController controller,
      NewsFeedController newsFeedController,
      FeedPost post,
      int index,
      ) {
    // 1. LOGIC LẤY NỘI DUNG CHỮ (Ưu tiên Summary nếu ContentPlainText rỗng)
    String displayContent = "";
    if (post.summary != null && post.summary!.trim().isNotEmpty) {
      displayContent = post.summary!;
    } else if (post.contentPlainText != null && post.contentPlainText!.trim().isNotEmpty) {
      displayContent = post.contentPlainText!;
    }

    // 2. LOGIC LẤY ẢNH (Đã check null trong Model)
    final String imageUrl = post.displayImage??"";

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Avatar + Tên
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey,
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      _formatDate(post.publishDate),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz),
            ],
          ),

          const SizedBox(height: 10),

          // BODY: Nội dung chữ (SỬA LẠI LOGIC HIỂN THỊ)
          if (displayContent.isNotEmpty)
            Text(
              displayContent,
              style: const TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 10),
          // BODY: Ảnh (BẮT BUỘC PHẢI CÓ HEADERS)
          if (imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomNetworkImage(
                imageUrl: imageUrl,
                headers: _getAuthHeaders(), // Token để tải ảnh thật
                borderRadius: BorderRadius.circular(12),
                height: post.featureImageType == 3 ? 250 : 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(12),
              //   child: Image.network(
              //     imageUrl,
              //     // [QUAN TRỌNG] Headers chứa Token để Server cho phép tải ảnh
              //     headers: _getAuthHeaders(),
              //     height: post.featureImageType == 3 ? 250 : 200,
              //     width: double.infinity,
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) {
              //       return Container(
              //         height: 200,
              //         color: Colors.grey[200],
              //         alignment: Alignment.center,
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             const Icon(Icons.broken_image, color: Colors.grey),
              //             const SizedBox(height: 5),
              //             Text("Lỗi ảnh: ${imageUrl.split('/').last}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              //           ],
              //         ),
              //       );
              //     },
              //     loadingBuilder: (context, child, loadingProgress) {
              //       if (loadingProgress == null) return child;
              //       return Container(
              //         height: 200,
              //         color: Colors.grey[100],
              //         child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              //       );
              //     },
              //   ),
              // ),
            ),
          // const Divider(height: 1),
          const SizedBox(height: 10),

          // FOOTER: Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => newsFeedController.toggleLike(index),
                child: Row(
                  children: [
                    Icon(
                      (post.selfLike == true) ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 20,
                      color: (post.selfLike == true) ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Thích (${post.totalLikeCount})',
                      style: TextStyle(
                        fontSize: 13,
                        color: (post.selfLike == true) ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _postActionItem("Bình luận (${post.totalCommentsCount})", Icons.chat_bubble_outline),
              _postActionItem("Chia sẻ", Icons.share_outlined),
            ],
          ),
          //const SizedBox(height: 10),
          //Divider(height: 10, thickness: 10.0, color: Colors.cyan[50]),
        ],
      ),
    );
  }

  // --- HELPER QUAN TRỌNG ĐỂ LẤY TOKEN ---
  Map<String, String> _getAuthHeaders() {
    if (!Get.isRegistered<LoginController>()) return {};
    final loginCtrl = Get.find<LoginController>();
    final token = loginCtrl.accessToken.value;
    final context = loginCtrl.userContext.value;

    final auth = token.startsWith("Bearer ") ? token : "Bearer $token";

    return {
      "Authorization": auth,
      "x-sessionid": context?.sessionId ?? "",
      "Cookie": "x-ihos-tid=${context?.tenantId}; x-ihos-sid=${context?.sessionId}",
      "DeviceType": "Smartphone",
    };
  }

  // --- Các Widget phụ khác ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Chưa có bài viết nào', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Kéo xuống để làm mới', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildAppBar(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(children: [
            Text('Bảng tin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Icon(Icons.keyboard_arrow_down),
          ]),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle),
              child: const Icon(Icons.star, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 15),
            const Icon(Icons.chat_bubble_outline, color: Colors.blueGrey, size: 28),
            const SizedBox(width: 15),
            Obx(() => Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.blueGrey, size: 28),
                if (controller.notificationCount.value > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    ),
                  ),
              ],
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildFunctionMenu(HomeController controller, NewsFeedController newsfeedcontroller) {
    final PageController pageController = PageController();
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.fromLTRB(6, 15, 6, 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 245, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 75,
            child: PageView.builder(
              controller: pageController,
              itemCount: newsfeedcontroller.totalPages,
              onPageChanged: newsfeedcontroller.updatePage,
              itemBuilder: (context, pageIndex) {
                final itemsPerPage = 4;
                final start = pageIndex * itemsPerPage;
                final end = (start + itemsPerPage > newsfeedcontroller.functionItems.length)
                    ? newsfeedcontroller.functionItems.length
                    : start + itemsPerPage;
                final pageItems = newsfeedcontroller.functionItems.sublist(start, end);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: pageItems.map((item) => _menuItem(item.title, item.icon, item.color)).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              newsfeedcontroller.totalPages,
                  (index) => Obx(() => _pageDot(
                newsfeedcontroller.currentPage.value == index,
                    () => pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
              )),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    ));
  }

  Widget _menuItem(String title, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.snackbar('Thông báo', 'Bạn chọn: $title', snackPosition: SnackPosition.TOP, backgroundColor: color.withOpacity(0.8), colorText: Colors.white),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
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

  Widget _pageDot(bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 10 : 8,
        height: isActive ? 10 : 8,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildUserList(HomeController controller) {
    return Obx(() {
      if (controller.todayPriorityBirthdays.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...controller.todayPriorityBirthdays.map((user) => _userAvatar(user.name, user.initials, user.color)),
            GestureDetector(onTap: controller.navigateToAllUsers, child: _userAvatar('Tất cả', '...', Colors.blue)),
          ],
        ),
      );
    });
  }

  Widget _userAvatar(String name, String initial, Color color) {
    return Column(children: [
      CircleAvatar(radius: 20, backgroundColor: color, child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(height: 5),
      Text(name, style: const TextStyle(fontSize: 13, color: Colors.black54)),
    ]);
  }

  Widget _buildBirthdayBanner(HomeController controller) {
    return Obx(() {
      final birthdays = controller.AlltodayPriorityBirthdays;
      if (birthdays.isEmpty) return const SizedBox.shrink();
      final birthdayPerson = birthdays.first;
      return Container(
        height: 130,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.lightGreen.shade50]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              CircleAvatar(radius: 20, backgroundColor: birthdayPerson.color, child: Text(birthdayPerson.initials, style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(birthdayPerson.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(birthdays.length > 1 ? '+ ${birthdays.length - 1} người khác' : 'Sinh nhật hôm nay!', style: const TextStyle(fontSize: 12)),
              ]),
            ]),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade300)), child: const Text('Gửi lời chúc', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13))),
          ])),
          const Align(alignment: Alignment.topRight, child: Icon(Icons.cake, color: Colors.pink, size: 40)),
        ]),
      );
    });
  }

  Widget _postActionItem(String title, IconData icon) {
    return Row(children: [Icon(icon, color: Colors.grey, size: 20), const SizedBox(width: 5), Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13))]);
  }
}


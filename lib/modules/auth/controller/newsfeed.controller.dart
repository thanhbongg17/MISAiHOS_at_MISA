import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/newsfeed/newsfeed.model.dart';
import '../../../data/services/newsfeed/newsfeed.service.dart';
import '../controller/login.controller.dart';

// Định nghĩa Model cho Menu Item
class FunctionItem {
  final String title;
  final IconData icon;
  final Color color;
  FunctionItem(this.title, this.icon, this.color);
}

class NewsFeedController extends GetxController {
  // --- Services & State ---
  final NewsFeedService _service = NewsFeedService();

  final RxList<FeedPost> feedPosts = <FeedPost>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  DateTime? lastModifiedDate;
  bool _isLoadingInProgress = false;

  final ScrollController scrollController = ScrollController();

  // --- LOGIC MENU (Giữ lại để View không bị lỗi) ---
  final currentPage = 0.obs;

  // Danh sách các icon chức năng
  final RxList<FunctionItem> functionItems = <FunctionItem>[
    FunctionItem("Bảng tin", Icons.newspaper, Colors.blue),
    FunctionItem("Danh bạ", Icons.contact_phone, Colors.green),
    FunctionItem("Chấm công", Icons.access_time, Colors.orange),
    FunctionItem("Xin nghỉ", Icons.flight_takeoff, Colors.red),
    FunctionItem("Lương", Icons.monetization_on, Colors.purple),
    FunctionItem("Đề xuất", Icons.assignment, Colors.teal),
    FunctionItem("Công việc", Icons.work, Colors.brown),
    FunctionItem("Khác", Icons.apps, Colors.grey),
  ].obs;

  // Getter tính tổng số trang
  int get totalPages {
    if (functionItems.isEmpty) return 1;
    return (functionItems.length / 4).ceil();
  }

  // Hàm update trang
  void updatePage(int index) {
    currentPage.value = index;
  }
  // ----------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => loadFeed(isRefresh: false));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // --- GỌI API NEWSFEED ---
  Future<void> loadFeed({bool isRefresh = false}) async {
    if (_isLoadingInProgress) return;

    if (!Get.isRegistered<LoginController>()) return;
    final loginController = Get.find<LoginController>();
    final token = loginController.accessToken.value;
    final userContext = loginController.userContext.value;

    if (token.isEmpty) return;

    _isLoadingInProgress = true;
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      if (feedPosts.isEmpty) isLoading.value = true;
    }

    try {
      final dateToLoad = isRefresh ? null : lastModifiedDate;

      final response = await _service.getNewsFeed(
        token,
        sessionId: userContext?.sessionId,
        tenantId: userContext?.tenantId,
        modifiedDate: dateToLoad,
      );

      if (response.data.isNotEmpty) {
        lastModifiedDate = response.data.first.publishDate;

        if (isRefresh) {
          feedPosts.assignAll(response.data);
        } else {
          final existingIds = feedPosts.map((e) => e.postId).toSet();
          final newPosts = response.data.where((p) => !existingIds.contains(p.postId)).toList();

          if (newPosts.isNotEmpty) {
            feedPosts.insertAll(0, newPosts);
            feedPosts.sort((a, b) => b.publishDate.compareTo(a.publishDate));
          }
        }
      }
    } catch (e) {
      print("Error loading feed: $e");
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isLoadingInProgress = false;
    }
  }

  Future<void> onRefresh() async {
    await loadFeed(isRefresh: true);
  }

  void toggleLike(int index) {
    // Logic like
  }
}


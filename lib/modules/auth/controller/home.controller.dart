// home_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/home/home.model.dart';
import '../../../data/models/user/user.model.dart';
import '../view/birthday/birthday.list.page.dart';
import '../../../data/models/user/user.model.dart';



class HomeController extends GetxController {
  // --- Các biến trạng thái đơn giản ---
  var notificationCount = 1.obs;
  var currentPage = 0.obs; // Thêm biến theo dõi trang hiện tại
  @override
  void onInit() {
    super.onInit();
    fetchFeedPosts();
    fetchUsersAndBirthdays();
  }

  // --- RxList cho Dữ liệu từ API ---

  // 1. Dữ liệu menu chức năng (Danh sách đầy đủ)
  final RxList<FunctionItem> functionItems = <FunctionItem>[
    FunctionItem('Viết bài', Icons.edit_note, Colors.blue),
    FunctionItem('Lập đơn', Icons.description_outlined, Colors.red),
    FunctionItem('Đặt phòng', Icons.calendar_month, Colors.orange),
    FunctionItem('Chạy quy trình', Icons.autorenew, Colors.teal),

    FunctionItem('Lập đơn', Icons.description_outlined, Colors.red),
    FunctionItem('Đặt phòng', Icons.calendar_month, Colors.orange),
    FunctionItem('Chạy quy trình', Icons.autorenew, Colors.teal),
    FunctionItem('Tùy chỉnh', Icons.inventory, Colors.purple),

  ].obs;
  //2.Dữ liệu sinh nhật
  // ... (các biến trạng thái và RxList khác)

  // Danh sách TẤT CẢ người dùng (Dùng để hiển thị khi nhấn "Tất cả")
  final RxList<User> allUsers = <User>[].obs;

  // Danh sách ƯU TIÊN: Chỉ chứa tối đa 2 người có sinh nhật hôm nay
  final RxList<User> todayPriorityBirthdays = <User>[].obs;
  // tất cả người sinh nhật hôm nay
  final RxList<User> AlltodayPriorityBirthdays = <User>[].obs;

  // --- Hàm Giả lập lấy và Lọc Sinh Nhật Ưu tiên ---
  void fetchUsersAndBirthdays() async {
    // 2.1. Giả lập Dữ liệu từ API/DB
    final mockAllUsers = [
      User(name: 'Hà Văn Tùng', initials: 'HT', color: Colors.green, dateOfBirth: DateTime(1990, 11, 19)),
      User(name: 'Lê Thu Linh', initials: 'LL', color: Colors.purple, dateOfBirth: DateTime(1995, 12, 5)), // Không sinh nhật
      User(name: 'Nguyễn Văn Nam', initials: 'NN', color: Colors.blue, dateOfBirth: DateTime(1985, 11, 19)),
      User(name: 'Phạm Thị Mai', initials: 'PM', color: Colors.red, dateOfBirth: DateTime(1992, 11, 19)), // Người sinh nhật thứ 3
      User(name: 'Đào Duy Anh', initials: 'ĐA', color: Colors.brown, dateOfBirth: DateTime(1993, 7, 10)), // Không sinh nhật
      User(name: 'Phạm Tiến Thành', initials: 'ĐA', color: Colors.brown, dateOfBirth: DateTime(1993, 11, 19)),
    ];

    allUsers.value = mockAllUsers; // Lưu toàn bộ danh sách

    final today = DateTime.now();

    // 2.2. Lọc: Lấy TẤT CẢ những người sinh nhật hôm nay
    final usersWithBirthdayToday = mockAllUsers.where((user) {
      return user.dateOfBirth.day == today.day && user.dateOfBirth.month == today.month;
    }).toList();

    // 2.3. Lọc Ưu tiên: Chỉ lấy 2 người đầu tiên (hoặc ít hơn)
    // Nếu có 3 người sinh nhật, chỉ 2 người đầu tiên được chọn.
    todayPriorityBirthdays.value = usersWithBirthdayToday.take(2).toList();
    // tất cả người sinh nhật hôm nay
    AlltodayPriorityBirthdays.value = usersWithBirthdayToday.take(100).toList();
  }

  // --- Hàm Xử lý khi nhấn "Tất cả" ---
  void navigateToAllUsers() {
    // Đây là nơisẽ điều hướng đến trang danh sách TẤT CẢ người dùng
    // Sử dụng Get.to() hoặc hiển thị dialog chứa allUsers.value

    if (allUsers.isNotEmpty) {
      Get.to(() => BirthdayListPage(birthdays: AlltodayPriorityBirthdays.value)); // Gọi trang mới

    } else {
      Get.snackbar('Thông báo', 'Hôm nay không có ai sinh nhật!', snackPosition: SnackPosition.BOTTOM);
    }
  }
  // 3. Dữ liệu bài đăng
  final RxList<FeedPost> feedPosts = <FeedPost>[].obs;
  var isLoading = true.obs;

  // --- GETTER ĐÃ SỬA LỖI ---
  // Tổng số trang (4 items/trang), sử dụng ceil() để làm tròn lên.
  int get totalPages {
    if (functionItems.isEmpty) return 1; // Tránh chia cho 0 nếu danh sách rỗng
    return (functionItems.length / 4).ceil();
  }
  // -------------------------



  // --- Hàm quản lý PageView ---
  void updatePage(int index) {
    currentPage.value = index;
  }

  // --- Hàm giả lập gọi API cho Feed Posts ---
  void fetchFeedPosts() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    final mockData = [
      FeedPost(
        userName: 'Nguyễn Văn Tùng',
        timeAgo: '3 ngày trước • 🌐',
        content: 'hi',
        attachmentName: 'Screenshot_...SA iHOS.jpg',
        initialLikes: 1,
        isLiked: true,
      ),
      FeedPost(
        userName: 'Trần Thị Hà',
        timeAgo: '1 giờ trước • 🔒',
        content: 'Báo cáo tháng đã hoàn thành.',
        attachmentName: 'Report_T11.xlsx',
        initialLikes: 5,
        isLiked: false,
      ),
    ];

    feedPosts.value = mockData;
    isLoading.value = false;
  }

  // --- Hàm xử lý Logic Business/Action (Like) ---
  void toggleLike(int index) {
    if (index < 0 || index >= feedPosts.length) return;

    var post = feedPosts[index];

    final newPost = FeedPost(
      userName: post.userName,
      timeAgo: post.timeAgo,
      content: post.content,
      attachmentName: post.attachmentName,
      initialLikes: post.isLiked ? post.initialLikes - 1 : post.initialLikes + 1,//lỗi cc gì thế này
      isLiked: !post.isLiked,
    );

    feedPosts[index] = newPost;
  }
}
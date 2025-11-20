import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/home.controller.dart';
import '../../data/models/home/home.model.dart';
import '../../data/models/user/user.model.dart';
import '../auth/view/home/home.page.view.dart';
import 'dart:math' as math;


class MainFeedContent extends StatelessWidget {
  const MainFeedContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure HomeController is registered. If not, create and register it.
    final HomeController controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final pages = controller.pages;
        final idx = controller.currentIndex.value;

        print('[MainFeedContent] pages=${pages.length} idx=$idx');

        final List<Widget> safePages = pages.isEmpty ? [const HomePageView()] : pages;

        return Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: (idx < 0 || idx >= safePages.length) ? 0 : idx,
                children: safePages.map((w) {
                  // Ensure each child is keyed so Flutter treats them as stable
                  return KeyedSubtree(key: ValueKey(w.hashCode), child: w);
                }).toList(),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),

              ),
            ),
          ],
        );
      }),

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
          currentIndex: controller.currentIndex.value,

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
//MainFeedContent

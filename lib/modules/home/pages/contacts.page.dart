import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/view/contact/contact.view.dart';
import '../../auth/controller/contact.controller.dart';
import '../../../data/services/contact/contact.service.dart';

class ContactsPage extends StatelessWidget {
  // 1. Thêm 'const' vào constructor để sửa lỗi biên dịch trong UserRoutes
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Dependency Injection (DI) trực tiếp - "Không dùng Binding"
    // Khi trang này được build, nó sẽ tự động khởi tạo Service và Controller

    // Khởi tạo Service
    final service = ContactService();

    // Đăng ký Controller và Inject Service vào
    // Get.put đảm bảo Controller được đưa vào bộ nhớ để View sử dụng
    Get.put(ContactController(contactService: service));

    // 3. Trả về View chính (Giao diện)
    return Scaffold(
      body: ContactView(),
    );
  }
}


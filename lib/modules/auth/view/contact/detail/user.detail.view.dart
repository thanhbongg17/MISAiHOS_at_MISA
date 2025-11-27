import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // 👇 1. Nhớ import thư viện này
import '../../../../../data/models/contact/contact.model.dart';
import '../../../../../token/token.manager.dart';

class UserDetailView extends StatelessWidget {
  final ContactUser user;

  const UserDetailView({super.key, required this.user});

  // 👇 2. Hàm gọi điện chuẩn (Copy từ UserListTile sang)
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      print("không thể mở trình gọi điện: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 60),
            _buildUserInfo(),
            const SizedBox(height: 20),

            // Các nút hành động (Gọi, Chat...)
            _buildActionButtons(),

            const SizedBox(height: 20),
            _buildDivider(),

            // Thông tin liên hệ (SĐT, Email)
            _buildContactInfo(),

            _buildDivider(),
            _buildPersonalInfo(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ... (Phần Header, Avatar, UserInfo giữ nguyên như cũ) ...

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan[200]!, Colors.cyan[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: _buildAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 46,
        backgroundColor: Colors.teal[100],
        child: Text(
          (user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName![0] : "A",
          style: TextStyle(fontSize: 40, color: Colors.teal[700], fontWeight: FontWeight.bold),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        user.avatarUrl!, width: 92, height: 92, fit: BoxFit.cover,
        headers: {
          "Authorization": "Bearer ${TokenManager.getManualTokenForImage()}",
          "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
        },
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 46, backgroundColor: Colors.teal[100],
          child: const Icon(Icons.person, size: 50, color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(user.fullName ?? "Không có tên", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(user.jobTitleName ?? "Chức vụ: --", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(user.departmentName ?? "Đơn vị: --", style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // 👇 3. SỬA PHẦN NÚT HÀNH ĐỘNG
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Nút Gọi điện
        _buildActionButton(
          Icons.call_outlined,
          "Gọi điện",
          Colors.teal,
          onTap: () => _makePhoneCall(user.mobilePhone), // Gắn hàm gọi
        ),
        _buildActionButton(Icons.chat_bubble_outline, "Chat", Colors.teal),
        _buildActionButton(Icons.contacts_outlined, "Danh bạ", Colors.teal),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // Thêm sự kiện tap
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // 👇 4. SỬA PHẦN THÔNG TIN LIÊN HỆ (Bấm vào số là gọi)
  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.phone_android,
            label: "Điện thoại di động",
            value: user.mobilePhone ?? "",
            isLink: true,
            // Gắn hàm gọi vào đây
            onTap: () => _makePhoneCall(user.mobilePhone),
          ),
          const Divider(height: 1, indent: 50),
          _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email cơ quan",
              value: user.email ?? "",
              isLink: true
          ),
        ],
      ),
    );
  }

  // 5. Hàm xây dựng dòng thông tin (Đã thêm onTap)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap, // Thêm tham số onTap
  }) {
    return InkWell(
      onTap: isLink && value.isNotEmpty ? onTap : null, // Chỉ cho bấm nếu là link và có dữ liệu
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "-" : value,
                    style: TextStyle(
                        fontSize: 16,
                        color: isLink ? Colors.blue[700] : Colors.black,
                        fontWeight: isLink ? FontWeight.w500 : FontWeight.normal
                    ),
                  ),
                ],
              ),
            ),
            if (isLink && value.isNotEmpty)
              Icon(Icons.chat_bubble_outline, color: Colors.blue[700], size: 20),
          ],
        ),
      ),
    );
  }

  // ... (Các phần còn lại giữ nguyên) ...
  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Thông tin cá nhân", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          _buildDetailItem("Mã nhân viên", user.employeeId ?? "-"),
          _buildDetailItem("Đơn vị", user.departmentName ?? "-"),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 12), const Divider(height: 1)]),
    );
  }

  Widget _buildDivider() => Container(height: 8, color: Colors.grey[100]);
}
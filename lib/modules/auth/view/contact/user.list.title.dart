import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/contact/contact.model.dart';
import '../../../../token/token.manager.dart';
import 'detail/user.detail.view.dart';

class UserListTile extends StatelessWidget {
  final ContactUser user;
  const UserListTile({super.key, required this.user});

  Color _getAvatarColor(String fullName) {
    final colors = [
      Colors.pink, Colors.purple, Colors.blue, Colors.cyan,
      Colors.teal, Colors.green, Colors.orange, Colors.red,
    ];
    int hash = fullName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return "?";
    final parts = fullName.trim().split(' ');
    String initials = '';
    if (parts.length >= 2) {
      initials = parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      initials = parts[0][0];
    }
    return initials.toUpperCase();
  }
  // 2. Hàm thực hiện cuộc gọi
  // Hàm gọi điện an toàn
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    // Xóa ký tự lạ, chỉ giữ số và dấu +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print("Không thể mở trình gọi điện");
      }
    } catch (e) {
      print("Lỗi gọi điện: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = user.fullName ?? "Không tên";

    // Dùng jobTitleName thay vì positionName
    final String position = user.jobTitleName ?? "";
    final String department = user.departmentName ?? "";

    // Logic ghép chuỗi: "Chức vụ | Phòng ban"
    String subtitleText = department;
    if (position.isNotEmpty && department.isNotEmpty) {
      subtitleText = '$position | $department';
    } else if (position.isNotEmpty) {
      subtitleText = position;
    }
    // Kiểm tra null an toàn cho mobilePhone
    final bool hasMobilePhone = user.mobilePhone != null && user.mobilePhone!.isNotEmpty;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _buildAvatar(fullName),
          title: Text(
            fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),

          subtitle: Text(
            subtitleText,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // NÚT GỌI ĐIỆN (ĐÃ SỬA)
          trailing: hasMobilePhone
              ? IconButton(
            icon: const Icon(Icons.call_outlined, color: Color(0xFF00C9B1)),
            onPressed: () {
              // Gọi hàm mở trình gọi điện
              _makePhoneCall(user.mobilePhone!);
            },
          )
              : const SizedBox(width: 48),

          // SỰ KIỆN CHUYỂN TRANG CHI TIẾT
          onTap: () {
            Get.to(() => UserDetailView(user: user));
          },
        ),
        // Divider(height: 0, indent: 72, color: Color(0xFFFAFAFA)),
      ],
    );
  }

  Widget _buildAvatar(String fullName) {
    final fallbackAvatar = CircleAvatar(
      radius: 20,
      backgroundColor: _getAvatarColor(fullName).withOpacity(0.7),
      child: Text(
        _getInitials(fullName),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );

    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return fallbackAvatar;
    }

    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          user.avatarUrl!,
          fit: BoxFit.cover,
          headers: {
            // Lấy token từ hàm static bạn đã viết (hoặc fix cứng tạm)
            "Authorization": "Bearer ${TokenManager.getToken()}",
            "Cookie": "x-ihos-tid=${TokenManager.tenantId}; x-ihos-sid=${TokenManager.sessionId}",
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallbackAvatar;
          },
          errorBuilder: (context, error, stackTrace) {
            return fallbackAvatar;
          },
        ),
      ),
    );
  }
}
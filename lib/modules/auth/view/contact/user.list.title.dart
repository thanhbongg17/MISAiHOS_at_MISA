import 'package:flutter/material.dart';
import '../../../../data/models/contact/contact.model.dart';

class UserListTile extends StatelessWidget {
  final ContactUser user;
  const UserListTile({super.key, required this.user});

  Color _getAvatarColor(String fullName) {
    final colors = [
      Colors.pink, Colors.purple, Colors.blue, Colors.cyan,
      Colors.teal, Colors.green, Colors.orange, Colors.red
    ];
    int hash = fullName.hashCode;
    return colors[hash % colors.length];
  }

  String _getInitials(String fullName) {
    final parts = fullName.split(' ');
    String initials = '';
    if (parts.length >= 2) {
      initials = parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      initials = parts.last[0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Xây dựng dòng phụ: Chức danh | Tên Khoa/Phòng
    final String subtitleText = user.positionName.isNotEmpty
        ? '${user.positionName} | ${user.departmentName}'
        : user.departmentName;

    final bool hasMobilePhone = user.mobilePhone != null && user.mobilePhone!.isNotEmpty;

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: _getAvatarColor(user.fullName).withOpacity(0.7),
            child: Text(
              _getInitials(user.fullName),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            subtitleText,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          trailing: hasMobilePhone
              ? IconButton(
            icon: const Icon(Icons.call_outlined, color: Color(0xFF00C9B1)),
            onPressed: () {
              // Xử lý gọi điện
            },
          )
              : null,
          onTap: () {
            // Xử lý chuyển trang chi tiết
          },
        ),
        const Divider(height: 1, indent: 72, color: Colors.black12),
      ],
    );
  }
}

import 'package:flutter/material.dart';

// Model cho các mục menu chức năng (Viết bài, Lập đơn...)
class FunctionItem {
  final String title;
  final IconData icon;
  final Color color;

  FunctionItem(this.title, this.icon, this.color);
}

// Model cho các bài đăng (Feed Post)
class FeedPost {
  final String userName;
  final String timeAgo;
  final String content;
  final String attachmentName;
  final int initialLikes;
  final bool isLiked; // Trạng thái like ban đầu

  FeedPost({
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.attachmentName,
    this.initialLikes = 0,
    this.isLiked = false,
  });
}
import 'dart:math';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatefulWidget {
  final String imageUrl;
  final Map<String, String>? headers;
  final double height;
  final double width;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  const CustomNetworkImage({
    Key? key,
    required this.imageUrl,
    this.headers,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  // Biến lưu chỉ số random cố định cho mỗi bài viết (để không bị nháy ảnh khi cuộn)
  late int _fallbackIndex;

  @override
  void initState() {
    super.initState();
    // Random 1 số từ 0 đến 9 (tương ứng 10 ảnh trong assets)
    _fallbackIndex = Random().nextInt(10)+1;
  }

  @override
  Widget build(BuildContext context) {
    // Logic: Nếu URL rỗng thì coi như lỗi -> hiện ảnh fallback luôn
    if (widget.imageUrl.isEmpty) {
      return _buildFallbackImage();
    }

    Widget imageContent = Image.network(
      widget.imageUrl,
      headers: widget.headers, // Token quan trọng để tải ảnh thật
      height: widget.height,
      width: widget.width,
      fit: widget.fit,

      // 1. Loading: Hiện vòng quay khi đang tải ảnh thật
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child; // Tải xong -> Hiện ảnh thật
        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },

      // 2. Error: Chỉ khi ảnh thật bị lỗi -> Hiện ảnh Random từ Assets
      errorBuilder: (context, error, stackTrace) {
        print("Lỗi tải ảnh thật: $error -> Dùng fallback $_fallbackIndex");
        return _buildFallbackImage();
      },
    );

    // Bo góc nếu cần
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildFallbackImage() {
    // Giả sử bạn lưu ảnh tên là: img_0.png, img_1.png ... img_9.png
    // Đường dẫn: assets/images/fallback/
    return Image.asset(
      'assets/images/images_news_feed/newsfeed$_fallbackIndex.png',
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      // Nếu quên chép ảnh vào assets thì hiện icon xám để tránh crash app
      errorBuilder: (context, error, stackTrace) => Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
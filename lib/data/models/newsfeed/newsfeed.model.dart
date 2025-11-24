import 'package:flutter/material.dart';

class FunctionItem {
  final String title;
  final IconData icon;
  final Color color;

  FunctionItem(this.title, this.icon, this.color);
}

// có 3 nhóm dữ liệu
//nhóm 1: Response wrapper
class NewsFeedResponse {
  final bool success;
  final int code;
  final List<FeedPost> data;

  NewsFeedResponse({
    required this.success,
    required this.code,
    required this.data,
  });

  factory NewsFeedResponse.fromJson(Map<String, dynamic> json) {
    // Xử lý trường hợp Data có thể là null hoặc không phải List
    List<FeedPost> posts = [];

    print("[NewsFeedResponse] Starting to parse response...");
    print(
      "[NewsFeedResponse] Success: ${json['Success']}, Code: ${json['Code']}",
    );
    print("[NewsFeedResponse] Data type: ${json['Data']?.runtimeType}");
    print("[NewsFeedResponse] Data is null: ${json['Data'] == null}");

    if (json['Data'] != null && json['Data'] is List) {
      try {
        final dataList = json['Data'] as List;
        print(
          "[NewsFeedResponse] Parsing ${dataList.length} posts from Data array",
        );

        int successCount = 0;
        int errorCount = 0;

        for (int i = 0; i < dataList.length; i++) {
          try {
            if (dataList[i] == null) {
              print("[NewsFeedResponse] Post at index $i is null, skipping");
              errorCount++;
              continue;
            }

            final postJson = dataList[i] as Map<String, dynamic>;
            final post = FeedPost.fromJson(postJson);
            posts.add(post);
            successCount++;

            if (i == 0) {
              print(
                "[NewsFeedResponse] First post parsed - ID: ${post.postId}, Author: ${post.authorName}",
              );
            }
          } catch (e, stackTrace) {
            print("[NewsFeedResponse] ❌ Error parsing post at index $i: $e");
            final postData = dataList[i];
            if (postData is Map) {
              print("[NewsFeedResponse] Post JSON keys: ${postData.keys}");
              final postStr = postData.toString();
              print(
                "[NewsFeedResponse] Post JSON sample: ${postStr.length > 200 ? postStr.substring(0, 200) : postStr}",
              );
            } else {
              print(
                "[NewsFeedResponse] Post data type: ${postData.runtimeType}",
              );
            }
            print("[NewsFeedResponse] Stack trace: $stackTrace");
            errorCount++;
            // Tiếp tục parse các post khác - KHÔNG throw để parse các post còn lại
          }
        }

        print(
          "[NewsFeedResponse] Parsing complete - Success: $successCount, Errors: $errorCount, Total: ${posts.length} posts",
        );
      } catch (e, stackTrace) {
        print("[NewsFeedResponse] CRITICAL Error parsing Data: $e");
        print("[NewsFeedResponse] Stack trace: $stackTrace");
        posts = [];
      }
    } else {
      print("[NewsFeedResponse] WARNING: Data is null or not a List!");
      print("[NewsFeedResponse] Data value: ${json['Data']}");
    }

    final response = NewsFeedResponse(
      success: json['Success'] ?? false,
      code: json['Code'] ?? 0,
      data: posts,
    );

    print(
      "[NewsFeedResponse] Final response - Success: ${response.success}, Code: ${response.code}, Posts: ${response.data.length}",
    );

    return response;
  }
}

//nhóm 2:Model chính: NewsPost
class FeedPost {
  final int postId;
  final String? tenantId;

  final String? title;
  final String? summary;

  final String? contentPlainText;
  final String? content; // nội dung HTML

  final int postType;
  final int status;

  final String authorName;
  final String authorId;

  final DateTime publishDate;

  final int imagesCount;
  final List<String> images;
  final List<ImageDetail>? listImageDetail;

  final int totalViewCount;
  final int totalViewer;

  final String? featureImage;

  final int commentsCount;
  final int totalCommentsCount;

  final int totalLikeCount;
  final bool? selfLike;

  final List<PostLike>? postLikes;
  final List<TopComment>? topComment;

  FeedPost({
    required this.postId,
    this.tenantId,
    this.title,
    this.summary,
    this.contentPlainText,
    this.content,
    this.listImageDetail,
    required this.postType,
    required this.status,
    required this.publishDate,
    required this.imagesCount,
    required this.authorName,
    required this.authorId,
    required this.totalViewCount,
    required this.totalViewer,
    this.featureImage,
    required this.commentsCount,
    required this.totalCommentsCount,
    required this.images,
    required this.totalLikeCount,
    this.selfLike,
    this.postLikes,
    this.topComment,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    try {
      // Parse PublishDate an toàn
      DateTime publishDate;
      try {
        final publishDateStr = json['PublishDate']?.toString() ?? '';
        if (publishDateStr.isNotEmpty) {
          publishDate = DateTime.parse(publishDateStr);
        } else {
          publishDate = DateTime.now();
        }
      } catch (e) {
        print(
          "[FeedPost] Error parsing PublishDate: ${json['PublishDate']}, error: $e",
        );
        publishDate = DateTime.now();
      }

      // Parse Images
      List<String> images = [];
      try {
        if (json['Images'] != null && json['Images'] is List) {
          images = (json['Images'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print("[FeedPost] Error parsing Images: $e");
        images = [];
      }
      // Parse ListImageDetail
      List<ImageDetail>? listImageDetail;
      try {
        if (json['ListImageDetail'] != null && json['ListImageDetail'] is List) {
          listImageDetail = (json['ListImageDetail'] as List)
              .map((e) => ImageDetail.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print("[FeedPost] Error parsing ListImageDetail: $e");
        listImageDetail = null;
      }



      // Parse PostLikes
      List<PostLike>? postLikes;
      try {
        if (json['PostLikes'] != null && json['PostLikes'] is List) {
          postLikes = (json['PostLikes'] as List)
              .map((e) => PostLike.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print("[FeedPost] Error parsing PostLikes: $e");
        postLikes = null;
      }

      // Parse TopComment
      List<TopComment>? topComment;
      try {
        if (json['TopComment'] != null && json['TopComment'] is List) {
          topComment = (json['TopComment'] as List)
              .map((e) => TopComment.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        print("[FeedPost] Error parsing TopComment: $e");
        topComment = null;
      }

      // Đảm bảo tất cả các trường required đều có giá trị
      final postId = json['PostID'] is int
          ? json['PostID'] as int
          : (int.tryParse(json['PostID']?.toString() ?? '0') ?? 0);

      final authorName = json['AuthorName']?.toString() ?? 'Unknown';
      final authorId = json['AuthorID']?.toString() ?? '';

      // Validate các trường bắt buộc - nhưng không throw exception, chỉ log warning
      if (postId == 0) {
        print("[FeedPost] WARNING: PostID is 0, using fallback");
        // Không throw, chỉ log warning
      }
      if (authorName == 'Unknown' && authorId.isEmpty) {
        print("[FeedPost] WARNING: Both AuthorName and AuthorID are empty");
        // Không throw, chỉ log warning
      }

      return FeedPost(
        postId: postId,
        tenantId: json['TenantID']?.toString(),

        title: json['Title']?.toString(),
        summary: json['Summary']?.toString(),

        contentPlainText: json['ContentPlainText']?.toString() ?? '',
        content: json['Content']?.toString(),
        listImageDetail: listImageDetail,

        postType: json['PostType'] is int
            ? json['PostType'] as int
            : (int.tryParse(json['PostType']?.toString() ?? '0') ?? 0),
        status: json['Status'] is int
            ? json['Status'] as int
            : (int.tryParse(json['Status']?.toString() ?? '0') ?? 0),

        authorName: authorName,
        authorId: authorId,

        publishDate: publishDate,

        imagesCount: json['ImagesCount'] is int
            ? json['ImagesCount'] as int
            : (int.tryParse(json['ImagesCount']?.toString() ?? '0') ?? 0),
        images: images,

        totalViewCount: json['TotalViewCount'] is int
            ? json['TotalViewCount'] as int
            : (int.tryParse(json['TotalViewCount']?.toString() ?? '0') ?? 0),
        totalViewer: json['TotalViewer'] is int
            ? json['TotalViewer'] as int
            : (int.tryParse(json['TotalViewer']?.toString() ?? '0') ?? 0),

        featureImage: json['FeatureImage']?.toString(),

        commentsCount: json['CommentsCount'] is int
            ? json['CommentsCount'] as int
            : (int.tryParse(json['CommentsCount']?.toString() ?? '0') ?? 0),
        totalCommentsCount: json['TotalCommentsCount'] is int
            ? json['TotalCommentsCount'] as int
            : (int.tryParse(json['TotalCommentsCount']?.toString() ?? '0') ??
                  0),

        totalLikeCount: json['TotalLikeCount'] is int
            ? json['TotalLikeCount'] as int
            : (int.tryParse(json['TotalLikeCount']?.toString() ?? '0') ?? 0),
        selfLike: json['SelfLike'] == true
            ? true
            : (json['SelfLike'] == false ? false : null),

        postLikes: postLikes,
        topComment: topComment,
      );
    } catch (e, stackTrace) {
      print("[FeedPost] Error parsing FeedPost: $e");
      print("[FeedPost] Stack trace: $stackTrace");
      print("[FeedPost] JSON: $json");
      rethrow;
    }
  }
}

//nhóm 3: PostLike
class PostLike {
  final int postId;
  final String userId;
  final int likeType;
  final String userName;
  final bool isLike;

  PostLike({
    required this.postId,
    required this.userId,
    required this.likeType,
    required this.userName,
    required this.isLike,
  });

  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      postId: json['PostID'] is int
          ? json['PostID']
          : (int.tryParse(json['PostID']?.toString() ?? '0') ?? 0),
      userId: json['UserID']?.toString() ?? '',
      likeType: json['LikeType'] is int
          ? json['LikeType']
          : (int.tryParse(json['LikeType']?.toString() ?? '0') ?? 0),
      userName: json['UserName']?.toString() ?? '',
      isLike: json['IsLike'] == true,
    );
  }
}

//nhóm 4:TopComment
class TopComment {
  final int postId;
  final String commentId;
  final String userId;
  final String userName;
  final String body;

  TopComment({
    required this.postId,
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.body,
  });

  factory TopComment.fromJson(Map<String, dynamic> json) {
    return TopComment(
      postId: json['PostID'] is int
          ? json['PostID']
          : (int.tryParse(json['PostID']?.toString() ?? '0') ?? 0),
      commentId: json['CommentID']?.toString() ?? '',
      userId: json['UserID']?.toString() ?? '',
      userName: json['UserName']?.toString() ?? '',
      body: json['Body']?.toString() ?? '',
    );
  }
}
//nhóm 5 image
class ImageDetail {
  final String fileName;
  final int width;
  final int height;

  ImageDetail({
    required this.fileName,
    required this.width,
    required this.height,
  });

  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    return ImageDetail(
      fileName: json['FileName']?.toString() ?? "",
      width: json['ImageWidth'] is int
          ? json['ImageWidth']
          : int.tryParse(json['ImageWidth']?.toString() ?? "0") ?? 0,
      height: json['ImageHeight'] is int
          ? json['ImageHeight']
          : int.tryParse(json['ImageHeight']?.toString() ?? "0") ?? 0,
    );
  }
}


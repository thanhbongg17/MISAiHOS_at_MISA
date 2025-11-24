import 'package:get/get.dart';
import '../../../data/models/newsfeed/newsfeed.model.dart';
import '../../../data/services/newsfeed/newsfeed.service.dart';
import '../controller/login.controller.dart';

class NewsFeedController extends GetxController {
  final NewsFeedService _service = NewsFeedService();
  final RxList<FeedPost> feedPosts = <FeedPost>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs; // Trạng thái refresh
  final currentPage = 0.obs;
  final RxList<dynamic> functionItems = <dynamic>[].obs;
  DateTime?
  lastModifiedDate; // Lưu modifiedDate của post mới nhất để lấy dữ liệu mới

  // Flag để tránh gọi API nhiều lần đồng thời
  bool _isLoadingInProgress = false;
  bool _hasInitialLoad = false; // Đánh dấu đã load lần đầu chưa

  @override
  void onInit() {
    super.onInit();
    print(
      "[NewsFeedController] onInit called - _hasInitialLoad: $_hasInitialLoad",
    );

    // CHỈ load một lần khi controller được khởi tạo
    if (!_hasInitialLoad) {
      // Đợi một chút để đảm bảo LoginController đã được khởi tạo và token đã được lưu
      // Sử dụng microtask để đảm bảo chạy sau khi widget tree đã được build
      Future.microtask(() async {
        // Đợi thêm một chút để token sẵn sàng
        await Future.delayed(const Duration(milliseconds: 500));

        if (!_hasInitialLoad && !_isLoadingInProgress) {
          print("[NewsFeedController] Starting initial load from onInit...");
          await _checkAndLoadFeedPosts();
        } else {
          print(
            "[NewsFeedController] Skipping initial load - already loaded or in progress",
          );
        }
      });
    } else {
      print("[NewsFeedController] Already loaded, skipping onInit load");
    }
  }

  // Hàm public để force load dữ liệu từ bên ngoài
  Future<void> ensureDataLoaded() async {
    print("[NewsFeedController] ensureDataLoaded() called");
    print(
      "[NewsFeedController] Current state - _hasInitialLoad: $_hasInitialLoad, feedPosts.length: ${feedPosts.length}, isLoading: ${isLoading.value}",
    );

    // Nếu chưa load hoặc không có dữ liệu, load lại
    if (!_hasInitialLoad || feedPosts.isEmpty) {
      if (!_isLoadingInProgress && !isLoading.value) {
        print("[NewsFeedController] No data found, loading...");
        await _checkAndLoadFeedPosts();
      } else {
        print("[NewsFeedController] Already loading, skipping...");
      }
    } else {
      print(
        "[NewsFeedController] Data already loaded: ${feedPosts.length} posts",
      );
    }
  }

  // Hàm kiểm tra token và load feed posts
  Future<void> _checkAndLoadFeedPosts() async {
    print("[NewsFeedController] _checkAndLoadFeedPosts() called");

    // Retry logic với max retries
    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      if (Get.isRegistered<LoginController>()) {
        final loginController = Get.find<LoginController>();
        final token = loginController.accessToken.value;

        print(
          "[NewsFeedController] Token check (attempt ${retryCount + 1}/$maxRetries): ${token.isNotEmpty ? 'FOUND (${token.length} chars)' : 'NOT FOUND (empty)'}",
        );

        if (token.isNotEmpty) {
          print(
            "[NewsFeedController] ✅ Token available, loading feed posts...",
          );
          await _loadFeedPosts();
          return; // Thành công, thoát khỏi loop
        } else {
          retryCount++;
          if (retryCount < maxRetries) {
            print(
              "[NewsFeedController] ⏳ Token not ready yet, waiting... (retry $retryCount/$maxRetries)",
            );
            await Future.delayed(
              Duration(seconds: retryCount),
            ); // Tăng delay mỗi lần retry
          } else {
            print(
              "[NewsFeedController] ❌ Max retries reached, token still not available",
            );
            print(
              "[NewsFeedController] ⚠️ Make sure you have logged in successfully!",
            );
            isLoading(false);
            return;
          }
        }
      } else {
        retryCount++;
        if (retryCount < maxRetries) {
          print(
            "[NewsFeedController] ⚠️ LoginController not registered yet (retry $retryCount/$maxRetries)",
          );
          print(
            "[NewsFeedController] Waiting ${retryCount} seconds and retrying...",
          );
          await Future.delayed(Duration(seconds: retryCount));
        } else {
          print(
            "[NewsFeedController] ❌ Max retries reached, LoginController still not available",
          );
          print("[NewsFeedController] ⚠️ Please login first!");
          isLoading(false);
          return;
        }
      }
    }
  }

  // Hàm helper để load feed posts với token từ LoginController
  Future<void> _loadFeedPosts({bool isRefresh = false}) async {
    // Tránh gọi API nhiều lần đồng thời
    if (_isLoadingInProgress && !isRefresh) {
      print("[NewsFeedController] ⚠️ Already loading, skipping duplicate call");
      return;
    }

    _isLoadingInProgress = true;

    try {
      print(
        "[NewsFeedController] _loadFeedPosts called (isRefresh: $isRefresh, _hasInitialLoad: $_hasInitialLoad)",
      );

      // Tìm LoginController để lấy token
      if (Get.isRegistered<LoginController>()) {
        final loginController = Get.find<LoginController>();
        final token = loginController.accessToken.value;

        print(
          "[NewsFeedController] Token found: ${token.isNotEmpty ? 'YES (${token.length} chars)' : 'NO (empty)'}",
        );

        if (token.isNotEmpty) {
          // Thêm "Bearer " prefix nếu chưa có
          // sửa newfeed
          // final fullToken = token.startsWith('Bearer ')
          //     ? token
          //     : 'Bearer $token';
          final fullToken = "Bearer $token";
          print("[NewsFeedController] Calling fetchFeedPosts with token...");
          await fetchFeedPosts(fullToken, isRefresh: isRefresh);
          _hasInitialLoad = true; // Đánh dấu đã load xong
        } else {
          print(
            "[NewsFeedController] ❌ Token is empty, cannot fetch feed posts",
          );
          if (!isRefresh) {
            // Chỉ retry một lần nếu không phải refresh
            await Future.delayed(const Duration(seconds: 2));
            if (Get.isRegistered<LoginController>()) {
              final retryController = Get.find<LoginController>();
              final retryToken = retryController.accessToken.value;
              if (retryToken.isNotEmpty && !_isLoadingInProgress) {
                print("[NewsFeedController] Retry: Token found, fetching...");
                final fullToken = retryToken.startsWith('Bearer ')
                    ? retryToken
                    : 'Bearer $retryToken';
                await fetchFeedPosts(fullToken, isRefresh: isRefresh);
                _hasInitialLoad = true;
              } else {
                print(
                  "[NewsFeedController] ❌ Retry: Token still empty or already loading",
                );
                isLoading(false);
              }
            } else {
              isLoading(false);
            }
          } else {
            isLoading(false);
          }
        }
      } else {
        print("[NewsFeedController] ❌ LoginController not found");
        if (!isRefresh) {
          // Chỉ retry một lần nếu không phải refresh
          await Future.delayed(const Duration(seconds: 1));
          if (Get.isRegistered<LoginController>() && !_isLoadingInProgress) {
            print(
              "[NewsFeedController] Retry: LoginController found, loading...",
            );
            await _loadFeedPosts(isRefresh: isRefresh);
          } else {
            isLoading(false);
          }
        } else {
          isLoading(false);
        }
      }
    } catch (e, stackTrace) {
      print("[NewsFeedController] ❌ Error loading feed posts: $e");
      print("[NewsFeedController] Stack trace: $stackTrace");
      isLoading(false);
      isRefreshing(false);
    } finally {
      _isLoadingInProgress = false;
    }
  }

  // Hàm refresh công khai để gọi từ UI (pull-to-refresh)
  Future<void> refreshFeed() async {
    print("[NewsFeedController] refreshFeed() called");
    print(
      "[NewsFeedController] Current state - isRefreshing: ${isRefreshing.value}, _isLoadingInProgress: $_isLoadingInProgress, feedPosts.length: ${feedPosts.length}",
    );

    // Tránh refresh đồng thời, nhưng nếu đã quá lâu thì cho phép refresh lại
    if (isRefreshing.value || _isLoadingInProgress) {
      print(
        "[NewsFeedController] ⚠️ Already refreshing/loading, skipping duplicate refresh",
      );
      return;
    }

    isRefreshing.value = true;
    try {
      // Reset flag để cho phép load
      _isLoadingInProgress = false;
      await _loadFeedPosts(isRefresh: true);
    } catch (e, stackTrace) {
      print("[NewsFeedController] ❌ Error in refreshFeed: $e");
      print("[NewsFeedController] Stack trace: $stackTrace");
    } finally {
      isRefreshing.value = false;
      _isLoadingInProgress = false;
      print(
        "[NewsFeedController] refreshFeed() completed - feedPosts.length: ${feedPosts.length}",
      );
    }
  }

  // === GETTER SỬA LỖI ===
  int get totalPages {
    if (functionItems.isEmpty) return 1;
    return (functionItems.length / 4).ceil();
  }

  // === CẬP NHẬT PAGEVIEW ===
  void updatePage(int index) {
    currentPage.value = index;
  }

  // === GỌI API NEWSFEED (THẬT) ===
  Future<void> fetchFeedPosts(String token, {bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        isLoading(true);
      }
      print(
        "[NewsFeedController] Starting to fetch feed posts... (refresh: $isRefresh)",
      );

      // Lấy sessionId và tenantId từ LoginController
      String? sessionId;
      String? tenantId;

      if (Get.isRegistered<LoginController>()) {
        final loginController = Get.find<LoginController>();
        sessionId = loginController.userContext.value?.sessionId;
        tenantId = loginController.userContext.value?.tenantId;
      }

      // Gọi API với modifiedDate để lấy dữ liệu mới nhất
      // Nếu refresh hoặc load lần đầu (lastModifiedDate == null), lấy tất cả
      // Nếu không, lấy từ lastModifiedDate
      final response = await _service.getNewsFeed(
        token,
        sessionId: sessionId,
        tenantId: tenantId,
        modifiedDate: (isRefresh || lastModifiedDate == null)
            ? null
            : lastModifiedDate,
      );

      print(
        "[NewsFeedController] API Response - Success: ${response.success}, Code: ${response.code}",
      );
      print(
        "[NewsFeedController] API Response - Data count: ${response.data.length}",
      );

      // Luôn xử lý dữ liệu nếu có
      print(
        "[NewsFeedController] Processing response.data: ${response.data.length} posts",
      );

      if (response.data.isNotEmpty) {
        print(
          "[NewsFeedController] ✅ Response has ${response.data.length} posts",
        );

        // Cập nhật lastModifiedDate với post mới nhất
        final latestPost = response.data.first;
        lastModifiedDate = latestPost.publishDate;

        // Nếu là refresh HOẶC feedPosts đang rỗng, thay thế toàn bộ danh sách
        if (isRefresh || feedPosts.isEmpty) {
          print(
            "[NewsFeedController] 📝 Assigning all ${response.data.length} posts to feedPosts",
          );
          print(
            "[NewsFeedController] Before: feedPosts.length = ${feedPosts.length}",
          );

          // Clear trước để đảm bảo clean state
          feedPosts.clear();
          print(
            "[NewsFeedController] After clear: feedPosts.length = ${feedPosts.length}",
          );

          // Đảm bảo response.data không rỗng trước khi gán
          if (response.data.isNotEmpty) {
            print(
              "[NewsFeedController] 📝 Preparing to assign ${response.data.length} posts...",
            );

            // QUAN TRỌNG: Clear trước, sau đó assignAll
            // assignAll trong GetX sẽ tự động trigger reactive update
            feedPosts.clear();

            // Sử dụng addAll trước để đảm bảo dữ liệu được thêm vào
            feedPosts.addAll(response.data);

            // Sau đó assignAll để trigger reactive update
            feedPosts.assignAll(response.data);

            print(
              "[NewsFeedController] ✅ After assignAll: feedPosts.length = ${feedPosts.length}",
            );
            print(
              "[NewsFeedController] ✅ feedPosts.isEmpty = ${feedPosts.isEmpty}",
            );
            print(
              "[NewsFeedController] ✅ Expected length: ${response.data.length}",
            );

            // Verify dữ liệu đã được gán
            if (feedPosts.length != response.data.length) {
              print(
                "[NewsFeedController] ⚠️ WARNING: feedPosts.length (${feedPosts.length}) != response.data.length (${response.data.length})",
              );
              // Thử gán lại bằng cách khác - clear và add từng cái
              feedPosts.clear();
              for (var post in response.data) {
                try {
                  feedPosts.add(post);
                } catch (e) {
                  print("[NewsFeedController] Error adding post: $e");
                }
              }
              print(
                "[NewsFeedController] Retry with loop add: feedPosts.length = ${feedPosts.length}",
              );
            }

            // Đợi một chút để đảm bảo dữ liệu đã được gán xong
            await Future.delayed(const Duration(milliseconds: 50));

            print(
              "[NewsFeedController] ✅ After delay: feedPosts.length = ${feedPosts.length}, isEmpty: ${feedPosts.isEmpty}",
            );

            // Force update UI bằng nhiều cách để đảm bảo reactive
            feedPosts.refresh(); // Trigger RxList update
            update(); // Trigger GetX controller update

            // Đợi thêm một chút để UI có thời gian rebuild
            await Future.delayed(const Duration(milliseconds: 50));

            print(
              "[NewsFeedController] ✅ After refresh() and update(): feedPosts.length = ${feedPosts.length}",
            );
            print("[NewsFeedController] ✅✅✅ DATA ASSIGNED SUCCESSFULLY ✅✅✅");
          } else {
            print(
              "[NewsFeedController] ⚠️ response.data is empty, cannot assign",
            );
          }
        } else {
          // Merge: thêm posts mới vào đầu danh sách, loại bỏ duplicate
          final existingIds = feedPosts.map((p) => p.postId).toSet();
          final newPosts = response.data
              .where((p) => !existingIds.contains(p.postId))
              .toList();
          print(
            "[NewsFeedController] Merging ${newPosts.length} new posts (${response.data.length - newPosts.length} duplicates skipped)",
          );
          if (newPosts.isNotEmpty) {
            feedPosts.insertAll(0, newPosts);
            // Sắp xếp theo publishDate mới nhất
            feedPosts.sort((a, b) => b.publishDate.compareTo(a.publishDate));
            feedPosts.refresh();
          }
        }
      } else {
        print(
          "[NewsFeedController] ⚠️ WARNING: API returned empty data array!",
        );
        print(
          "[NewsFeedController] Response success: ${response.success}, code: ${response.code}",
        );
        // Nếu là refresh và không có dữ liệu mới, giữ nguyên dữ liệu cũ
        // Nếu là load lần đầu và không có dữ liệu, để feedPosts rỗng
        if (isRefresh && feedPosts.isNotEmpty) {
          print(
            "[NewsFeedController] Refresh returned empty, keeping existing ${feedPosts.length} posts",
          );
        } else if (!isRefresh) {
          print(
            "[NewsFeedController] Initial load returned empty, clearing feedPosts",
          );
          feedPosts.clear();
          feedPosts.refresh();
        }
      }

      // Đợi một chút để đảm bảo tất cả operations đã hoàn thành
      await Future.delayed(const Duration(milliseconds: 50));

      print(
        "[NewsFeedController] 📊 Final feedPosts.length = ${feedPosts.length}",
      );
      print("[NewsFeedController] 📊 feedPosts.isEmpty = ${feedPosts.isEmpty}");

      // Debug: In ra một vài post đầu tiên
      if (feedPosts.isNotEmpty) {
        print(
          "[NewsFeedController] ✅✅✅ SUCCESS: feedPosts has ${feedPosts.length} posts ✅✅✅",
        );
        print("[NewsFeedController] First post ID: ${feedPosts.first.postId}");
        print(
          "[NewsFeedController] First post Author: ${feedPosts.first.authorName}",
        );
        print(
          "[NewsFeedController] First post Title: ${feedPosts.first.title ?? 'No title'}",
        );
        print("[NewsFeedController] Last modified date: $lastModifiedDate");

        // Force UI update - GetX sẽ tự động update khi RxList thay đổi
        // Nhưng để chắc chắn, trigger một update bằng nhiều cách
        feedPosts.refresh();
        update(); // Trigger GetX update
        print(
          "[NewsFeedController] ✅ UI should update now with ${feedPosts.length} posts",
        );
      } else {
        print(
          "[NewsFeedController] ❌❌❌ ERROR: feedPosts is empty after parsing! ❌❌❌",
        );
        print(
          "[NewsFeedController] Response had ${response.data.length} posts",
        );
        print(
          "[NewsFeedController] Response success: ${response.success}, code: ${response.code}",
        );

        // Nếu response có data nhưng feedPosts rỗng, có thể là lỗi parse
        if (response.data.isNotEmpty) {
          print(
            "[NewsFeedController] ⚠️ CRITICAL: Response has ${response.data.length} posts but feedPosts is empty!",
          );
          print(
            "[NewsFeedController] This suggests ALL posts failed to parse or assignAll failed",
          );

          // Thử gán lại bằng cách khác
          print(
            "[NewsFeedController] Attempting to assign posts one by one...",
          );
          feedPosts.clear();
          for (var post in response.data) {
            try {
              feedPosts.add(post);
              print("[NewsFeedController] Added post ID: ${post.postId}");
            } catch (e) {
              print("[NewsFeedController] Failed to add post: $e");
            }
          }
          print(
            "[NewsFeedController] After manual add: feedPosts.length = ${feedPosts.length}",
          );

          if (feedPosts.isNotEmpty) {
            feedPosts.refresh();
            print(
              "[NewsFeedController] ✅ Successfully added ${feedPosts.length} posts manually",
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print("[NewsFeedController] Error: $e");
      print("[NewsFeedController] Stack trace: $stackTrace");
      if (isRefresh) {
        // Nếu refresh lỗi, giữ nguyên dữ liệu cũ
      } else {
        feedPosts.clear(); // Clear để tránh hiển thị dữ liệu cũ
      }
    } finally {
      isLoading(false);
      isRefreshing(false);
      print("[NewsFeedController] isLoading set to false");
    }
  }

  // === LIKE (optimistic update) ===
  void toggleLike(int index) {
    if (index < 0 || index >= feedPosts.length) return;

    // Đây là bản đơn giản: tăng/giảm dựa trên SelfLike (tuỳ backend)
    // TODO: Implement actual like API call and update UI accordingly
    try {
      // Logic like sẽ được implement sau khi có API
      print("[NewsFeedController] Toggle like for post at index $index");
    } catch (_) {}
  }

  // Hàm debug để kiểm tra trạng thái
  void debugStatus() {
    print("=== NewsFeedController Debug Status ===");
    print("feedPosts.length: ${feedPosts.length}");
    print("feedPosts.isEmpty: ${feedPosts.isEmpty}");
    print("isLoading: ${isLoading.value}");
    print("isRefreshing: ${isRefreshing.value}");
    print("_hasInitialLoad: $_hasInitialLoad");
    print("_isLoadingInProgress: $_isLoadingInProgress");
    if (feedPosts.isNotEmpty) {
      print("First post ID: ${feedPosts.first.postId}");
      print("First post Author: ${feedPosts.first.authorName}");
    }
    print("=======================================");
  }
}

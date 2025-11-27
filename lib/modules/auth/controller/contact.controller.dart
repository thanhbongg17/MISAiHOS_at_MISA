import 'package:get/get.dart';
import '../../../data/models/contact/contact.model.dart';
import '../../../data/services/contact/contact.service.dart';
import '../../../data/models/contact/user.detail.model.dart';
import '../../../data/services/contact/user.detail.service.dart';
import '../../../data/models/contact/derpartment.model.dart';
import '../../../data/services/contact/derpartment.service.dart';
class ContactController extends GetxController{
  // Service 1: Lấy danh sách (Có sẵn)
  final ContactService contactService ;//API3
  // Service 2: Lấy thông tin Header (Mới thêm)
  // Khởi tạo trực tiếp (Hoặc inject qua constructor nếu bạn rành Binding)
  final UserDetailService userDetailService = UserDetailService();//API1
  final DepartmentService departmentService = DepartmentService(); //API2

  //Nhận Service khi khởi tạo
  ContactController({
    required this.contactService,
    //required this.userDetailService, // Thêm dòng này
  });
  // --- 2. CÁC BIẾN STATE (OBS) ---
  final RxList<ContactUser> users = <ContactUser>[].obs;
  //API1
  final RxString hospitalName = 'Đang tải...'.obs;
  final RxString budgetCode = ''.obs; // 20020008.13
  //loading err
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  // THÊM BIẾN NÀY ĐỂ LƯU KẾT QUẢ TÌM KIẾM PHÒNG BAN
  final RxList<DepartmentModel> filteredDepartments = <DepartmentModel>[].obs;
  final RxString departmentSearchQuery = ''.obs; // Từ khóa tìm kiếm phòng ban
  // Data Phòng ban (API 2)
  List<DepartmentModel> _fullDepartmentList = []; // Lưu cache toàn bộ phòng ban
  String? currentDepartmentId; // ID phòng ban đang chọn (để lọc API 3)

  @override
  void onInit() {
    super.onInit();
    // Logic tìm kiếm (Debounce)
    debounce(_searchQuery, (query) {
      // Gọi fetchUsers chỉ khi đã hết thời gian debounce
      if (!isLoading.value) {
        fetchUsers(query: query);
      }
    }, time: const Duration(milliseconds: 500));
    initData();
  }
  // --- HÀM TỔNG HỢP: GỌI API LÚC KHỞI TẠO ---
  void initData() async {
    isLoading.value = true;

    // Bước 1: Gọi song song API 1 (User) và API 2 (Phòng ban) cho nhanh
    await Future.wait([
      fetchUserDetail(),
      fetchDepartments(),
    ]);

    // Bước 2: Sau khi có phòng ban/user rồi thì mới load danh sách nhân viên
    fetchUsers();

    isLoading.value = false;
  }
// Hàm gọi API 1 (Dùng userDetailService)
  Future<void> fetchUserDetail() async {
    try {
      // 👇 Gọi hàm từ file service mới tạo
      UserDetailModel? userDetail = await userDetailService.getUserDetail();

      if (userDetail != null) {
        hospitalName.value = userDetail.organizationName ?? "Đơn vị không xác định";
        budgetCode.value = userDetail.budgetCode ?? "";
      }
    } catch (e) {
      print("Lỗi API Header: $e");
      hospitalName.value = "Bệnh viện đa khoa tỉnh Misa"; // Fallback
    }
  }
  //thêm gọi API2 vào đây
  // --- XỬ LÝ API 2: LẤY DANH SÁCH PHÒNG BAN ---
  Future<void> fetchDepartments() async {
    try {
      // Gọi Service lấy list về và lưu vào biến local
      _fullDepartmentList = await departmentService.getListDepartments();
      print("Đã tải xong ${_fullDepartmentList.length} phòng ban.");
    } catch (e) {
      print("Lỗi API Phòng ban: $e");
    }
  }
  // Phương thức tải dữ liệu API3
  Future<void> fetchUsers({String? query}) async {
    if (query == null || query.isEmpty) isLoading.value = true;

    errorMessage.value = '';
    try {
      // Gọi API
      List<ContactUser> result = await contactService.fetchContactUsers(
          query: query,
          departmentID: currentDepartmentId
      );

      // 👇 THUẬT TOÁN SẮP XẾP (Đã Fix lỗi Null và Result)
      if (query != null && query.isNotEmpty) {
        // Fix lỗi 1: Xử lý null an toàn
        final lowerQuery = (query ?? "").toLowerCase().trim();

        // Fix lỗi 2: Biến result nằm trong scope này nên gọi được
        result.sort((a, b) {
          int scoreA = _calculateRelevance(a, lowerQuery);
          int scoreB = _calculateRelevance(b, lowerQuery);
          return scoreB.compareTo(scoreA);
        });
      }

      users.assignAll(result);

    } catch (e) {
      errorMessage.value = 'Không thể tải danh bạ. Lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }
  // Hàm chấm điểm độ tương thích (Relevance Score)
  int _calculateRelevance(ContactUser user, String query) {
    int score = 0;
    String name = (user.fullName ?? "").toLowerCase();
    //String job = (user.jobTitleName ?? "").toLowerCase(); // Chức vụ
    String phone = (user.mobilePhone ?? "").toLowerCase();

    // 1. Ưu tiên CHỨC VỤ (Tìm "Giám đốc" -> Chức vụ Giám đốc lên đầu)
    //if (job.contains(query)) score += 100;

    // 2. Ưu tiên TÊN bắt đầu bằng từ khóa (Tìm "Tùng" -> "Tùng Lâm" xếp trên "Sơn Tùng")
    if (name.startsWith(query)) score += 50;
    // Tên chứa từ khóa
    else if (name.contains(query)) score += 100;

    // 3. Ưu tiên SỐ ĐIỆN THOẠI
    if (phone.contains(query)) score += 80;

    return score;
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }
  //THÊM HÀM NÀY: Logic tìm kiếm phòng ban (Client-side)
  void searchDepartments(String query) {
    departmentSearchQuery.value = query;

    if (query.isEmpty) {
      filteredDepartments.clear(); // Nếu rỗng thì xóa list tìm kiếm (để hiện cây mặc định)
      return;
    }

    // Lọc trong _fullDepartmentList (danh sách gốc đã tải từ API 2)
    // Tìm theo Tên hoặc Mã phòng ban, không phân biệt hoa thường
    final lowerQuery = query.toLowerCase().trim();
    final result = _fullDepartmentList.where((dept) {
      final name = (dept.departmentName ).toLowerCase();
      final code = (dept.departmentCode ).toLowerCase();
      return name.contains(lowerQuery) || code.contains(lowerQuery);
    }).toList();

    filteredDepartments.assignAll(result);
  }
  // 1. Lấy danh sách con của 1 ID (Để vẽ list đệ quy)
  List<DepartmentModel> getChildren(String? parentId) {
    if (parentId == null) {
      // Nếu parentId null -> Tìm Root (Bệnh viện)
      return _fullDepartmentList.where((e) => e.parentID == null).toList();
    }
    // Tìm các node con có ParentID trùng với ID truyền vào
    return _fullDepartmentList.where((e) => e.parentID == parentId).toList();
  }

  // 2. Lấy Node Gốc (Để bắt đầu mở màn hình)
  DepartmentModel? getRootNode() {
    // Tìm phần tử đầu tiên không có cha (Root)
    return _fullDepartmentList.firstWhereOrNull((e) => e.parentID == null);
  }

  // 3. Xử lý khi người dùng CHỌN xong 1 phòng ban
  void onDepartmentSelected(DepartmentModel selectedDept) {
    // Cập nhật Header
    hospitalName.value = selectedDept.departmentName;
    budgetCode.value = selectedDept.departmentCode; // Cập nhật mã hiển thị

    // Cập nhật ID lọc
    currentDepartmentId = selectedDept.departmentID;
    _searchQuery.value = '';

    // Load lại API 3 theo ID mới
    print("🔄 Đang tải nhân viên của phòng: ${selectedDept.departmentName} (ID: $currentDepartmentId)");
    fetchUsers();
  }
}
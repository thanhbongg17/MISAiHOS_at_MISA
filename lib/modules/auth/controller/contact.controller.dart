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
  // 👇 Khởi tạo trực tiếp (Hoặc inject qua constructor nếu bạn rành Binding)
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
    if (query == null || query.isEmpty || query.length >= 2) {
      isLoading.value = true;
      errorMessage.value = '';
      try {
        // Gọi phương thức trên instance 'contactService'
        final List<ContactUser> result =
        await contactService.fetchContactUsers(query: query);

        users.assignAll(result);
      } catch (e) {
        errorMessage.value = 'Không thể tải danh bạ. Vui lòng kiểm tra kết nối.';
      } finally {
        isLoading.value = false;
      }
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query.trim();
  }
  // ==========================================================
  // LOGIC CÂY THƯ MỤC (Dùng cho màn hình chọn phòng ban)
  // ==========================================================

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

    // Load lại API 3 theo ID mới
    fetchUsers();

    print("Đã chuyển sang xem: ${selectedDept.departmentName}");
  }
}
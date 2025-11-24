import 'package:get/get.dart';
import '../../../data/models/contact/contact.model.dart';
import '../../../data/services/contact/contact.service.dart';
class ContactController extends GetxController{
  // truyen Service conf controller
  final ContactService contactService ;
  //Nhận Service khi khởi tạo
  ContactController({required this.contactService});

  final RxList<ContactUser> users = <ContactUser>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString hospitalName = 'Bệnh viện đa khoa tỉnh Misa'.obs;

  final RxString _searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Vẫn sử dụng debounce cho _searchQuery
    debounce(_searchQuery, (query) {
      // Gọi fetchUsers chỉ khi đã hết thời gian debounce
      if (!isLoading.value) {
        fetchUsers(query: query);
      }
    }, time: const Duration(milliseconds: 500));

    fetchUsers();
  }

  // Phương thức tải dữ liệu
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
}
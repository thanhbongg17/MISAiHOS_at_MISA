import 'package:get/get.dart'; // Import GetX
import '../../modules/home/home.page.dart';
import '../../modules/auth/view/login/login.page.dart';
import '../../modules/home/loading.page.dart';

class UserRoutes {
  // Change the type from Map<String, WidgetBuilder> to List<GetPage>
  static final List<GetPage> routes = [
    GetPage(
      name: "/",
      page: () => const LoginPage(),
    ),
    GetPage(
        name:'/loading',
        page:()=> const LoadingPage()),
    GetPage(
      name: "/home",
      page: () => const HomePage(),
    ),
  ];
}

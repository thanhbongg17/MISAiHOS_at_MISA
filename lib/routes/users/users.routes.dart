import 'package:get/get.dart'; // Import GetX
import '../../modules/auth/view/login/otp.two.factor.login.dart';
import '../../modules/home/home.page.dart';
import '../../modules/auth/controller/home.controller.dart' show HomeController;
import '../../modules/auth/view/login/login.page.dart';
import '../../modules/home/loading.page.dart';
import '../../modules/auth/view/dashboard/dashboard.page.dart';
import '../../modules/auth/view/home/home.page.view.dart';

class UserRoutes {
  // Change the type from Map<String, WidgetBuilder> to List<GetPage>
  static final List<GetPage> routes = [
    GetPage(name: "/", page: () => const LoginPage()),
    GetPage(name: "/otp-two-factor", page: () => const TwoFactorAuthScreen()),
    GetPage(name: '/loading', page: () => const LoadingPage()),

    GetPage(
      name: "/maincontent",
      page: () => const MainFeedContent(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: "/home_view",
      page: () => const HomePageView(),
      // Ensure HomeController is created when navigating to /home
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(name: "/report", page: () => const DashboardPage()),
  ];
}

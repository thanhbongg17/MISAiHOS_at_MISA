import 'package:get/get.dart'; // Make sure you import GetX here to recognize GetPage

import 'users/users.routes.dart';
// import 'admin_routes.dart';
// import 'auth_routes.dart';

class AppRoutes {
  // Use square brackets [] for a List
  static final List<GetPage> all = [
    ...UserRoutes.routes,
    // ...AdminRoutes.routes,
    // ...AuthRoutes.routes,
  ];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app.routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MISA iHOS',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: AppRoutes.all, // dùng GetX routing
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
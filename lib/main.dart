import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manage_authentication/src/bindings/initial_binding.dart';
import 'package:manage_authentication/src/controllers/auth_controller.dart';
import 'package:manage_authentication/src/views/home_page.dart';
import 'package:manage_authentication/src/views/login_page.dart';
import 'package:manage_authentication/src/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Token Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: InitialBinding(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => HomePage(),
          binding: HomeBinding(),
        ),
      ],
    );
  }
}
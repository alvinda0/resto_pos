// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/models/routes.dart';
import 'package:pos/controller/auth/auth_controller.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';
import 'package:pos/services/auth_service.dart';
import 'package:pos/services/tables/tables_qr_code_service.dart';
import 'package:pos/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services first
  await initServices();

  runApp(const MyApp());
}

/// Initialize all required services
Future<void> initServices() async {
  // Initialize storage service first
  Get.put(StorageService.instance);

  // Initialize auth service
  Get.put(AuthService.instance);
  Get.lazyPut(() => QrCodeService());

  // Initialize auth controller
  Get.put(AuthController());

  print('All services initialized successfully');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS System',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getPages(), // Call the getPages method here
      home: SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/category/category_controller.dart';
import 'package:pos/models/routes.dart';
import 'package:pos/controller/auth/auth_controller.dart';
import 'package:pos/screens/splash_screen/splash_screen.dart';
import 'package:pos/services/auth_service.dart';
import 'package:pos/services/tables/tables_qr_code_service.dart';
import 'package:pos/storage_service.dart';
import 'package:pos/screens/printer/BluetoothPrinterManager.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services first
  await initServices();

  runApp(const MyApp());
}

/// Initialize all required services
Future<void> initServices() async {
  try {
    // Initialize storage service first
    Get.put(StorageService.instance);

    // Initialize auth service
    Get.put(AuthService.instance);

    // Initialize services with lazy loading to avoid conflicts
    Get.lazyPut(() => QrCodeService());

    // Initialize auth controller
    Get.put(AuthController());
    Get.lazyPut<CategoryController>(() => CategoryController());

    // Initialize Bluetooth Printer Manager untuk auto reconnect
    // This will attempt to reconnect to saved printer if available
    try {
      await BluetoothPrinterManager().initialize();
      print('BluetoothPrinterManager initialized successfully');
    } catch (e) {
      print('BluetoothPrinterManager initialization failed: $e');
      // Don't throw error, let app continue without printer functionality
    }
  } catch (e) {
    print('Service initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RESTOT',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getPages(),
      home: SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

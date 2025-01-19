import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import configuration and services
import 'app/config/app_config.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';
import 'app/controllers/auth_controller.dart';
import 'app/utils/connection_diagnostic.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Perform initial connection diagnostics
  final connectionReport = await ConnectionDiagnostic.getConnectivityReport();
  
  // Initialize GetX services and controllers
  await initializeServices();

  // Run the app
  runApp(MyApp(
    connectionReport: connectionReport,
  ));
}

// Initialize GetX services and controllers
Future<void> initializeServices() async {
  // Register API Service
  Get.put(ApiService(), permanent: true);

  // Register Auth Controller
  Get.put(AuthController(), permanent: true);
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> connectionReport;

  const MyApp({
    super.key, 
    required this.connectionReport
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Book Store',
      
      // Theme Configuration
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Enhanced typography
        textTheme: Typography.material2021().black,
        
        // App-wide transition
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      // Dark theme support
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue[800],
      ),
      
      // Routing Configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // Debug Configuration
      debugShowCheckedModeBanner: false,
      
      // Logging and Error Handling
      builder: (context, child) {
        // Global error handling
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Text(
                'An error occurred: ${details.exception}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        };
        return child!;
      },

      // Localization and Internationalization (placeholder)
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

// Logging utility for development
void _logConnectionDiagnostics(Map<String, dynamic> report) {
  print('Connection Diagnostics Report:');
  report.forEach((key, value) {
    print('$key: $value');
  });
}

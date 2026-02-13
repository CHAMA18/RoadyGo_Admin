import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/firebase_options.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/services/driver_service.dart';
import 'package:roadygo_admin/services/ride_service.dart';
import 'package:roadygo_admin/services/region_service.dart';
import 'package:roadygo_admin/services/schedule_service.dart';
import 'package:roadygo_admin/services/rate_service.dart';
import 'package:roadygo_admin/services/theme_service.dart';
import 'package:roadygo_admin/theme.dart';
import 'package:roadygo_admin/nav.dart';

/// Main entry point for the application
///
/// This sets up:
/// - Firebase initialization
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize default data in Firestore if needed
  await _initializeDefaultData();
  
  runApp(const MyApp());
}

/// Initialize default regions and rates in Firestore if they don't exist
Future<void> _initializeDefaultData() async {
  final regionService = RegionService();
  final rateService = RateService();
  
  // Initialize default regions with pricing
  await regionService.initializeDefaultRegions();
  
  // Initialize default rates
  await rateService.initializeDefaultRates();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DriverService()),
        ChangeNotifierProvider(create: (_) => RideService()),
        ChangeNotifierProvider(create: (_) => RegionService()),
        ChangeNotifierProvider(create: (_) => ScheduleService()),
        ChangeNotifierProvider(create: (_) => RateService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'RoadyGo Admin',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/firebase_options.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
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
  _configureGlobalErrorHandling();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

void _configureGlobalErrorHandling() {
  bool isKnownWebWindowAssertion(Object error) {
    final message = error.toString();
    return message.contains('_engine/engine/window.dart:99:12');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isKnownWebWindowAssertion(details.exception)) {
      debugPrint('Suppressed known Flutter Web window assertion.');
      return;
    }
    FlutterError.presentError(details);
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    if (isKnownWebWindowAssertion(error)) {
      debugPrint('Suppressed known Flutter Web window assertion (platform dispatcher).');
      return true;
    }
    return false;
  };
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
            locale: themeService.currentLocale,
            supportedLocales: themeService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

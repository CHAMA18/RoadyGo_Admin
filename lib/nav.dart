import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/pages/admin_registration_page.dart';
import 'package:roadygo_admin/pages/admin_dashboard_page.dart';
import 'package:roadygo_admin/pages/driver_details_page.dart';
import 'package:roadygo_admin/pages/login_page.dart';
import 'package:roadygo_admin/pages/profile_settings_page.dart';
import 'package:roadygo_admin/pages/edit_rates_page.dart';
import 'package:roadygo_admin/pages/edit_region_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminRegistrationPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.driverDetails,
        name: 'driverDetails',
        pageBuilder: (context, state) {
          final driver = state.extra as DriverModel;
          return NoTransitionPage(
            child: DriverDetailsPage(driver: driver),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        name: 'profileSettings',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfileSettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editRates,
        name: 'editRates',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: EditRatesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editRegion,
        name: 'editRegion',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: EditRegionPage(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String driverDetails = '/driver-details';
  static const String profileSettings = '/profile-settings';
  static const String editRates = '/edit-rates';
  static const String editRegion = '/edit-region';
}

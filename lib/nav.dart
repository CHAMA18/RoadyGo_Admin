import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/pages/admin_registration_page.dart';
import 'package:roadygo_admin/pages/admin_dashboard_page.dart';
import 'package:roadygo_admin/pages/driver_details_page.dart';
import 'package:roadygo_admin/pages/login_page.dart';
import 'package:roadygo_admin/pages/profile_settings_page.dart';
import 'package:roadygo_admin/pages/edit_rates_page.dart';
import 'package:roadygo_admin/pages/edit_region_page.dart';
import 'package:roadygo_admin/pages/personal_information_page.dart';
import 'package:roadygo_admin/pages/security_page.dart';
import 'package:roadygo_admin/pages/credit_management_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const Set<String> _publicRoutes = {
    AppRoutes.home,
    AppRoutes.login,
  };

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isSignedIn = FirebaseAuth.instance.currentUser != null;
      final currentPath = state.uri.path;
      final isPublic = _publicRoutes.contains(currentPath);

      if (!isSignedIn && !isPublic) {
        return AppRoutes.login;
      }

      if (isSignedIn && isPublic) {
        return AppRoutes.dashboard;
      }

      return null;
    },
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
        pageBuilder: (context, state) {
          final extra = state.extra;
          final region = extra is RegionModel ? extra : null;
          return NoTransitionPage(
            child: EditRegionPage(region: region),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.personalInformation,
        name: 'personalInformation',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PersonalInformationPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.security,
        name: 'security',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SecurityPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.creditManagement,
        name: 'creditManagement',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CreditManagementPage(),
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
  static const String personalInformation = '/personal-information';
  static const String security = '/security';
  static const String creditManagement = '/credit-management';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../session/session_provider.dart';
import '../../data/models/models.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/farmer/screens/farmer_dashboard_screen.dart';
import '../../features/chef/screens/chef_dashboard_screen.dart';
import '../../features/consumer/screens/consumer_dashboard_screen.dart';
import '../../features/consumer/screens/consumer_scan_result_screen.dart';
import '../../features/shared/screens/qr_scan_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);
  final fbSignedIn = ref.watch(firebaseSignedInProvider).value ?? false;

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isPublic = path == '/splash' ||
          path == '/onboarding' ||
          path == '/login';
      final isRoleSelect = path == '/role-select';

      // Not signed in to Firebase AND no mock session → public pages only
      if (!fbSignedIn && session == null && !isPublic) return '/login';

      // Firebase signed in but Firestore doc not yet saved → pick role
      if (fbSignedIn && session == null && !isRoleSelect && !isPublic) {
        return '/role-select';
      }

      // Has full session → redirect away from public/role pages
      if (session != null && (isPublic || isRoleSelect)) {
        return switch (session.role) {
          UserRole.farmer => '/farmer',
          UserRole.chef => '/chef',
          UserRole.consumer => '/consumer',
        };
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/role-select', builder: (_, __) => const RoleSelectScreen()),

      // Farmer
      GoRoute(path: '/farmer', builder: (_, __) => const FarmerDashboardScreen()),

      // Chef
      GoRoute(path: '/chef', builder: (_, __) => const ChefDashboardScreen()),

      // Consumer
      GoRoute(path: '/consumer', builder: (_, __) => const ConsumerDashboardScreen()),
      GoRoute(
        path: '/consumer/result/:type/:id',
        builder: (_, state) => ConsumerScanResultScreen(
          targetType: state.pathParameters['type']!,
          targetId: state.pathParameters['id']!,
        ),
      ),

      // Shared QR
      GoRoute(path: '/scan', builder: (_, __) => const QRScanScreen()),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Dependency Injection
import 'core/di/injection_container.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/lounge_owner_provider.dart';
import 'presentation/providers/registration_provider.dart';
import 'presentation/providers/marketplace_provider.dart';
import 'presentation/providers/lounge_staff_provider.dart';
import 'presentation/providers/lounge_booking_provider.dart';
import 'presentation/providers/transport_location_provider.dart';
import 'presentation/providers/driver_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/initial_role_selection_screen.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/staff_otp_registration_screen.dart';
import 'screens/auth/staff_pending_approval_screen.dart';
import 'screens/auth/staff_registered_login_screen.dart';
import 'screens/lounge_owner/lounge_owner_registration_screen.dart';
import 'screens/dashboard/lounge_owner_home_screen.dart';
import 'screens/lounge/lounges_list_screen.dart';
import 'screens/lounge/add_lounge_screen.dart';
import 'screens/booking/bookings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/marketplace/marketplace_products_screen.dart';

// Config
import 'config/theme_config.dart';

// Utils
import 'utils/sms_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print app signature for SMS auto-read setup
  await SmsHelper.printAppSignature();

  // Initialize dependency injection
  final di = InjectionContainer();
  await di.init();

  runApp(MyApp(di: di));
}

class MyApp extends StatelessWidget {
  final InjectionContainer di;

  const MyApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the refactored providers with proper DI
        ChangeNotifierProvider<AuthProvider>.value(value: di.authProvider),
        ChangeNotifierProvider<LoungeOwnerProvider>.value(
          value: di.loungeOwnerProvider,
        ),
        ChangeNotifierProvider<RegistrationProvider>.value(
          value: di.registrationProvider,
        ),
        ChangeNotifierProvider<MarketplaceProvider>.value(
          value: di.marketplaceProvider,
        ),
        ChangeNotifierProvider.value(value: di.roleSelectionProvider),
        ChangeNotifierProvider<LoungeStaffProvider>.value(
          value: di.loungeStaffProvider,
        ),
        ChangeNotifierProvider<LoungeBookingProvider>.value(
          value: di.loungeBookingProvider,
        ),
        ChangeNotifierProvider<TransportLocationProvider>.value(
          value: di.transportLocationProvider,
        ),
        ChangeNotifierProvider<DriverProvider>.value(
          value: di.driverProvider,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Lounge Owner App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case '/role-selection':
                  return MaterialPageRoute(
                    builder: (_) => const InitialRoleSelectionScreen(),
                  );
                case '/phone-input':
                  return MaterialPageRoute(
                    builder: (_) => const PhoneInputScreen(),
                  );
                case '/otp-verification':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => OtpVerificationScreen(
                      phoneNumber: args?['phoneNumber'] as String? ?? '',
                    ),
                  );
                case '/staff-otp-registration':
                  return MaterialPageRoute(
                    builder: (_) => const StaffOtpRegistrationScreen(),
                  );
                case '/staff-pending-approval':
                  return MaterialPageRoute(
                    builder: (_) => const StaffPendingApprovalScreen(),
                  );
                case '/staff-registered-login':
                  return MaterialPageRoute(
                    builder: (_) => const StaffRegisteredLoginScreen(),
                  );
                case '/lounge-owner-registration':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => LoungeOwnerRegistrationScreen(
                      userId: args?['userId'] as String? ?? '',
                    ),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const LoungeOwnerHomeScreen(),
                  );
                case '/lounges':
                  return MaterialPageRoute(
                    builder: (_) => const LoungesListScreen(),
                  );
                case '/add-lounge':
                  return MaterialPageRoute(
                    builder: (_) => const AddLoungeScreen(),
                  );
                case '/bookings':
                  return MaterialPageRoute(
                    builder: (_) => const BookingsScreen(),
                  );
                case '/profile':
                  return MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  );
                case '/edit-profile':
                  return MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  );
                case '/marketplace':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => MarketplaceProductsScreen(
                      loungeId: args?['loungeId'] as String? ?? '',
                      loungeName:
                          args?['loungeName'] as String? ?? 'Marketplace',
                    ),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}

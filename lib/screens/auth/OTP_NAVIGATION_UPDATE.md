// OTP Verification Screen - Updated navigation logic
// After successful OTP verification, navigate to role selection instead of directly to dashboard

// Add this import at the top of otp_verification_screen.dart:
// import 'role_selection_screen.dart';

// Replace the navigation after successful OTP verification with:
/*
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const RoleSelectionScreen(),
  ),
);
*/

// Previous navigation was:
// Navigator.pushReplacementNamed(context, '/dashboard');
// or Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoungeOwnerHomeScreen()));

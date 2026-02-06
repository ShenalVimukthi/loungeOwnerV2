// filepath: d:\lounge_app\lounge-owner-app\lib\screens\auth\auth_navigation_helper.dart

import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

/// Helper class for authentication navigation
/// Use this after successful OTP verification
class AuthNavigationHelper {
  /// Navigate to role selection screen after OTP verification success
  static void navigateToRoleSelection(BuildContext context, String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionScreen(userId: userId)),
    );
  }

  /// Alternative: Navigate using named route
  static void navigateToRoleSelectionNamed(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/role-selection');
  }
}

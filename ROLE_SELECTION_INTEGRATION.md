# Role Selection Integration Guide

## Files Created

1. **lib/screens/auth/role_selection_screen.dart**
   - Beautiful role selection UI with Admin and Staff Member options
   - Uses app theme (AppColors.primary)
   - Navigates to appropriate dashboard based on selection

2. **lib/screens/staff/staff_dashboard_screen.dart**
   - Staff member dashboard with modern UI
   - Quick actions, stats, and recent activity
   - Uses CustomBottomNavBar for consistency

3. **lib/screens/auth/auth_navigation_helper.dart**
   - Helper class for navigation after OTP verification
   - Makes integration easier

## Integration Steps

### Step 1: Update OTP Verification Screen

In your `otp_verification_screen.dart`, find the navigation code after successful OTP verification.

**Add this import at the top:**
```dart
import 'role_selection_screen.dart';
// or use the helper:
import 'auth_navigation_helper.dart';
```

**Replace the navigation after successful OTP verification:**

**Option 1: Direct Navigation (Recommended)**
```dart
// After successful OTP verification
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const RoleSelectionScreen(),
  ),
);
```

**Option 2: Using Helper**
```dart
// After successful OTP verification
AuthNavigationHelper.navigateToRoleSelection(context);
```

**Look for code similar to this and replace it:**
```dart
// OLD CODE - Remove this:
Navigator.pushReplacementNamed(context, '/dashboard');
// or
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoungeOwnerHomeScreen()),
);

// NEW CODE - Replace with this:
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const RoleSelectionScreen(),
  ),
);
```

### Step 2: Update main.dart Routes (Optional - if using named routes)

If you're using named routes in main.dart, add:

```dart
import 'screens/auth/role_selection_screen.dart';
import 'screens/staff/staff_dashboard_screen.dart';

// In your routes map:
routes: {
  '/role-selection': (context) => const RoleSelectionScreen(),
  '/staff-dashboard': (context) => const StaffDashboardScreen(),
  // ... other routes
},
```

### Step 3: Test the Flow

1. Open app → Enter phone number
2. Receive SMS OTP → Enter OTP
3. After verification → See Role Selection Screen
4. Select Admin → Navigate to LoungeOwnerHomeScreen
5. Select Staff Member → Navigate to StaffDashboardScreen

## Navigation Flow

```
App Start
   ↓
Phone Input Screen
   ↓
OTP Verification Screen
   ↓
✨ Role Selection Screen ✨ (NEW)
   ↓
   ├── Admin → Lounge Owner Home Screen (existing)
   └── Staff Member → Staff Dashboard Screen (new)
```

## Features

### Role Selection Screen
- ✅ Modern, beautiful UI
- ✅ Two role cards (Admin & Staff Member)
- ✅ Uses AppColors.primary theme
- ✅ Smooth navigation with pushReplacement
- ✅ Icons and descriptions for each role

### Staff Dashboard Screen
- ✅ Welcome card with gradient
- ✅ Today's stats (Orders & Bookings)
- ✅ Quick actions grid (placeholder features)
- ✅ Recent activity list
- ✅ CustomBottomNavBar integration
- ✅ Consistent with app theme

## Customization

### Change Role Colors
In `role_selection_screen.dart`:
```dart
_buildRoleCard(
  // ...
  color: AppColors.primary, // Admin color
  // or
  color: Colors.blue.shade600, // Staff color
);
```

### Add More Roles
Add additional `_buildRoleCard()` calls in the role selection screen.

### Customize Staff Dashboard
Edit `staff_dashboard_screen.dart` to add actual functionality:
- Replace placeholder actions with real navigation
- Connect to actual data sources
- Add more features as needed

## Notes

- ✅ OTP verification logic is NOT modified
- ✅ Admin dashboard (LoungeOwnerHomeScreen) is NOT modified
- ✅ All new screens use existing app theme
- ✅ Navigation uses pushReplacement to prevent back navigation
- ✅ Staff dashboard is ready for future feature implementation

## Troubleshooting

**If role selection doesn't show:**
- Check OTP verification screen navigation code
- Ensure import statement is added
- Verify successful OTP verification triggers navigation

**If theme colors look wrong:**
- Check that theme_config.dart exports AppColors
- Ensure AppColors.primary is defined

**If navigation fails:**
- Check that all imports are correct
- Verify file paths match your project structure

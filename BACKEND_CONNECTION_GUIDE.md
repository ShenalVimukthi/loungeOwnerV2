# Backend Connection Guide

## Connection Timeout Error - Solutions

### Issue
The app is showing "Connection timeout" when trying to add staff members. This happens because the local backend server is not accessible.

### Current Configuration
- **Local Backend URL**: `http://10.0.2.2:8080` (for Android Emulator)
- **Timeout**: 30 seconds (increased from 10)
- **API Endpoint**: `/api/v1/lounges/{loungeId}/staff`

### Solutions

#### Option 1: Start Your Local Backend Server (Recommended)

1. **Check if backend is running:**
   ```bash
   # Test the connection
   curl http://localhost:8080/api/v1/lounges
   ```

2. **Start your backend server** (if not running):
   ```bash
   # Navigate to your backend project directory
   cd path/to/your/backend/project
   
   # Start the server (example commands)
   npm start
   # or
   python manage.py runserver 8080
   # or
   java -jar your-backend.jar
   ```

3. **Verify it's accessible:**
   - Open browser: `http://localhost:8080`
   - Should see API response or documentation

#### Option 2: Use Physical Device Instead of Emulator

If testing on a **physical device**, update the URL in `lib/config/api_config.dart`:

```dart
// Find your computer's local IP address:
// Windows: ipconfig (look for IPv4 Address)
// Mac/Linux: ifconfig or ip addr

// Replace with your IP:
static const String localBaseUrl = 'http://192.168.1.XXX:8080';
```

#### Option 3: Use Production/Staging Backend

If you have a deployed backend, update `lib/config/api_config.dart`:

```dart
static const String localBaseUrl = 'https://your-backend-url.com';
```

#### Option 4: iOS Simulator Configuration

If using **iOS Simulator**, update in `lib/config/api_config.dart`:

```dart
// Uncomment this line:
static const String localBaseUrl = 'http://localhost:8080';

// Comment out the Android emulator line
// static const String localBaseUrl = 'http://10.0.2.2:8080';
```

### Testing the Connection

After starting your backend, test in your Flutter app:

1. Hot restart the app (not just hot reload)
2. Try adding a staff member again
3. Check the console logs for connection details

### Debug Logs

When the error occurs, check the console for these logs:
- `📤 [LOCAL] Adding staff to lounge: ...`
- `📤 [LOCAL] URL: ...`
- `❌ DioException: ...`

This will tell you the exact URL being called and the error type.

### Common Issues

1. **Backend not running** → Start your backend server
2. **Wrong IP address** → Verify with `ipconfig` or `ifconfig`
3. **Firewall blocking** → Allow port 8080 in firewall
4. **Backend on different port** → Update port number in config

### API Endpoints Required

Your backend needs these endpoints:
- `POST /api/v1/lounges/{loungeId}/staff` - Add staff
- Headers: `Authorization: Bearer {token}`
- Body:
  ```json
  {
    "lounge_id": "string",
    "full_name": "string",
    "nic_number": "string",
    "phone": "string",
    "email": "string",
    "hired_date": "2026-02-05T00:00:00.000Z"
  }
  ```

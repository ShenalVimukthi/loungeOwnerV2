# Galaxy A07 APK + Local Backend Test Guide (No Developer Options)

Test the lounge staff QR scanner on your **Samsung Galaxy A07** without USB debugging / developer options.

---

## 1) What this covers

✅ Build APK on Mac  
✅ Install APK manually (no ADB/developer options needed)  
✅ Connect to local backend over Wi‑Fi (LAN IP)  
✅ Test QR camera scan flow (reference extraction + backend lookup)

❌ Cannot use: `flutter run`, ADB, hot reload, logcat

---

## 2) Networking setup for real phone

Unlike emulator (which uses `10.0.2.2`), a **real phone needs your Mac's LAN IP**.

### Find your Mac LAN IP

```bash
ipconfig getifaddr en0
```

If empty (Ethernet), try:

```bash
ipconfig getifaddr en1
```

Example output: `192.168.1.25`

### Update app config

Edit `lib/config/api_config.dart`:

```dart
static const String localBaseUrl = 'http://192.168.1.25:8080';  // Your Mac IP
```

---

## 3) Prepare backend

Backend must bind to all interfaces (not localhost only):

```
Good:  0.0.0.0:8080
Bad:   127.0.0.1:8080
```

Verify on Mac:

```bash
lsof -i :8080
```

**Important:** Phone and Mac must be on the **same Wi‑Fi network**.

---

## 4) Build APK

```bash
cd /Users/vimukthifernando/Desktop/frontend/lounge_test

flutter clean
flutter pub get
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

(Use `--debug` for faster iteration.)

---

## 5) Install APK on Galaxy A07

### Option A: Send via WhatsApp/Email/Telegram

1. Send `app-release.apk` to yourself
2. Download on phone
3. Tap APK
4. Enable **Install unknown apps** if blocked (Files/Chrome settings)
5. Install

### Option B: Google Drive

1. Upload APK
2. Download on phone
3. Tap to install

### Option C: USB cable (MTP transfer)

1. Connect phone to Mac
2. Copy APK to Downloads
3. Open Files app → tap APK

---

## 6) Verify connection to backend

Open any API screen (login/bookings):

- If fails: check IP in `api_config.dart`, backend on `0.0.0.0`, same Wi‑Fi
- Browser test: open `http://192.168.1.25:8080` from phone → should load

---

## 7) QR Scanner endpoint & reference format

**Staff Dashboard → QR Scanner**

### Backend endpoint:

```
GET /api/v1/lounge-bookings/reference/{reference}
```

Example: `LNG-b7336f` → `/api/v1/lounge-bookings/reference/LNG-b7336f`

### Reference extraction logic:

- QR can be just: `LNG-b7336f`
- Or a URL: `http://example.com/booking/LNG-b7336f`
- App finds `LNG-xxxxxx` pattern anywhere in QR text
- Invalid format → error: "Expected booking reference like LNG-b7336f"

### Fallback button:

- **"Enter Reference Manually"** if camera fails
- Type reference like `LNG-b7336f`
- Same validation & backend call

---

## 8) Test QR end-to-end

1. Get a valid booking reference from backend DB (example: `LNG-b7336f`)
2. Generate QR code from that text
3. Show QR on another device/screen
4. On Galaxy A07: Staff Dashboard → **QR Scanner**
5. Point camera at QR
6. App shows booking details (guest, phone, lounge, status)

**If camera doesn't work:**

- Check camera permission is granted
- Use "Enter Reference Manually" button
- Set booking reference in input

---

## 9) Troubleshooting

| Issue                   | Check                                                                                             |
| ----------------------- | ------------------------------------------------------------------------------------------------- |
| Connection timeout      | IP in `api_config.dart` correct? Backend on `0.0.0.0:8080`? Same Wi‑Fi?                           |
| APK won't install       | Unknown app installs enabled? Uninstall old app first?                                            |
| Camera won't open       | Permission granted? Try manual entry fallback?                                                    |
| "Booking not found"     | Reference matches DB exactly? Check backend logs for `/api/v1/lounge-bookings/reference/` request |
| Invalid reference error | QR content must include `LNG-` prefix (case-insensitive)                                          |

---

## 10) After testing

Before shipping builds:

- Revert `localBaseUrl` to production backend URL or use environment config
- Example production: `https://api.yourdomain.com`

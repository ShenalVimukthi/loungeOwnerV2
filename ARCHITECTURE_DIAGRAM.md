# 📐 CLEAN ARCHITECTURE - Visual Diagrams

## 🏗️ 3-Layer Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                      📱 PRESENTATION LAYER                          │
│                    (What the user sees)                             │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Screens    │  │   Widgets    │  │   Providers  │             │
│  │              │  │              │  │  (ViewModels)│             │
│  │ - Phone      │  │ - Custom     │  │              │             │
│  │ - OTP        │  │   Button     │  │ - Auth       │             │
│  │ - Register   │  │ - Text Field │  │ - Staff      │             │
│  │ - Home       │  │ - Loading    │  │              │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
│         │                  │                  │                     │
│         └──────────────────┴──────────────────┘                     │
│                            │                                        │
│                    Calls Use Cases                                  │
└────────────────────────────┼────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       🧠 DOMAIN LAYER                               │
│                   (Business Logic - Pure Dart)                      │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Entities   │  │  Use Cases   │  │ Repositories │             │
│  │              │  │              │  │  (Interfaces)│             │
│  │ - User       │  │ - SendOTP    │  │              │             │
│  │ - Staff      │  │ - VerifyOTP  │  │ - Auth       │             │
│  │ - Tokens     │  │ - Register   │  │ - Staff      │             │
│  │              │  │ - Logout     │  │              │             │
│  └──────────────┘  └──────┬───────┘  └──────┬───────┘             │
│                            │                  │                     │
│                            │        Implements│                     │
└────────────────────────────┼──────────────────┼─────────────────────┘
                             │                  │
                             ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        💾 DATA LAYER                                │
│                   (How we get/store data)                           │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │    Models    │  │ Repositories │  │ Data Sources │             │
│  │              │  │     (Impl)   │  │              │             │
│  │ - UserModel  │  │              │  │ - Remote     │             │
│  │ - StaffModel │  │ - Auth Impl  │  │   (API)      │             │
│  │ - TokenModel │  │ - Staff Impl │  │ - Local      │             │
│  │              │  │              │  │   (Storage)  │             │
│  └──────────────┘  └──────┬───────┘  └──────┬───────┘             │
│                            │                  │                     │
└────────────────────────────┼──────────────────┼─────────────────────┘
                             │                  │
                             ▼                  ▼
                    ┌─────────────────┐ ┌──────────────┐
                    │   Backend API   │ │    Secure    │
                    │   (Dio/HTTP)    │ │   Storage    │
                    │  10.0.2.2:8080  │ │  (Flutter)   │
                    └─────────────────┘ └──────────────┘
```

---

## 🔄 DATA FLOW: User Verifies OTP

### Step-by-Step Flow:

```
1️⃣ USER ACTION
   User enters OTP: "123456"
   Taps "Verify" button

   ↓

2️⃣ PRESENTATION LAYER
   📱 OtpVerificationScreen
   └─> Calls: Provider.verifyOtp("0771234567", "123456")

   ↓

3️⃣ PRESENTATION LAYER (Provider)
   🎨 AuthProvider.verifyOtp()
   ├─> Sets: _isLoading = true
   ├─> Calls: VerifyOtpUseCase(phone: "...", otp: "...")
   └─> Awaits result...

   ↓

4️⃣ DOMAIN LAYER (Use Case)
   🧠 VerifyOtpUseCase.call()
   ├─> Validates: phone.isNotEmpty ✅
   ├─> Validates: otp.length == 6 ✅
   ├─> Calls: AuthRepository.verifyOtp(...)
   └─> Awaits result...

   ↓

5️⃣ DATA LAYER (Repository)
   💾 AuthRepositoryImpl.verifyOtp()
   ├─> Calls: remoteDataSource.verifyOtp(...)
   └─> Awaits result...

   ↓

6️⃣ DATA LAYER (Remote Data Source)
   🌐 AuthRemoteDataSource.verifyOtp()
   ├─> POST /api/v1/auth/verify-otp-staff
   ├─> Body: {"phone_number": "0771234567", "otp": "123456"}
   └─> Awaits response...

   ↓

7️⃣ BACKEND RESPONDS
   ✅ 200 OK
   {
     "access_token": "eyJhbGc...",
     "refresh_token": "eyJhbGc...",
     "roles": ["driver"],
     "is_new_user": false
   }

   ↓

8️⃣ DATA LAYER (Remote Data Source)
   🌐 AuthRemoteDataSource
   ├─> Parses JSON
   ├─> Creates AuthTokensModel
   ├─> Fetches User Profile (GET /api/v1/user/profile)
   └─> Returns AuthRemoteResult(user, tokens, roles)

   ↓

9️⃣ DATA LAYER (Repository)
   💾 AuthRepositoryImpl
   ├─> Calls: localDataSource.saveTokens(tokens)
   ├─> Calls: localDataSource.saveUser(user)
   ├─> Converts to domain entities
   └─> Returns: Either.right(AuthResult(...))

   ↓

🔟 DOMAIN LAYER (Use Case)
   �� VerifyOtpUseCase
   ├─> Receives: Either.right(AuthResult)
   ├─> Checks business rule: user.isPassenger? ❌
   ├─> Determines next route based on roles
   └─> Returns: Either.right(VerifyOtpResult(...))

   ↓

1️⃣1️⃣ PRESENTATION LAYER (Provider)
   🎨 AuthProvider
   ├─> Receives: Either.right(...)
   ├─> Sets: _isAuthenticated = true
   ├─> Sets: _isLoading = false
   ├─> Calls: notifyListeners()
   └─> Returns: {'success': true, 'nextRoute': 'check-staff'}

   ↓

1️⃣2️⃣ PRESENTATION LAYER (Screen)
   📱 OtpVerificationScreen
   ├─> Receives result
   ├─> Navigates to next screen
   └─> User sees home screen!
```

---

## 🎯 DEPENDENCY FLOW

### Dependency Rule: **Dependencies point INWARD only**

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│                                                          │
│  Dependencies: ✅ Domain, ❌ Data                        │
│  Can import: domain/entities, domain/usecases           │
│  Cannot import: data/models, data/datasources           │
└───────────────────────┬─────────────────────────────────┘
                        │
                    depends on
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│                                                          │
│  Dependencies: NONE (Pure Dart)                          │
│  Can import: NOTHING (independent)                       │
│  Cannot import: Flutter, Dio, any framework             │
└───────────────────────▲─────────────────────────────────┘
                        │
                   implements
                        │
┌───────────────────────┴─────────────────────────────────┐
│                     DATA LAYER                           │
│                                                          │
│  Dependencies: ✅ Domain, ✅ Frameworks                  │
│  Can import: domain/repositories (interfaces)           │
│  Can import: Dio, FlutterSecureStorage, etc.            │
└─────────────────────────────────────────────────────────┘
```

---

## 🔌 DEPENDENCY INJECTION FLOW

### How dependencies are created and injected:

```
App Startup (main_refactored.dart)
│
├─> InjectionContainer.init()
│   │
│   ├─> 1️⃣ Create Core Dependencies
│   │   ├─> Dio(baseUrl, timeouts)
│   │   └─> FlutterSecureStorage()
│   │
│   ├─> 2️⃣ Create Data Sources
│   │   ├─> AuthRemoteDataSource(dio, baseUrl)
│   │   ├─> AuthLocalDataSource(secureStorage)
│   │   └─> StaffRemoteDataSource(dio, baseUrl)
│   │
│   ├─> 3️⃣ Create Repositories
│   │   ├─> AuthRepositoryImpl(
│   │   │       remoteDataSource,
│   │   │       localDataSource
│   │   │   )
│   │   └─> StaffRepositoryImpl(remoteDataSource)
│   │
│   ├─> 4️⃣ Create Use Cases
│   │   ├─> SendOtpUseCase(authRepository)
│   │   ├─> VerifyOtpUseCase(authRepository)
│   │   ├─> RegisterStaffUseCase(staffRepository)
│   │   └─> LogoutUseCase(authRepository)
│   │
│   └─> 5️⃣ Create Providers
│       ├─> AuthProvider(
│       │       sendOtpUseCase,
│       │       verifyOtpUseCase,
│       │       logoutUseCase,
│       │       authRepository
│       │   )
│       └─> StaffProvider(
│               registerStaffUseCase,
│               getStaffProfileUseCase
│           )
│
└─> MultiProvider(
        providers: [
            ChangeNotifierProvider.value(di.authProvider),
            ChangeNotifierProvider.value(di.staffProvider),
        ]
    )
```

---

## 🧩 FILE STRUCTURE MAP

### Complete file organization:

```
lib/
│
├─── 🧠 domain/                         # BUSINESS LOGIC (Pure Dart)
│    ├─── entities/                     # Business models
│    │    ├─── user.dart               # User with business methods
│    │    ├─── staff.dart              # Staff with validation logic
│    │    └─── auth_tokens.dart        # Token with expiry logic
│    │
│    ├─── repositories/                # Contracts (interfaces)
│    │    ├─── auth_repository.dart    # What auth operations exist
│    │    └─── staff_repository.dart   # What staff operations exist
│    │
│    └─── usecases/                    # Business operations
│         ├─── send_otp.dart           # Send OTP business logic
│         ├─── verify_otp.dart         # Verify OTP + passenger check
│         ├─── register_staff.dart     # Staff registration rules
│         ├─── get_staff_profile.dart  # Get profile logic
│         └─── logout.dart             # Logout logic
│
├─── 💾 data/                           # DATA ACCESS
│    ├─── models/                       # JSON serializable models
│    │    ├─── user_model.dart         # User + toJson/fromJson
│    │    ├─── staff_model.dart        # Staff + JSON methods
│    │    └─── auth_tokens_model.dart  # Tokens + JSON methods
│    │
│    ├─── datasources/                 # Where data comes from
│    │    ├─── auth_remote_datasource.dart   # API calls (Dio)
│    │    ├─── auth_local_datasource.dart    # Secure storage
│    │    └─── staff_remote_datasource.dart  # Staff API calls
│    │
│    └─── repositories/                # Repository implementations
│         ├─── auth_repository_impl.dart     # Implements AuthRepository
│         └─── staff_repository_impl.dart    # Implements StaffRepository
│
├─── 🎨 presentation/                   # UI STATE
│    └─── providers/                    # ViewModels
│         ├─── auth_provider.dart      # Auth UI state
│         └─── staff_provider.dart     # Staff UI state
│
├─── ⚙️ core/                            # UTILITIES
│    ├─── error/                        # Error handling
│    │    ├─── failures.dart           # Domain-level errors
│    │    └─── exceptions.dart         # Data-level errors
│    │
│    ├─── di/                           # Dependency Injection
│    │    └─── injection_container.dart # DI setup
│    │
│    └─── (future: network, utils, etc.)
│
└─── main_refactored.dart               # App entry point
```

---

## 🎭 COMPARISON: Before vs After

### Before Refactoring:

```
lib/
├── providers/
│   └── auth_provider.dart        # 254 lines
│       ├── UI state management   # ❌ Mixed
│       ├── Business logic        # ❌ Mixed
│       ├── API calls             # ❌ Mixed
│       └── Data transformation   # ❌ Mixed
│
├── services/
│   └── auth_service.dart         # 200 lines
│       ├── API implementation    # ❌ Tight coupling
│       └── Hard-coded ApiService # ❌ Not testable
│
└── models/
    └── user_model.dart           # ✅ OK
```

**Problems:**
- 🔴 Business logic in Provider
- 🔴 Hard to test (no mocking)
- 🔴 Tight coupling
- 🔴 No clear boundaries

### After Refactoring:

```
lib/
├── domain/
│   ├── entities/user.dart        # ✅ Pure business model
│   ├── repositories/             # ✅ Contracts
│   └── usecases/verify_otp.dart  # ✅ Business logic isolated
│
├── data/
│   ├── models/user_model.dart    # ✅ JSON handling
│   ├── datasources/              # ✅ API isolated
│   └── repositories/             # ✅ Implementation
│
└── presentation/
    └── providers/auth_provider.dart  # ✅ UI state only (170 lines)
```

**Benefits:**
- ✅ Clear separation of concerns
- ✅ Easy to test (mock any layer)
- ✅ Loose coupling (DI)
- ✅ Each file has one responsibility

---

## 🧪 TESTABILITY COMPARISON

### Before: Hard to Test ❌

```dart
test('verify OTP', () {
  final provider = AuthProvider();
  // ❌ Creates real AuthService
  // ❌ Makes real API calls
  // ❌ Can't test business logic in isolation
});
```

### After: Easy to Test ✅

```dart
// Test Use Case (Business Logic)
test('verify OTP blocks passengers', () {
  final mockRepo = MockAuthRepository();
  final useCase = VerifyOtpUseCase(mockRepo);

  // ✅ Test business rule in isolation
  final result = await useCase(phone: '...', otp: '...');
  expect(result.isLeft, true);
});

// Test Repository (Data Access)
test('verify OTP saves tokens', () {
  final mockRemote = MockRemoteDataSource();
  final mockLocal = MockLocalDataSource();
  final repo = AuthRepositoryImpl(
    remoteDataSource: mockRemote,
    localDataSource: mockLocal,
  );

  await repo.verifyOtp(...);

  verify(mockLocal.saveTokens(any)).called(1); // ✅
});

// Test Provider (UI State)
test('verify OTP sets loading', () {
  final mockUseCase = MockVerifyOtpUseCase();
  final provider = AuthProvider(
    verifyOtpUseCase: mockUseCase,
    ...
  );

  expect(provider.isLoading, false);
  provider.verifyOtp(...);
  expect(provider.isLoading, true); // ✅
});
```

---

**Created:** 2025-10-18
**Architecture:** Clean Architecture + DI
**Pattern:** Repository Pattern + Use Cases

# Framee Flutter App

Social media app — share photos and thoughts.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.24+ / Dart 3.5+ |
| State | Riverpod 2 + riverpod_generator |
| Navigation | go_router 14 |
| Models | freezed + json_serializable |
| Push Notifications | Firebase Cloud Messaging |
| Secure Storage | flutter_secure_storage |
| Preferences | shared_preferences |
| Images | cached_network_image + image_picker |
| HTTP | Dio (Supabase REST ready) |
| Backend (planned) | Supabase |

---

## Project Structure

```
lib/
├── core/
│   ├── components/        # Reusable widgets (AppButton, AppAvatar, etc.)
│   ├── constants/         # AppColors, AppTextStyles, AppDimens, AppStrings
│   ├── errors/            # AppError sealed class + mapError()
│   ├── extensions/        # BuildContext, String, DateTime, num extensions
│   ├── l10n/              # Localization setup
│   ├── models/            # UI models (UserModel, PostModel, etc.)
│   ├── providers/         # ThemeProvider, ConnectivityProvider
│   ├── router/            # go_router AppRouter + AppRoutes
│   ├── services/          # FcmService, SecureStorageService, SupabaseService
│   ├── theme/             # AppTheme (light + dark)
│   └── utils/             # MockData
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/   # LoginScreen, SignUpScreen
│   │       ├── widgets/
│   │       └── providers/ # AuthProvider
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/   # HomeScreen
│   │       ├── widgets/   # PostCard
│   │       └── providers/ # HomeProvider
│   ├── post/
│   │   └── presentation/
│   │       ├── screens/   # CreatePostScreen, PostDetailScreen
│   │       ├── widgets/   # CommentTile
│   │       └── providers/ # CreatePostProvider, PostDetailProvider
│   ├── profile/
│   │   └── presentation/
│   │       ├── screens/   # ProfileScreen, FollowersScreen, EditProfileScreen
│   │       ├── widgets/   # ProfileGrid
│   │       └── providers/ # ProfileProvider, EditProfileProvider
│   ├── search/
│   │   └── presentation/
│   │       ├── screens/   # SearchScreen
│   │       └── providers/ # SearchProvider
│   ├── notifications/
│   │   └── presentation/
│   │       ├── screens/   # NotificationsScreen
│   │       └── providers/ # NotificationsProvider
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/   # SettingsScreen
│   └── onboarding/
│       └── presentation/
│           ├── screens/   # OnboardingScreen, ProfileSetupScreen
│           └── providers/ # ProfileSetupProvider
│
├── firebase_options.dart  # Firebase config (replace with real values)
└── main.dart
```

---

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configure Firebase
```bash
# Install flutterfire CLI if not installed
dart pub global activate flutterfire_cli

# Configure for your Firebase project
flutterfire configure
```
This replaces `lib/firebase_options.dart` with your real config.

### 4. Add fonts
Download and place in `assets/fonts/`:
- DMSans-Regular.ttf
- DMSans-Medium.ttf
- DMSans-SemiBold.ttf
- DMSans-Bold.ttf
- InstrumentSerif-Regular.ttf
- InstrumentSerif-Italic.ttf

Available free from: https://fonts.google.com/specimen/DM+Sans

### 5. Create asset folders
```bash
mkdir -p assets/images assets/icons assets/animations
```

### 6. Configure Supabase (when ready)
Add to pubspec.yaml:
```yaml
supabase_flutter: ^2.5.0
```
Then uncomment the code in `lib/core/services/supabase_service.dart`.

### 7. Add flutter_local_notifications (for FCM foreground)
Add to pubspec.yaml:
```yaml
flutter_local_notifications: ^17.2.2
```

---

## Run

```bash
# Debug
flutter run

# Release
flutter run --release

# Specific device
flutter run -d <device_id>
```

---

## Code Generation

After modifying any `@riverpod`, `@freezed`, or `@JsonSerializable` annotated class:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous watching during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Generated Files (do not edit manually)

- `*.g.dart` — Riverpod providers, JSON serialization
- `*.freezed.dart` — Freezed data classes

---

## Responsive Design

- Design base: 393×852 (iPhone 15)
- Tablet breakpoint: 600dp
- Desktop breakpoint: 900dp
- Uses `flutter_screenutil` for adaptive sizing
- `ResponsiveBuilder` widget for layout switching
- `MaxWidthBox` for tablet centering

---

## Dark / Light Mode

Theme is controlled by `themeModeProvider` (Riverpod).
Persisted to `SharedPreferences`. Toggle via Settings screen.

---

## Notes

- Domain / data layers are intentionally not implemented —
  add your Supabase queries in the `// Supabase` comments inside providers.
- `MockData` in `lib/core/utils/mock_data.dart` provides sample data for UI.
- All colors: `AppColors` | All text styles: `AppTextStyles` |
  All spacing: `AppDimens` | All strings: `AppStrings`

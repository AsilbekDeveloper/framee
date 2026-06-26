import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/services/fcm_service.dart';
import 'core/l10n/app_localizations.dart';
import 'features/profile/data/providers/profile_data_providers.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'i18n/strings.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics — catch all Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Crashlytics — catch async/platform errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // Disable Crashlytics in debug so logs stay readable in the console
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  // Analytics — enable data collection (disabled in debug for clean dashboards)
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  // Background/terminated holatda kelgan push xabarlarni qayta ishlash uchun.
  // runApp'dan oldin ro'yxatdan o'tkazilishi kerak.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await GoogleSignIn.instance.initialize(
    serverClientId: '410555718765-uuvj8u3hl1m7qf67ofjv8h8ittrt4tn1.apps.googleusercontent.com',
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(TranslationProvider(child: const ProviderScope(child: FrameeApp())));
}

class FrameeApp extends ConsumerStatefulWidget {
  const FrameeApp({super.key});

  @override
  ConsumerState<FrameeApp> createState() => _FrameeAppState();
}

class _FrameeAppState extends ConsumerState<FrameeApp> {
  @override
  void initState() {
    super.initState();
    // Initialize after the first frame so the Activity is fully ready and
    // the system permission dialog can be shown to the user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wire FCM token saving through ProfileRepository (Clean Architecture).
      FcmService.instance.setTokenSaver((token) async {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;
        await ref.read(profileRepositoryProvider).saveFcmToken(userId, token);
      });
      FcmService.instance.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    // Initialize locale from persisted preference
    ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Framee',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'services/api_service.dart';

// Core
import 'core/theme/app_theme.dart';

// Providers
import 'providers/auth/auth_provider.dart';
import 'providers/theme/app_theme_provider.dart';
import 'providers/locale/app_locale_provider.dart';
import 'providers/sidebar/sidebar_provider.dart';
import 'providers/sidebar/navigation_provider.dart';
import 'providers/token/token_provider.dart';
import 'providers/notification/notification_provider.dart';
import 'providers/dataset/dataset_provider.dart';
import 'providers/translation_provider.dart';

// Screens (legacy)
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_choice_screen.dart';
import 'screens/user_signup_screen.dart';
import 'screens/org_signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/reset_sent_screen.dart';
import 'screens/set_new_password_screen.dart';
import 'screens/home_screen.dart' as legacy;
import 'screens/text_to_sign_screen.dart' as legacy;
import 'screens/subscription_screen.dart' as legacy;
import 'screens/user_profile_screen.dart' as legacy;
import 'screens/organization_profile_screen.dart' as legacy;

// New features
import 'features/sidebar/widgets/app_shell.dart';
import 'features/chatbot/providers/chat_provider.dart';
import 'features/chatbot/screens/chat_screen.dart' as chatbot;
import 'features/sign_to_text/providers/sign_to_text_provider.dart';
import 'features/sign_to_text/screens/sign_to_text_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.init();
  await ApiService.loadTokensFromStorage();

  runApp(const TafahomApp());
}

/// Root application widget with all providers
class TafahomApp extends StatelessWidget {
  const TafahomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => AppThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => AppLocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => SidebarProvider()..init()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()..init()),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DatasetProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => SignToTextProvider()..init()),
      ],
      child: const _AppContent(),
    );
  }
}

/// App content that responds to theme and locale changes
class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    final localeProvider = context.watch<AppLocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TAFAHOM',

      // Localization
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Routes
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate(),
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup_choice': (_) => const SignupChoiceScreen(),
        '/user_signup': (_) => const UserSignupScreen(),
        '/org_signup': (_) => const OrgSignupScreen(),
        '/reset_password': (_) => const ResetPasswordScreen(),
        '/reset_sent': (_) => const ResetSentScreen(),
        '/set_new_password': (_) => const SetNewPasswordScreen(),

        // Legacy routes (for backward compatibility)
        '/main': (_) => const LegacyMainNavigator(),
        '/home': (context) => legacy.HomeScreen(
              username: 'User',
              usernameLower: 'user',
            ),
        '/sign-to-text': (context) => const SignToTextScreen(),
        '/sign-translation': (context) => const SignToTextScreen(),
        '/text-to-sign': (context) => const legacy.TextToSignScreen(),
        '/user_profile': (_) => const legacy.UserProfileScreen(),
        '/org_profile': (_) => const legacy.OrganizationProfileScreen(),
        '/subscription': (_) => const legacy.SubscriptionScreen(),
        '/chatbot': (_) => const chatbot.ChatScreen(),
      },
    );
  }
}

/// Auth gate — splashscreen first, user chooses to login or continue as guest
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

/// Premium app shell with modern sidebar
class PremiumAppShell extends StatelessWidget {
  const PremiumAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}

/// Legacy main navigator for backward compatibility
class LegacyMainNavigator extends StatelessWidget {
  const LegacyMainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}

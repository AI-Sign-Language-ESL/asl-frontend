import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:tafahom_english_light/l10n/app_localizations.dart';

// ================= SCREENS =================
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_2fa_screen.dart';
import 'screens/signup_choice_screen.dart';
import 'screens/user_signup_screen.dart';
import 'screens/org_signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/reset_sent_screen.dart';
import 'screens/set_new_password_screen.dart';

import 'screens/home_screen.dart';
import 'screens/sign_to_text_screen.dart';
import 'screens/text_to_sign_screen.dart';
import 'screens/dataset_contribution_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

// ================= WIDGETS =================
import 'widgets/custom_sidebar.dart';

/// ================= Locale Provider =================
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

/// ================= User Provider =================
class UserProvider extends ChangeNotifier {
  bool isLoggedIn = false;

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// ================= App Root =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TAFAHOM',
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: const Color(0xFF275878),
            scaffoldBackgroundColor: const Color(0xFFD5EBF5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Color(0xFF275878),
              centerTitle: true,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF275878),
                foregroundColor: Colors.white,
              ),
            ),
          ),

          /// IMPORTANT: use ONLY initialRoute
          initialRoute: '/auth',

          routes: {
            '/auth': (_) => const AuthWrapper(),
            '/splash': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/login_2fa': (_) => const Login2FAScreen(),
            '/signup_choice': (_) => const SignupChoiceScreen(),
            '/user_signup': (_) => const UserSignupScreen(),
            '/org_signup': (_) => const OrgSignupScreen(),
            '/reset_password': (_) => const ResetPasswordScreen(),
            '/reset_sent': (_) => const ResetSentScreen(),
            '/set_new_password': (_) => const SetNewPasswordScreen(),

            /// MAIN APP
            '/main': (_) => const MainNavigator(),

            /// TRANSLATION SCREENS (used by toggle)
            '/sign-to-text': (_) => const SignToTextScreen(),
            '/text-to-sign': (_) => const TextToSignScreen(),
          },
        );
      },
    );
  }
}

/// ================= Auth Wrapper =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoggedIn) {
      return const MainNavigator();
    }
    return const SplashScreen();
  }
}

/// ================= Main Navigator (Drawer-based) =================
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SignToTextScreen(), // Translation (default)
    DatasetContributionScreen(),
    SubscriptionScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      drawer: CustomSidebar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import 'services/api_service.dart';

import 'screens/custom_sidebar.dart';
import 'screens/dataset_contribution_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/org_signup_screen.dart';
import 'screens/organization_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/reset_sent_screen.dart';
import 'screens/set_new_password_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_to_text_screen.dart';
import 'screens/signup_choice_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/text_to_sign_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/user_signup_screen.dart';

// ── LocaleProvider ────────────────────────────────────────────────────────────
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}

// ── ThemeProvider ─────────────────────────────────────────────────────────────
/// Single source of truth for dark-mode state.
/// Toggle from SettingsScreen; consumed by every screen via context.watch<ThemeProvider>().
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

// ── UserProvider ──────────────────────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  String? username;
  bool isOrg = false;
  bool isLoggedIn = false;

  void login(String name, {bool org = false}) {
    username = name;
    isOrg = org;
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    username = null;
    isOrg = false;
    isLoggedIn = false;
    notifyListeners();
  }
}

// ── main ──────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.init();
  await ApiService.loadTokensFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ── MyApp ─────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch both providers so the app rebuilds when either changes.
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

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

      // ── Theme mode driven by ThemeProvider ──────────────────────────────
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ── Light theme ─────────────────────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Cairo',
        primaryColor: const Color(0xFF275878),
        scaffoldBackgroundColor: const Color(0xFFD5EBF5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF275878),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF275878),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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

      // ── Dark theme ───────────────────────────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        primaryColor: const Color(0xFF4A90C4),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90C4),
          secondary: Color(0xFF4A90C4),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
        ),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          foregroundColor: Color(0xFF4A90C4),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF4A90C4),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90C4),
            foregroundColor: Colors.white,
          ),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup_choice': (_) => const SignupChoiceScreen(),
        '/user_signup': (_) => const UserSignupScreen(),
        '/org_signup': (_) => const OrgSignupScreen(),
        '/reset_password': (_) => const ResetPasswordScreen(),
        '/reset_sent': (_) => const ResetSentScreen(),
        '/set_new_password': (_) => const SetNewPasswordScreen(),
        '/main': (_) => const MainNavigator(),
        '/home': (context) =>
            HomeScreen(username: "User", usernameLower: 'user'),
        '/sign-to-text': (context) => const SignToTextScreen(),
        '/text-to-sign': (context) => const TextToSignScreen(),
        '/user_profile': (_) => const UserProfileScreen(),
        '/org_profile': (_) => const OrganizationProfileScreen(),
        '/subscription': (_) => const SubscriptionScreen(),
      },

      home: const AuthWrapper(),
    );
  }
}

// ── AuthWrapper ───────────────────────────────────────────────────────────────
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) => const SplashScreen();
}

// ── MainNavigator ─────────────────────────────────────────────────────────────
class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final List<Widget> screens = [
      HomeScreen(username: userProvider.username ?? '', usernameLower: ''),
      const SignToTextScreen(),
      const DatasetContributionScreen(),
      const SubscriptionScreen(),
      ProfileScreen(userName: userProvider.username ?? ''),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      drawer: isRtl
          ? null
          : CustomSidebar(
              selectedIndex: _currentIndex,
              onItemTapped: (index) {
                setState(() => _currentIndex = index);
                Navigator.pop(context);
              },
            ),
      endDrawer: isRtl
          ? CustomSidebar(
              selectedIndex: _currentIndex,
              onItemTapped: (index) {
                setState(() => _currentIndex = index);
                Navigator.pop(context);
              },
            )
          : null,
    );
  }
}

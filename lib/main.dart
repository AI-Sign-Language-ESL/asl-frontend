// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
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

/// LocaleProvider for language switching
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}

/// UserProvider – now with isLoggedIn flag
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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TAFAHOM',

          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,

          // ✅ CORRECT localization delegates for intl-based localization
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

          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/login': (_) => const LoginScreen(),
            '/signup_choice': (_) => const SignupChoiceScreen(),
            '/user_signup': (_) => const UserSignupScreen(),
            '/org_signup': (_) => const OrgSignupScreen(),
            '/reset_password': (_) => const ResetPasswordScreen(),
            '/reset_sent': (_) => const ResetSentScreen(),
            '/set_new_password': (_) => const SetNewPasswordScreen(),
            '/home': (_) => const MainNavigator(),
            '/home': (context) => HomeScreen(
                  username: "User",
                  usernameLower: 'user',
                ),
            '/sign-to-text': (context) => const SignToTextScreen(),
            '/text-to-sign': (context) => const TextToSignScreen(),
            '/main': (_) => const MainNavigator(),
            '/user_profile': (_) => const UserProfileScreen(),
            '/org_profile': (_) => const OrganizationProfileScreen(),
            '/subscription': (_) => SubscriptionScreen(),
          },

          home: const AuthWrapper(),
        );
      },
    );
  }
}

/// Auto route based on login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoggedIn) {
      return const MainNavigator();
    }
    return const SplashScreen();
  }
}

/// Main app with sidebar
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

    final List<Widget> _screens = [
      HomeScreen(
        username: userProvider.username ?? '',
        usernameLower: '',
      ),
      SignToTextScreen(),
      DatasetContributionScreen(),
      SubscriptionScreen(),
      ProfileScreen(),
      SettingsScreen(),
    ];

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

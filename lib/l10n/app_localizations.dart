import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @worldUnheard.
  ///
  /// In en, this message translates to:
  /// **'𝐴 𝑤𝑜𝑟𝑙𝑑 𝑤ℎ𝑒𝑟𝑒 𝑛𝑜 𝑜𝑛𝑒 𝑖𝑠 𝑙𝑒𝑓𝑡 𝑢𝑛ℎ𝑒𝑎𝑟𝑑'**
  String get worldUnheard;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started ➔ '**
  String get getStarted;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get continueAsGuest;

  /// No description provided for @builtBy.
  ///
  /// In en, this message translates to:
  /// **'Built by NU • In collaboration with EgyDeaf'**
  String get builtBy;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome '**
  String get welcome;

  /// No description provided for @signsAlive.
  ///
  /// In en, this message translates to:
  /// **'Where your signs come alive.'**
  String get signsAlive;

  /// No description provided for @enterEmailUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get enterEmailUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me!'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or Login with'**
  String get orLoginWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @pleaseEnterEmailUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or username'**
  String get pleaseEnterEmailUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits your needs...'**
  String get choosePlan;

  /// No description provided for @for1Month.
  ///
  /// In en, this message translates to:
  /// **'for 1 month'**
  String get for1Month;

  /// No description provided for @plus100Coin.
  ///
  /// In en, this message translates to:
  /// **'+100 coin everyday'**
  String get plus100Coin;

  /// No description provided for @textToSign.
  ///
  /// In en, this message translates to:
  /// **'Text to Sign'**
  String get textToSign;

  /// No description provided for @speech.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get speech;

  /// No description provided for @for3Months.
  ///
  /// In en, this message translates to:
  /// **'for 3 months'**
  String get for3Months;

  /// No description provided for @plus150Coin.
  ///
  /// In en, this message translates to:
  /// **'+150 coin everyday'**
  String get plus150Coin;

  /// No description provided for @meetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetings;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @handsVoice.
  ///
  /// In en, this message translates to:
  /// **'Your hands have a voice — join us.'**
  String get handsVoice;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get organizationName;

  /// No description provided for @organizationActivity.
  ///
  /// In en, this message translates to:
  /// **'Organization activity'**
  String get organizationActivity;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @signUpAs.
  ///
  /// In en, this message translates to:
  /// **'Sign up as'**
  String get signUpAs;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with 💖 for the Deaf community'**
  String get madeWithLove;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'profile'**
  String get profile;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmail;

  /// No description provided for @sentResetLink.
  ///
  /// In en, this message translates to:
  /// **'We have sent a password reset link to\nyour registered email address.'**
  String get sentResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @subscriptionLower.
  ///
  /// In en, this message translates to:
  /// **'subscription'**
  String get subscriptionLower;

  /// No description provided for @oneMonthLeft.
  ///
  /// In en, this message translates to:
  /// **'1 month left'**
  String get oneMonthLeft;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @willEmailLink.
  ///
  /// In en, this message translates to:
  /// **'We will email you a link to reset your password.'**
  String get willEmailLink;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @tryLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Try logging in? '**
  String get tryLoggingIn;

  /// No description provided for @changePersonalProfile.
  ///
  /// In en, this message translates to:
  /// **'Change Personal Profile'**
  String get changePersonalProfile;

  /// No description provided for @changeEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Change Email Address'**
  String get changeEmailAddress;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'More Settings'**
  String get moreSettings;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @helpPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Help and Privacy'**
  String get helpPrivacy;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @firstnameLower.
  ///
  /// In en, this message translates to:
  /// **'firstname'**
  String get firstnameLower;

  /// No description provided for @lastnameLower.
  ///
  /// In en, this message translates to:
  /// **'lastname'**
  String get lastnameLower;

  /// No description provided for @usernameLower.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get usernameLower;

  /// No description provided for @emailLower.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLower;

  /// No description provided for @orgNameLower.
  ///
  /// In en, this message translates to:
  /// **'organization name'**
  String get orgNameLower;

  /// No description provided for @orgActivityLower.
  ///
  /// In en, this message translates to:
  /// **'organization activity'**
  String get orgActivityLower;

  /// No description provided for @jobTitleLower.
  ///
  /// In en, this message translates to:
  /// **'job title'**
  String get jobTitleLower;

  /// No description provided for @exclamationEmoji.
  ///
  /// In en, this message translates to:
  /// **'! 👋'**
  String get exclamationEmoji;

  /// No description provided for @startTranslating.
  ///
  /// In en, this message translates to:
  /// **'Start Translating ➔'**
  String get startTranslating;

  /// No description provided for @contributeDataset.
  ///
  /// In en, this message translates to:
  /// **'Contribute to dataset'**
  String get contributeDataset;

  /// No description provided for @supportedDialects.
  ///
  /// In en, this message translates to:
  /// **'Supported Dialects'**
  String get supportedDialects;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @signToText.
  ///
  /// In en, this message translates to:
  /// **'Sign to Text'**
  String get signToText;

  /// No description provided for @tafahom.
  ///
  /// In en, this message translates to:
  /// **'TAFAHOM.'**
  String get tafahom;

  /// No description provided for @helpUsGrow.
  ///
  /// In en, this message translates to:
  /// **'Help Us Grow'**
  String get helpUsGrow;

  /// No description provided for @recordSign.
  ///
  /// In en, this message translates to:
  /// **'Record a sign and tell us what it means to\nimprove our dataset.'**
  String get recordSign;

  /// No description provided for @whatSignMean.
  ///
  /// In en, this message translates to:
  /// **'What does this sign mean?'**
  String get whatSignMean;

  /// No description provided for @egGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'e.g: \"Good morning\"'**
  String get egGoodMorning;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload a video max 15mb'**
  String get uploadVideo;

  /// No description provided for @submitContribution.
  ///
  /// In en, this message translates to:
  /// **'Submit contribution'**
  String get submitContribution;

  /// No description provided for @thankContribution.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your contribution!'**
  String get thankContribution;

  /// No description provided for @realPerson.
  ///
  /// In en, this message translates to:
  /// **'Real person'**
  String get realPerson;

  /// No description provided for @character.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get character;

  /// No description provided for @waitingOutput.
  ///
  /// In en, this message translates to:
  /// **'Waiting for output..'**
  String get waitingOutput;

  /// No description provided for @typeOrSpeak.
  ///
  /// In en, this message translates to:
  /// **'type or speak...'**
  String get typeOrSpeak;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get cameraNotAvailable;

  /// No description provided for @enterTextToSign.
  ///
  /// In en, this message translates to:
  /// **'Enter text to convert to sign language'**
  String get enterTextToSign;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message here...'**
  String get typeYourMessage;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or Sign up with'**
  String get orSignUpWith;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

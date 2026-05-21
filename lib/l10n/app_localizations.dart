import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'RoAdRoBos'**
  String get appName;

  /// Book now button label
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get btnBook;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Proceed button label
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get btnProceed;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get btnSignIn;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get btnSignUp;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get btnLogout;

  /// Pickup location label
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get lblPickup;

  /// Drop-off location label
  ///
  /// In en, this message translates to:
  /// **'Drop-off Location'**
  String get lblDropoff;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get lblEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get lblPassword;

  /// Wallet screen title
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get titleWallet;

  /// Home tab title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get titleHome;

  /// Bookings tab title
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get titleBookings;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get titleProfile;

  /// Explore tab title
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get titleExplore;

  /// Login screen welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get titleWelcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get lblLoginSubtitle;

  /// Social login divider text
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get lblOrContinueWith;

  /// Prompt to sign up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get lblDontHaveAccount;

  /// Wallet balance label
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get lblAvailableBalance;

  /// Wallet transactions header
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get titleRecentTransactions;

  /// Wallet top up action
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get lblTopUp;

  /// Wallet transfer action
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get lblTransfer;

  /// Wallet withdraw action
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get lblWithdraw;

  /// Home screen quick actions section
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get titleQuickActions;

  /// Home screen offers section
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get titleActiveOffers;

  /// View all link text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get lblViewAll;

  /// Home search bar hint text
  ///
  /// In en, this message translates to:
  /// **'Search services, repairs...'**
  String get lblSearchServices;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

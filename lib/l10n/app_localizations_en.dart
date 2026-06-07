// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RoadRobos';

  @override
  String get recentServices => 'Recent Services';

  @override
  String get exploreServices => 'Explore Services';

  @override
  String get moreServices => 'More Services';

  @override
  String get switchView => 'Switch View';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get addNewVehicle => 'Add New Vehicle';

  @override
  String get errorLoadingCategories =>
      'Unable to load categories. Please try again.';

  @override
  String get errorLoadingOffers => 'Unable to load offers. Please try again.';

  @override
  String get bookNow => 'Book Now';

  @override
  String get retry => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String get loading => 'Loading...';

  @override
  String get viewAll => 'View All';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get home => 'Home';

  @override
  String get bookings => 'Bookings';

  @override
  String get wallet => 'Wallet';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get signOut => 'Sign Out';

  @override
  String get paymentSuccess => 'Payment Successful!';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get securityWarning => 'Security Alert';

  @override
  String get securityWarningMessage =>
      'Your device appears to be rooted or jailbroken. Payment features are disabled to protect your account.';

  @override
  String get closeApp => 'Close App';
}

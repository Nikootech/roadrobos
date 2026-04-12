/// Application environment configuration.
/// Values are injected at build time via --dart-define flags.
///
/// Example build command:
/// ```
/// flutter build apk --dart-define=ENV=prod --dart-define=RAZORPAY_KEY=rzp_live_xxx
/// ```
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment environment;
  static late String razorpayKey;
  static late String mapsApiKey;

  /// Initialize config from compile-time defines.
  static void init() {
    const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (envStr) {
      case 'prod':
        environment = Environment.prod;
        break;
      case 'staging':
        environment = Environment.staging;
        break;
      default:
        environment = Environment.dev;
    }

    razorpayKey = const String.fromEnvironment(
      'RAZORPAY_KEY',
      defaultValue: 'rzp_test_PLACEHOLDER', // Replace with actual test key
    );

    mapsApiKey = const String.fromEnvironment(
      'MAPS_API_KEY',
      defaultValue: '', // Set via --dart-define
    );
  }

  static bool get isDev => environment == Environment.dev;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProd => environment == Environment.prod;

  /// Show debug features (Quick Demo Access, etc.) only in dev
  static bool get showDebugFeatures => isDev;
}

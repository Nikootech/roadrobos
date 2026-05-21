/// Application environment configuration.
/// Values are injected at build time via --dart-define-from-file=.dart_defines
///
/// Example build command:
/// ```
/// flutter run --dart-define-from-file=.dart_defines
/// flutter build apk --dart-define-from-file=.dart_defines
/// ```
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment environment;
  static const razorpayKey = String.fromEnvironment('RAZORPAY_KEY_ID');
  static late String mapsApiKey;

  // --- Supabase ---
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabaseServiceKey = String.fromEnvironment('SUPABASE_SERVICE_KEY');

  // --- Google OAuth ---
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  // --- Razorpay ---
  // (Using razorpayKey defined above)

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

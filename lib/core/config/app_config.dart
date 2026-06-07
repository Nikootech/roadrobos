/// Application environment configuration.
/// Values are injected at build time via --dart-define-from-file=.dart_defines.json
///
/// Build commands:
///   flutter run  --dart-define-from-file=.dart_defines.json
///   flutter build apk --release --dart-define-from-file=.dart_defines.json
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment environment;

  // ── Supabase (client-side safe values) ──────────────────────────────────
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  // supabaseServiceKey has been REMOVED — the service role key bypasses
  // all Row Level Security. It MUST only exist in Supabase Edge Functions
  // as a server-side env variable, never in the Flutter app APK.

  // ── Google OAuth ─────────────────────────────────────────────────────────
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  // ── Razorpay ─────────────────────────────────────────────────────────────
  // Use rzp_live_ in prod, rzp_test_ in dev. Key ID is safe to include
  // (it is public); the secret stays server-side in the verify_payment RPC.
  static const razorpayKey = String.fromEnvironment('RAZORPAY_KEY_ID');

  // ── Maps ─────────────────────────────────────────────────────────────────
  static late String mapsApiKey;

  /// Call once in main() before runApp.
  static void init() {
    const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (envStr) {
      case 'prod':
        environment = Environment.prod;
      case 'staging':
        environment = Environment.staging;
      default:
        environment = Environment.dev;
    }

    mapsApiKey = const String.fromEnvironment('MAPS_API_KEY');
  }

  static bool get isDev => environment == Environment.dev;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProd => environment == Environment.prod;

  /// Show developer-only features (quick demo access, debug overlay).
  static bool get showDebugFeatures => isDev;
}

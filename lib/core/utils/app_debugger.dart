// ignore_for_file: avoid_print
/// ──────────────────────────────────────────────────────────────────────────
/// AppDebugger — Central diagnostic utility for RoadRobos
///
/// Usage:
///   AppDebugger.run();          // Full diagnostics on app start (debug only)
///   AppDebugger.logEnv();       // Print all dart-define values
///   AppDebugger.logPlatform();  // Print platform/web info
///   AppDebugger.checkConfig();  // Validate critical config at runtime
///   AppDebugger.watch(ref);     // Watch auth + user state (call in ConsumerWidget)
/// ──────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../config/app_config.dart';

class AppDebugger {
  AppDebugger._();

  static const _divider = '──────────────────────────────────────────────────';

  /// Run all diagnostics. Call once in main() inside `if (kDebugMode)`.
  static void run() {
    if (!kDebugMode) return;
    _section('APP DEBUGGER — RoadRobos');
    logPlatform();
    logEnv();
    checkConfig();
    _footer();
  }

  // ── 1. Platform info ───────────────────────────────────────────────────────

  static void logPlatform() {
    _section('PLATFORM');
    debugPrint('  kIsWeb       : $kIsWeb');
    debugPrint('  kDebugMode   : $kDebugMode');
    debugPrint('  kProfileMode : $kProfileMode');
    debugPrint('  kReleaseMode : $kReleaseMode');
    debugPrint('  defaultTargetPlatform: $defaultTargetPlatform');
  }

  // ── 2. Dart-define / environment variables ─────────────────────────────────

  static void logEnv() {
    _section('DART-DEFINE ENVIRONMENT');

    _check('ENV',
        desc: 'Build environment (dev / staging / prod)',
        value: AppConfig.environment.name);

    _check('SUPABASE_URL',
        desc: 'Supabase project URL',
        value: AppConfig.supabaseUrl,
        critical: true,
        validate: (v) => v.startsWith('https://'));

    _check('SUPABASE_ANON_KEY',
        desc: 'Supabase anon/public key',
        value: AppConfig.supabaseAnonKey,
        critical: true,
        validate: (v) => v.length > 20,
        redact: true);

    _check('GOOGLE_CLIENT_ID',
        desc: 'Google OAuth client ID',
        value: AppConfig.googleClientId,
        validate: (v) => v.contains('.apps.googleusercontent.com'));

    _check('RAZORPAY_KEY_ID',
        desc: 'Razorpay key (rzp_test_ or rzp_live_)',
        value: AppConfig.razorpayKey,
        validate: (v) => v.startsWith('rzp_'));

    _check('MAPS_API_KEY',
        desc: 'Google Maps / OSM key',
        value: AppConfig.mapsApiKey);

    _check('SENTRY_DSN',
        desc: 'Sentry error reporting DSN',
        value: AppConfig.sentryDsn);
  }

  // ── 3. Runtime config validation ───────────────────────────────────────────

  static void checkConfig() {
    _section('CONFIG VALIDATION');

    final issues = <String>[];

    // Supabase URL check
    if (AppConfig.supabaseUrl.isEmpty) {
      issues.add('❌ SUPABASE_URL is empty → app will crash on Supabase.initialize()');
    } else if (!AppConfig.supabaseUrl.startsWith('https://')) {
      issues.add('⚠️  SUPABASE_URL does not start with https:// — check .dart_defines');
    } else {
      debugPrint('  ✅ SUPABASE_URL looks valid');
    }

    // Supabase anon key
    if (AppConfig.supabaseAnonKey.isEmpty) {
      issues.add('❌ SUPABASE_ANON_KEY is empty → all DB calls will return 401');
    } else {
      debugPrint('  ✅ SUPABASE_ANON_KEY is set (${AppConfig.supabaseAnonKey.length} chars)');
    }

    // Razorpay
    if (AppConfig.razorpayKey.isEmpty || AppConfig.razorpayKey == 'rzp_test_placeholderKey') {
      debugPrint('  ⚠️  RAZORPAY_KEY_ID is placeholder → payment will run in simulation mode');
    } else {
      debugPrint('  ✅ RAZORPAY_KEY_ID is set');
    }

    // Google Sign-In web
    if (kIsWeb && AppConfig.googleClientId.isEmpty) {
      issues.add('⚠️  GOOGLE_CLIENT_ID is empty on web → Google Sign-In will fail');
    }

    // Supabase session check (runtime)
    try {
      final session = sb.Supabase.instance.client.auth.currentSession;
      debugPrint('  ℹ️  Supabase current session: ${session == null ? "null (no session)" : "active (uid=${session.user.id.substring(0, 8)}...)"}');
    } catch (e) {
      issues.add('❌ Supabase.instance.client threw: $e  → Supabase.initialize() may not have been called yet');
    }

    // Vercel-specific issues
    if (kIsWeb) {
      _section('WEB / VERCEL CHECKS');
      _checkVercel();
    }

    if (issues.isEmpty) {
      debugPrint('  ✅ No critical config issues found.');
    } else {
      debugPrint('\n  ══ ISSUES DETECTED ══');
      for (final issue in issues) {
        debugPrint('  $issue');
      }
    }
  }

  // ── 4. Vercel-specific checks ──────────────────────────────────────────────

  static void _checkVercel() {
    // On web, flutter_local_notifications & razorpay_flutter are N/A.
    // Known web-only issue: Cross-Origin-Embedder-Policy (COEP) can block
    // SharedArrayBuffer needed by some WASM codecs. The vercel.json sets
    // COOP/COEP headers which can break third-party iframes (e.g. Razorpay modal).
    debugPrint('  ℹ️  Running on web (Vercel deployment or flutter run -d chrome)');
    debugPrint('  ⚠️  Razorpay payment modal is BLOCKED on web — use web payment link fallback');
    debugPrint('  ⚠️  flutter_local_notifications is DISABLED on web — only FCM web push works');
    debugPrint('  ⚠️  flutter_jailbreak_detection is SKIPPED on web');
    debugPrint('  ⚠️  sqlite3 / Drift DB is UNAVAILABLE on web — offline sync is disabled');
    debugPrint('  ℹ️  COOP/COEP headers in vercel.json may block third-party iframes (chat widgets, payment UIs)');
    debugPrint('  ℹ️  Google Sign-In uses OAuth redirect on web — /login-callback must be a registered redirect URI');
  }

  // ── 5. Auth/User state watcher — call from ConsumerWidget ─────────────────

  /// Print current auth + user state. Call from a ConsumerWidget's build():
  ///   if (kDebugMode) AppDebugger.logAuthState(ref.watch(authNotifierProvider), ref.watch(userProvider));
  static void logAuthState(dynamic authState, dynamic userState) {
    if (!kDebugMode) return;
    _section('AUTH STATE SNAPSHOT');
    debugPrint('  authState.isLoading : ${authState.isLoading}');
    debugPrint('  authState.hasValue  : ${authState.hasValue}');
    debugPrint('  authState.hasError  : ${authState.hasError}');
    debugPrint('  authUser uid        : ${authState.value?.id?.substring(0, 8) ?? "null"}...');
    debugPrint('  userState.isLoading : ${userState.isLoading}');
    debugPrint('  userState.isDemo    : ${userState.isDemo}');
    debugPrint('  userState.error     : ${userState.error}');
    debugPrint('  user role           : ${userState.user?.role}');
    debugPrint('  user approved       : ${userState.user?.isApproved}');
  }

  // ── 6. Known issues registry ───────────────────────────────────────────────

  /// Print all known issues and their fixes.
  static void printKnownIssues() {
    if (!kDebugMode) return;
    _section('KNOWN ISSUES & FIXES');

    final issues = [
      // Issue 1
      {
        'id': 'ISSUE-01',
        'title': 'dart_defines mismatch (local vs Vercel)',
        'symptom': 'App works locally but Supabase connection fails on Vercel',
        'cause': '.dart_defines file has values; Vercel uses ENV vars from Dashboard',
        'fix': 'Set SUPABASE_URL, SUPABASE_ANON_KEY etc. in Vercel Dashboard → Settings → Environment Variables',
      },
      // Issue 2
      {
        'id': 'ISSUE-02',
        'title': 'Razorpay modal blocked by COEP headers (Vercel)',
        'symptom': 'Payment modal does not open on web deploy',
        'cause': 'vercel.json sets Cross-Origin-Embedder-Policy: require-corp which blocks Razorpay iframe',
        'fix': 'Either remove COEP from vercel.json for payment routes, or use Razorpay Payment Link (hosted page) on web',
      },
      // Issue 3
      {
        'id': 'ISSUE-03',
        'title': 'Google OAuth redirect URI not registered',
        'symptom': 'Google Sign-In fails on Vercel with "redirect_uri_mismatch"',
        'cause': 'The Vercel deployment URL is not added as an authorized redirect URI in Google Cloud Console',
        'fix': 'Add https://<your-vercel-domain>/login-callback to Google Cloud Console → Credentials → OAuth → Authorized redirect URIs AND to Supabase → Auth → URL Configuration → Redirect URLs',
      },
      // Issue 4
      {
        'id': 'ISSUE-04',
        'title': 'Drift / SQLite unavailable on web',
        'symptom': 'App crashes or throws "UnsupportedError: SQLite not available on web"',
        'cause': 'sqlite3_flutter_libs and drift_flutter are native-only. Web build excludes them.',
        'fix': 'Guard all drift DB access with `if (!kIsWeb)`. Web falls back to Supabase direct queries.',
      },
      // Issue 5
      {
        'id': 'ISSUE-05',
        'title': 'flutter_local_notifications crash on web',
        'symptom': 'Notification service throws MissingPluginException on web',
        'cause': 'flutter_local_notifications has no web implementation',
        'fix': 'Already guarded with `if (!kIsWeb)` in notification_service.dart — ensure no new call sites bypass this guard',
      },
      // Issue 6
      {
        'id': 'ISSUE-06',
        'title': 'FCM background handler registered on web',
        'symptom': '"the `web` parameter needs to be set" warning in Flutter error handler',
        'cause': 'FirebaseMessaging.onBackgroundMessage() is called on web where it is not supported',
        'fix': 'Already guarded with `if (!kIsWeb)` in main.dart — confirmed fixed',
      },
      // Issue 7
      {
        'id': 'ISSUE-07',
        'title': 'ENV=prod in .dart_defines but debug-only features expected',
        'symptom': 'AppConfig.showDebugFeatures returns false even in local dev',
        'cause': '.dart_defines has ENV=prod which sets AppConfig.environment = prod',
        'fix': 'Change ENV=dev in .dart_defines for local development. Only set ENV=prod in Vercel ENV vars.',
      },
      // Issue 8
      {
        'id': 'ISSUE-08',
        'title': 'SENTRY_DSN is empty — errors not tracked in production',
        'symptom': 'Sentry.captureException is called but no events appear in Sentry dashboard',
        'cause': 'SENTRY_DSN is blank in .dart_defines and/or Vercel env vars',
        'fix': 'Add your Sentry DSN to .dart_defines (local) and to Vercel → Environment Variables (production)',
      },
      // Issue 9
      {
        'id': 'ISSUE-09',
        'title': 'MAPS_API_KEY is empty — map tiles may fail',
        'symptom': 'Map shows blank tiles or unauthorized errors in browser console',
        'cause': 'MAPS_API_KEY is not set in .dart_defines',
        'fix': 'OSM (flutter_map) does not need an API key. If using Google Maps tiles, add the key.',
      },
      // Issue 10
      {
        'id': 'ISSUE-10',
        'title': 'SentryFlutter.init() wraps runApp — errors before init are lost',
        'symptom': 'Errors during Firebase/Supabase init are not captured by Sentry',
        'cause': 'SentryFlutter.init() is called AFTER Firebase and Supabase initialize in main()',
        'fix': 'This is by design (Sentry needs the DSN from dart-defines). Firebase/Supabase init errors are caught by runZonedGuarded.',
      },
      // Issue 11
      {
        'id': 'ISSUE-11',
        'title': 'chat/:roomId route missing in customer_routes.dart',
        'symptom': 'Notification tap for chat_message pushes /chat/<roomId> but no route matches → shows 404',
        'cause': 'notification_service.dart pushes context.push("/chat/\$roomId") but customer_routes.dart only has /chat (no path param)',
        'fix': 'Add GoRoute(path: "/chat/:roomId", ...) to customer_routes.dart OR change notification_service.dart to pass roomId via state.extra',
      },
      // Issue 12
      {
        'id': 'ISSUE-12',
        'title': 'vercel-build.sh uses bash — Windows local test not supported',
        'symptom': 'Running vercel-build.sh locally on Windows fails (no bash)',
        'cause': 'The script is a Unix shell script; Windows does not have bash by default',
        'fix': 'Use WSL or Git Bash to test vercel-build.sh locally. Vercel Linux runners execute it correctly.',
      },
    ];

    for (final issue in issues) {
      debugPrint('\n  [${issue['id']}] ${issue['title']}');
      debugPrint('  Symptom : ${issue['symptom']}');
      debugPrint('  Cause   : ${issue['cause']}');
      debugPrint('  Fix     : ${issue['fix']}');
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  static void _section(String title) {
    debugPrint('\n$_divider');
    debugPrint('  $title');
    debugPrint(_divider);
  }

  static void _footer() {
    debugPrint('\n$_divider');
    debugPrint('  END OF DIAGNOSTICS');
    debugPrint(_divider);
  }

  static void _check(
    String key, {
    required String desc,
    required String value,
    bool critical = false,
    bool redact = false,
    bool Function(String)? validate,
  }) {
    final displayVal = redact
        ? (value.length > 10 ? '${value.substring(0, 6)}...[REDACTED]' : value.isEmpty ? '<empty>' : '[SET]')
        : (value.isEmpty ? '<empty>' : value);

    final ok = value.isNotEmpty && (validate == null || validate(value));
    final icon = ok ? '✅' : (critical ? '❌' : '⚠️ ');
    debugPrint('  $icon $key: $displayVal');
    if (!ok && value.isEmpty) {
      debugPrint('     └─ $desc is MISSING${critical ? " (CRITICAL)" : ""}');
    }
  }
}

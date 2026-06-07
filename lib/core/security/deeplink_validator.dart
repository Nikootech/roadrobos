/// Validates the scheme, host, and structure of incoming deeplinks
/// before the GoRouter processes them. Rejects forged or unexpected URIs.
class DeeplinkValidator {
  DeeplinkValidator._();

  static const _allowedSchemes = {'roadrobos', 'https'};

  /// Extract the host portion from the SUPABASE_URL env var.
  /// e.g. "https://qfwhgrhcffozujejlwre.supabase.co" → "qfwhgrhcffozujejlwre.supabase.co"
  static String get _supabaseHost {
    const url = String.fromEnvironment('SUPABASE_URL');
    if (url.isEmpty) return '';
    return Uri.tryParse(url)?.host ?? '';
  }

  static Set<String> get _allowedHosts => {
    'roadrobos.app',
    // Supabase project URL — used for OAuth redirects
    if (_supabaseHost.isNotEmpty) _supabaseHost,
  };


  /// Returns true if the URI is a valid, trusted deeplink.
  static bool isValid(Uri uri) {
    // 1. Scheme check
    if (!_allowedSchemes.contains(uri.scheme)) return false;

    // 2. For https deeplinks, host must be in allowlist
    if (uri.scheme == 'https' && !_allowedHosts.contains(uri.host)) {
      return false;
    }

    // 3. OAuth callback: must have a non-trivial code param
    if (uri.path == '/login-callback') {
      final code = uri.queryParameters['code'] ??
          uri.fragment; // PKCE uses fragment on some platforms
      if (code.length < 10) return false;
    }

    // 4. No path traversal attempts
    if (uri.path.contains('..') || uri.path.contains('%2e%2e')) return false;

    return true;
  }

  /// Sanitize and return a safe fallback path if validation fails.
  static String safeFallback(Uri uri) {
    // If it looks like an OAuth callback with a fragment, it may be legit
    if (uri.fragment.isNotEmpty && uri.path.isEmpty) return '/login-callback';
    return '/auth/login';
  }
}

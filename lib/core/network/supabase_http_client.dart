import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Custom HTTP Client for Supabase that enables local-only sign out.
///
/// When [suppressRemoteLogout] is true, requests to `/auth/v1/logout` are intercepted
/// and return a 200 OK locally without contacting the Supabase backend.
/// This prevents Supabase backend from revoking the session and refresh token in `auth.sessions`,
/// allowing the user to seamlessly resume the session via Biometrics after logging out.
class SupabaseHttpClient extends http.BaseClient {
  final http.Client _inner;

  /// Flag indicating whether remote logout calls should be intercepted.
  static bool suppressRemoteLogout = false;

  SupabaseHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (suppressRemoteLogout && request.url.path.endsWith('/logout')) {
      if (kDebugMode) {
        debugPrint(
          'SupabaseHttpClient: Intercepted /logout to preserve biometric session on server.',
        );
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode('{}')),
        200,
        request: request,
        headers: const {
          'content-type': 'application/json; charset=utf-8',
        },
      );
    }
    return _inner.send(request);
  }
}

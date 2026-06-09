// lib/core/services/two_factor_auth_service.dart
//
// Full-stack TOTP 2FA service using Supabase MFA APIs.
// The TOTP secret is NEVER stored in our own DB — Supabase Auth owns it.
// We only track mfa_enabled flag in the profiles table for display purposes.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

/// Result from a successful TOTP enrollment
class TotpEnrollmentResult {
  /// The factor ID — needed for challenge/verify and unenroll calls
  final String factorId;

  /// The `otpauth://totp/...` URI → feed this directly to QrImageView
  final String qrCodeUri;

  /// The plain-text secret (for manual entry in Authenticator apps)
  final String secret;

  const TotpEnrollmentResult({
    required this.factorId,
    required this.qrCodeUri,
    required this.secret,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class TwoFactorAuthService {
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  // ── Enroll ──────────────────────────────────────────────────────────────────

  /// Starts TOTP enrollment for the current user.
  /// Returns the QR URI and plain secret for the setup dialog.
  /// Does NOT save anything to the DB yet — that happens only after verification.
  Future<TotpEnrollmentResult> enrollTOTP() async {
    try {
      final response = await _supabase.auth.mfa.enroll(
        issuer: 'RoadRobos',
      );

      final totp = response.totp;
      if (totp == null) {
        throw Exception('2FA enrollment failed: no TOTP data returned.');
      }

      if (kDebugMode) {
        debugPrint('TwoFactorAuthService: TOTP enrolled. factorId=${response.id}');
      }

      return TotpEnrollmentResult(
        factorId: response.id,
        qrCodeUri: totp.qrCode,
        secret: totp.secret,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('TwoFactorAuthService.enrollTOTP error: $e');
      rethrow;
    }
  }

  // ── Challenge + Verify ───────────────────────────────────────────────────────

  /// Creates a challenge for [factorId] and immediately verifies the [totpCode].
  /// Returns `true` on success, throws on failure.
  Future<bool> challengeAndVerify({
    required String factorId,
    required String totpCode,
  }) async {
    try {
      // Step 1: Create a challenge
      final challengeResponse = await _supabase.auth.mfa.challenge(
        factorId: factorId,
      );

      // Step 2: Verify with user-entered code
      await _supabase.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeResponse.id,
        code: totpCode,
      );

      if (kDebugMode) {
        debugPrint('TwoFactorAuthService: TOTP verified successfully.');
      }
      return true;
    } on sb.AuthException catch (e) {
      if (kDebugMode) debugPrint('TwoFactorAuthService.challengeAndVerify AuthException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      if (kDebugMode) debugPrint('TwoFactorAuthService.challengeAndVerify error: $e');
      rethrow;
    }
  }

  // ── Unenroll ─────────────────────────────────────────────────────────────────

  /// Removes a TOTP factor for the current user (disabling 2FA).
  Future<void> unenroll(String factorId) async {
    try {
      await _supabase.auth.mfa.unenroll(factorId);
      if (kDebugMode) debugPrint('TwoFactorAuthService: Factor $factorId unenrolled.');
    } catch (e) {
      if (kDebugMode) debugPrint('TwoFactorAuthService.unenroll error: $e');
      rethrow;
    }
  }

  // ── List enrolled factors ────────────────────────────────────────────────────

  /// Returns the list of enrolled MFA factors for the current user.
  /// If the list has a verified TOTP factor, 2FA is active.
  Future<List<sb.Factor>> getEnrolledFactors() async {
    try {
      final response = await _supabase.auth.mfa.listFactors();
      return response.totp;
    } catch (e) {
      if (kDebugMode) debugPrint('TwoFactorAuthService.getEnrolledFactors error: $e');
      return [];
    }
  }

  /// Returns the first verified TOTP factor, or null if none.
  Future<sb.Factor?> getVerifiedTotpFactor() async {
    final factors = await getEnrolledFactors();
    try {
      return factors.firstWhere((f) => f.status == sb.FactorStatus.verified);
    } catch (_) {
      return null;
    }
  }

  // ── DB Flag helpers ──────────────────────────────────────────────────────────

  /// Updates `profiles.mfa_enabled = true` and `mfa_enrolled_at = now()` for [userId].
  Future<void> markMfaEnabledInProfile(String userId) async {
    await _supabase.from('profiles').update({
      'mfa_enabled': true,
      'mfa_enrolled_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  /// Updates `profiles.mfa_enabled = false` for [userId].
  Future<void> markMfaDisabledInProfile(String userId) async {
    await _supabase.from('profiles').update({
      'mfa_enabled': false,
      'mfa_enrolled_at': null,
    }).eq('id', userId);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

final twoFactorAuthServiceProvider = Provider<TwoFactorAuthService>((ref) {
  return TwoFactorAuthService();
});

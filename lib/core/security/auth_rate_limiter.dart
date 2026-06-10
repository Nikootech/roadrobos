/// Client-side rate limiter for authentication endpoints.
///
/// Prevents brute-forcing / flooding auth APIs by enforcing a cooldown after
/// [maxAttempts] are exceeded within a rolling [windowDuration].
class AuthRateLimiter {
  static final Map<String, List<DateTime>> _attempts = {};
  static final Map<String, DateTime> _cooldowns = {};

  // Limit: 5 attempts per 60 seconds.
  static const int maxAttempts = 5;
  static const Duration windowDuration = Duration(seconds: 60);
  static const Duration cooldownDuration = Duration(seconds: 30);

  /// Checks if the [email] is rate-limited.
  ///
  /// Throws an [Exception] if the rate limit is exceeded, indicating the
  /// remaining cooldown duration in seconds.
  static void checkRateLimit(String email) {
    final now = DateTime.now();

    // Check if in active cooldown
    if (_cooldowns.containsKey(email)) {
      final cooldownEnd = _cooldowns[email]!;
      if (now.isBefore(cooldownEnd)) {
        final remaining = cooldownEnd.difference(now).inSeconds;
        throw Exception(
          'Too many login attempts. Please try again in $remaining seconds.',
        );
      } else {
        _cooldowns.remove(email);
      }
    }

    // Purge attempts older than the window
    final history = _attempts[email] ?? [];
    final cutoff = now.subtract(windowDuration);
    history.removeWhere((t) => t.isBefore(cutoff));
    _attempts[email] = history;

    // Trigger cooldown if threshold crossed
    if (history.length >= maxAttempts) {
      final cooldownEnd = now.add(cooldownDuration);
      _cooldowns[email] = cooldownEnd;
      _attempts.remove(email); // Reset counter
      throw Exception(
        'Too many login attempts. Please try again in ${cooldownDuration.inSeconds} seconds.',
      );
    }
  }

  /// Records a login attempt for [email].
  static void recordAttempt(String email) {
    final now = DateTime.now();
    if (!_attempts.containsKey(email)) {
      _attempts[email] = [];
    }
    _attempts[email]!.add(now);
  }

  /// Clears rate limits and attempts for [email] (e.g. on successful login).
  static void reset(String email) {
    _attempts.remove(email);
    _cooldowns.remove(email);
  }
}

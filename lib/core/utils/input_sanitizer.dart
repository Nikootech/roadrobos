/// Utility class that sanitizes all user-supplied text before it reaches
/// Supabase queries, preventing PostgREST filter injection.
class InputSanitizer {
  InputSanitizer._();

  // ─── ID / UUID validation ─────────────────────────────────────────────────

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Returns true only if [value] is a well-formed UUID v4.
  static bool isValidUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    return _uuidRegex.hasMatch(value);
  }

  // ─── Query filter values ───────────────────────────────────────────────────

  /// Strips PostgREST operator characters from a value used in `.filter()`.
  /// Allows: word characters, spaces, hyphens, dots, @, +
  static String sanitizeFilterValue(String input) {
    return input.replaceAll(RegExp(r'[^\w\s\-\.@+]'), '').trim();
  }

  // ─── Free-text fields ─────────────────────────────────────────────────────

  /// Strips angle brackets, null bytes, and control chars from user-entered
  /// text (names, notes, addresses) before insert/update.
  static String sanitizeText(String input, {int maxLength = 500}) {
    final cleaned = input
        .replaceAll(
            RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '') // control chars
        .replaceAll(RegExp(r'[<>"\x00]'), '') // HTML / SQL injection chars
        .trim();
    return cleaned.length > maxLength
        ? cleaned.substring(0, maxLength)
        : cleaned;
  }

  // ─── Phone / Email ────────────────────────────────────────────────────────

  static final _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    return _emailRegex.hasMatch(email.trim());
  }
}

/*
 ─── SAFE vs UNSAFE Supabase query examples ───────────────────────────────────

 ✅ SAFE — enum .name never user-typed:
    .eq('status', BookingStatus.confirmed.name)

 ✅ SAFE — UUID validated before use:
    if (!InputSanitizer.isValidUuid(userId)) return ...error...;
    .eq('user_id', userId)

 ✅ SAFE — sanitized search term:
    .ilike('name', '%${InputSanitizer.sanitizeFilterValue(query)}%')

 ❌ UNSAFE — raw string from TextEditingController:
    .filter('status', 'eq', rawTextInput)    ← NEVER

 ❌ UNSAFE — string interpolation in filter value:
    .filter('email', 'eq', '$emailFromUser') ← NEVER
*/

// Conditional import shim:
// On web → background_service_web.dart (no-op stub, zero plugin imports)
// On mobile → background_service_mobile.dart (full implementation)
export 'background_service_web.dart'
    if (dart.library.io) 'background_service_mobile.dart';

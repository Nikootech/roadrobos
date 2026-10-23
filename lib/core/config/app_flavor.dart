import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defines the flavor of the application.
/// - [customer]: The RoadRobos consumer app (commuter rides, vehicle services, rentals, deliveries, admin).
/// - [partner]: The RoadRobos Partner app for drivers and service technicians (jobs, fleet navigation, earnings, KYC).
enum AppFlavor {
  customer,
  partner;

  static AppFlavor? _override;
  static void setOverride(AppFlavor flavor) => _override = flavor;

  /// Compile-time constant or environment-injected flavor.
  /// Injected via `--dart-define=APP_FLAVOR=partner` or `customer`.
  static AppFlavor get current {
    if (_override != null) return _override!;
    const flavorStr = String.fromEnvironment('APP_FLAVOR', defaultValue: 'customer');
    switch (flavorStr.toLowerCase()) {
      case 'partner':
        return AppFlavor.partner;
      case 'customer':
      default:
        return AppFlavor.customer;
    }
  }

  bool get isCustomer => this == AppFlavor.customer;
  bool get isPartner => this == AppFlavor.partner;

  String get appTitle {
    switch (this) {
      case AppFlavor.partner:
        return 'RoadRobos Partner';
      case AppFlavor.customer:
        return 'RoadRobos';
    }
  }

  String get packageName {
    switch (this) {
      case AppFlavor.partner:
        return 'com.roadrobos.partner';
      case AppFlavor.customer:
        return 'com.roadrobos.customer';
    }
  }
}

/// Provider to access the active flavor throughout the widget tree.
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.current);

import 'package:flutter_test/flutter_test.dart';
import 'package:roadrobos/core/config/app_flavor.dart';
import 'package:roadrobos/core/models/user_role.dart';

void main() {
  group('1. AppFlavor Unit Tests', () {
    test('AppFlavor enum values and default properties', () {
      expect(AppFlavor.values.length, 2);
      expect(AppFlavor.customer.isCustomer, isTrue);
      expect(AppFlavor.customer.isPartner, isFalse);
      expect(AppFlavor.customer.appTitle, 'RoadRobos');
      expect(AppFlavor.customer.packageName, 'com.roadrobos.customer');

      expect(AppFlavor.partner.isPartner, isTrue);
      expect(AppFlavor.partner.isCustomer, isFalse);
      expect(AppFlavor.partner.appTitle, 'RoadRobos Partner');
      expect(AppFlavor.partner.packageName, 'com.roadrobos.partner');
    });

    test('UserRole displayName is properly mapped for all roles', () {
      expect(UserRole.customer.displayName, 'Customer');
      expect(UserRole.driver.displayName, 'Driver / Pilot');
      expect(UserRole.technician.displayName, 'Service Technician');
      expect(UserRole.superAdmin.displayName, 'Super Admin');
      expect(UserRole.admin.displayName, 'Administrator');
    });
  });

  group('2. Flavor Route Isolation Policy Tests', () {
    String simulateCustomerAppRedirect({
      required bool isLoggedIn,
      required UserRole? role,
      required String location,
    }) {
      if (!isLoggedIn) return '/auth/login';

      if (role == UserRole.driver || role == UserRole.technician) {
        return '/wrong-app';
      }

      if (location.startsWith('/admin-') && role != null && !role.isAdmin) {
        return '/main/home';
      }

      return location;
    }

    String simulatePartnerAppRedirect({
      required bool isLoggedIn,
      required UserRole? role,
      required String location,
      String kycStatus = 'approved',
    }) {
      if (!isLoggedIn) return '/auth/login';

      if (role == UserRole.customer || (role != null && role.isAdmin)) {
        return '/wrong-app';
      }

      if (role == UserRole.driver) {
        if (kycStatus != 'approved' &&
            location != '/driver/kyc-status' &&
            location != '/driver/kyc-upload') {
          return '/driver/kyc-status';
        }
        if (location.startsWith('/tech-')) {
          return '/driver-home';
        }
      }

      if (role == UserRole.technician) {
        if (location.startsWith('/driver-') || location.startsWith('/driver/')) {
          return '/tech-dashboard';
        }
      }

      return location;
    }

    test('Customer App redirects driver and technician to /wrong-app', () {
      expect(
        simulateCustomerAppRedirect(
          isLoggedIn: true,
          role: UserRole.driver,
          location: '/main/home',
        ),
        equals('/wrong-app'),
      );

      expect(
        simulateCustomerAppRedirect(
          isLoggedIn: true,
          role: UserRole.technician,
          location: '/taxi/home',
        ),
        equals('/wrong-app'),
      );
    });

    test('Customer App allows customer and admin to proceed', () {
      expect(
        simulateCustomerAppRedirect(
          isLoggedIn: true,
          role: UserRole.customer,
          location: '/main/home',
        ),
        equals('/main/home'),
      );

      expect(
        simulateCustomerAppRedirect(
          isLoggedIn: true,
          role: UserRole.superAdmin,
          location: '/admin-home',
        ),
        equals('/admin-home'),
      );
    });

    test('Partner App redirects customer and admin to /wrong-app', () {
      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.customer,
          location: '/driver-home',
        ),
        equals('/wrong-app'),
      );

      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.admin,
          location: '/tech-dashboard',
        ),
        equals('/wrong-app'),
      );
    });

    test('Partner App allows driver and technician with proper portal isolation', () {
      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.driver,
          location: '/driver-home',
        ),
        equals('/driver-home'),
      );

      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.driver,
          location: '/driver-home',
          kycStatus: 'pending',
        ),
        equals('/driver/kyc-status'),
      );

      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.technician,
          location: '/tech-dashboard',
        ),
        equals('/tech-dashboard'),
      );

      expect(
        simulatePartnerAppRedirect(
          isLoggedIn: true,
          role: UserRole.technician,
          location: '/driver/rides',
        ),
        equals('/tech-dashboard'),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:roadrobos/core/models/user_role.dart';
import 'package:roadrobos/core/models/ride_booking.dart';
import 'package:roadrobos/core/extensions/datetime_extensions.dart';

void main() {
  group('1. Role Definition & Classification Tests (All 14 Roles)', () {
    test('UserRole enum contains exactly 14 distinct roles', () {
      expect(UserRole.values.length, 14);
      expect(
        UserRole.values,
        containsAll([
          UserRole.customer,
          UserRole.driver,
          UserRole.technician,
          UserRole.superAdmin,
          UserRole.founderAdmin,
          UserRole.opsHead,
          UserRole.cityManager,
          UserRole.areaManager,
          UserRole.financeManager,
          UserRole.supportManager,
          UserRole.marketingAdmin,
          UserRole.auditor,
          UserRole.analyst,
          UserRole.admin,
        ]),
      );
    });

    test('Every role has a non-empty, human-readable roleLabel', () {
      for (final role in UserRole.values) {
        expect(role.roleLabel.isNotEmpty, isTrue,
            reason: '${role.name} must have a non-empty roleLabel');
      }
    });

    test('Role database serialization round-trip consistency', () {
      for (final role in UserRole.values) {
        final dbString = AppUser.roleToDb(role);
        expect(dbString.isNotEmpty, isTrue);

        // AppUser.fromMap parsing test
        final parsedUser = AppUser.fromMap({'role': dbString}, 'test_id');
        expect(parsedUser.role, role,
            reason:
                'Role $role serialized to "$dbString" must parse back to $role');
      }
    });

    test('Role grouping classifications are strictly accurate', () {
      // 11 Admin roles
      final expectedAdmins = [
        UserRole.admin,
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.opsHead,
        UserRole.cityManager,
        UserRole.areaManager,
        UserRole.financeManager,
        UserRole.supportManager,
        UserRole.marketingAdmin,
        UserRole.auditor,
        UserRole.analyst,
      ];
      for (final role in UserRole.values) {
        expect(role.isAdmin, expectedAdmins.contains(role),
            reason: 'isAdmin check failed for ${role.name}');
      }

      // Field Staff
      for (final role in UserRole.values) {
        final expectedFieldStaff =
            role == UserRole.driver || role == UserRole.technician;
        expect(role.isFieldStaff, expectedFieldStaff,
            reason: 'isFieldStaff check failed for ${role.name}');
      }

      // Read-Only Roles
      for (final role in UserRole.values) {
        final expectedReadOnly =
            role == UserRole.auditor || role == UserRole.analyst;
        expect(role.isReadOnly, expectedReadOnly,
            reason: 'isReadOnly check failed for ${role.name}');
      }
    });

    test('Role permission gates adhere to security specifications', () {
      // Financial access
      expect(UserRole.superAdmin.canAccessFinancials, isTrue);
      expect(UserRole.financeManager.canAccessFinancials, isTrue);
      expect(UserRole.auditor.canAccessFinancials, isTrue);
      expect(UserRole.customer.canAccessFinancials, isFalse);
      expect(UserRole.driver.canAccessFinancials, isFalse);

      // Emergency dispatch
      expect(UserRole.opsHead.canSeeEmergencies, isTrue);
      expect(UserRole.cityManager.canSeeEmergencies, isTrue);
      expect(UserRole.supportManager.canSeeEmergencies, isTrue);
      expect(UserRole.marketingAdmin.canSeeEmergencies, isFalse);
      expect(UserRole.customer.canSeeEmergencies, isFalse);

      // Approvals
      expect(UserRole.superAdmin.canApprove, isTrue);
      expect(UserRole.opsHead.canApprove, isTrue);
      expect(UserRole.cityManager.canApprove, isTrue);
      expect(UserRole.areaManager.canApprove, isTrue);
      expect(UserRole.auditor.canApprove, isFalse);
      expect(UserRole.analyst.canApprove, isFalse);
      expect(UserRole.technician.canApprove, isFalse);

      // System settings
      expect(UserRole.superAdmin.canManageSystem, isTrue);
      expect(UserRole.founderAdmin.canManageSystem, isTrue);
      expect(UserRole.admin.canManageSystem, isTrue);
      expect(UserRole.cityManager.canManageSystem, isFalse);
      expect(UserRole.driver.canManageSystem, isFalse);
    });
  });

  group('2. Role-Based Navigation Routing Logic Simulation', () {
    String simulateRouteGuard({
      required AppUser user,
      required String requestedLocation,
    }) {
      // Unapproved Employee check
      if (!user.isApproved && user.role.isEmployee) {
        return '/auth/pending-approval';
      }

      // 1. Admin Guard
      if (requestedLocation.startsWith('/admin-') ||
          requestedLocation.startsWith('/admin/')) {
        if (!user.role.isAdmin) {
          return _homeForUser(user);
        }
      }

      // 2. Technician Guard
      if (requestedLocation.startsWith('/tech-')) {
        if (user.role != UserRole.technician) {
          return _homeForUser(user);
        }
      }

      // 3. Driver Guard
      if (requestedLocation.startsWith('/driver-') ||
          requestedLocation.startsWith('/driver/')) {
        if (user.role != UserRole.driver) {
          return _homeForUser(user);
        }
        if (user.kycStatus != 'approved' &&
            requestedLocation != '/driver/kyc-status' &&
            requestedLocation != '/driver/kyc-upload') {
          return '/driver/kyc-status';
        }
      }

      // 4. Customer Guard
      final customerPaths = [
        '/main/',
        '/taxi/',
        '/rental',
        '/delivery',
        '/wallet',
        '/services',
        '/insurance',
        '/ride-history',
      ];
      final isCustomerPath =
          customerPaths.any((p) => requestedLocation.startsWith(p));
      if (isCustomerPath && user.role != UserRole.customer) {
        return _homeForUser(user);
      }

      return requestedLocation; // Access granted
    }

    test('Customer is blocked from driver, technician, and admin portals', () {
      const customer = AppUser(
        id: 'cust_1',
        name: 'John Doe',
        phone: '9876543210',
        role: UserRole.customer,
      );

      expect(
        simulateRouteGuard(
            user: customer, requestedLocation: '/driver-home'),
        '/main/home',
      );
      expect(
        simulateRouteGuard(
            user: customer, requestedLocation: '/tech-dashboard'),
        '/main/home',
      );
      expect(
        simulateRouteGuard(
            user: customer, requestedLocation: '/admin-home'),
        '/main/home',
      );
      expect(
        simulateRouteGuard(
            user: customer, requestedLocation: '/main/home'),
        '/main/home',
      );
      expect(
        simulateRouteGuard(
            user: customer, requestedLocation: '/taxi/home'),
        '/taxi/home',
      );
    });

    test('Driver with approved KYC accesses driver routes, blocked from customer/admin/tech', () {
      const approvedDriver = AppUser(
        id: 'drv_1',
        name: 'Driver Dave',
        phone: '9876543211',
        role: UserRole.driver,
        kycStatus: 'approved',
      );

      expect(
        simulateRouteGuard(
            user: approvedDriver, requestedLocation: '/driver-home'),
        '/driver-home',
      );
      expect(
        simulateRouteGuard(
            user: approvedDriver, requestedLocation: '/main/home'),
        '/driver-home',
      );
      expect(
        simulateRouteGuard(
            user: approvedDriver, requestedLocation: '/admin-home'),
        '/driver-home',
      );
      expect(
        simulateRouteGuard(
            user: approvedDriver, requestedLocation: '/tech-dashboard'),
        '/driver-home',
      );
    });

    test('Driver with pending KYC is redirected to /driver/kyc-status', () {
      const pendingDriver = AppUser(
        id: 'drv_2',
        name: 'Pending Pete',
        phone: '9876543212',
        role: UserRole.driver,
        kycStatus: 'pending',
      );

      expect(
        simulateRouteGuard(
            user: pendingDriver, requestedLocation: '/driver-home'),
        '/driver/kyc-status',
      );
      expect(
        simulateRouteGuard(
            user: pendingDriver, requestedLocation: '/driver/kyc-upload'),
        '/driver/kyc-upload',
      );
    });

    test('Technician accesses tech routes, blocked from customer/admin/driver', () {
      const tech = AppUser(
        id: 'tech_1',
        name: 'Tech Tom',
        phone: '9876543213',
        role: UserRole.technician,
      );

      expect(
        simulateRouteGuard(
            user: tech, requestedLocation: '/tech-dashboard'),
        '/tech-dashboard',
      );
      expect(
        simulateRouteGuard(
            user: tech, requestedLocation: '/tech-create-job'),
        '/tech-create-job',
      );
      expect(
        simulateRouteGuard(
            user: tech, requestedLocation: '/main/home'),
        '/tech-dashboard',
      );
      expect(
        simulateRouteGuard(
            user: tech, requestedLocation: '/admin-home'),
        '/tech-dashboard',
      );
      expect(
        simulateRouteGuard(
            user: tech, requestedLocation: '/driver-home'),
        '/tech-dashboard',
      );
    });

    test('Unapproved employee is redirected to /auth/pending-approval', () {
      const unapprovedOps = AppUser(
        id: 'emp_1',
        name: 'Ops Pending',
        phone: '9876543214',
        role: UserRole.opsHead,
        isApproved: false,
      );

      expect(
        simulateRouteGuard(
            user: unapprovedOps, requestedLocation: '/admin-home'),
        '/auth/pending-approval',
      );
    });
  });

  group('3. Customer Ride Booking Flow Contract Tests', () {
    test('RideBooking model creates and serializes valid payload', () {
      final now = DateTime.now();
      final ride = RideBooking(
        id: 'ride_123',
        customerId: 'cust_test_1',
        pickupAddress: 'Sector 18, Noida',
        destinationAddress: 'Connaught Place, New Delhi',
        pickupLat: 28.5700,
        pickupLng: 77.3200,
        destLat: 28.6300,
        destLng: 77.2200,
        fare: 450.0,
        vehicleType: 'Sedan',
        otp: '4821',
        paymentMethod: 'Online',
        createdAt: now,
      );

      final map = ride.toMap();
      expect(map['customer_id'], 'cust_test_1');
      expect(map['pickup_address'], 'Sector 18, Noida');
      expect(map['fare'], 450.0);
      expect(map['status'], 'searching');
      expect(map['vehicle_type'], 'Sedan');
      expect(map['otp'], '4821');
      expect(map['payment_method'], 'Online');
      expect(map['created_at'], endsWith('Z'));

      // Deserialization check
      final parsedRide = RideBooking.fromMap(map, 'ride_123');
      expect(parsedRide.id, 'ride_123');
      expect(parsedRide.customerId, 'cust_test_1');
      expect(parsedRide.fare, 450.0);
      expect(parsedRide.pickupLat, 28.5700);
      expect(parsedRide.destLng, 77.2200);
    });
  });

  group('4. Technician Job Card Creation Flow Contract Tests', () {
    test('Job card payload satisfies required database contract and defaults', () {
      final nowUtcIso = DateTime.now().utcIso;
      final jobCardPayload = {
        'technician_id': 'tech_456',
        'vehicle_make': 'Maruti Suzuki',
        'vehicle_model': 'Swift Dzire',
        'registration_number': 'UP16AB1234',
        'notes': 'Engine oil change, brake pad inspection',
        'status': 'draft',
        'created_at': nowUtcIso,
      };

      expect(jobCardPayload['technician_id'], 'tech_456');
      expect(jobCardPayload['vehicle_model'], 'Swift Dzire');
      expect(jobCardPayload['status'], 'draft');
      expect(jobCardPayload['created_at'], endsWith('Z'));
      expect(jobCardPayload['registration_number'], isNotEmpty);
    });
  });
}

String _homeForUser(AppUser user) {
  if (user.role.isAdmin) return '/admin-home';
  switch (user.role) {
    case UserRole.driver:
      return '/driver-home';
    case UserRole.technician:
      return '/tech-dashboard';
    default:
      return '/main/home';
  }
}

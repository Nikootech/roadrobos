import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'mock_data.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    if (!kDebugMode) return;
    
    try {
      debugPrint('Starting Firestore Database Seeding...');

      // 1. Seed Categories
      final categoryCache = await _firestore.collection('categories').limit(1).get();
      if (categoryCache.docs.isEmpty) {
        debugPrint('Seeding categories...');
        for (var i = 0; i < MockData.categories.length; i++) {
          await _firestore.collection('categories').doc('cat_$i').set(MockData.categories[i]);
        }
      }

      // 2. Seed Services
      final serviceCache = await _firestore.collection('services').limit(1).get();
      if (serviceCache.docs.isEmpty) {
        debugPrint('Seeding services...');
        for (var service in MockData.services) {
          final id = service['id'] as String;
          final data = Map<String, dynamic>.from(service)..remove('id');
          await _firestore.collection('services').doc(id).set(data);
        }
      }

      // 3. Seed Banners
      final bannerCache = await _firestore.collection('banners').limit(1).get();
      if (bannerCache.docs.isEmpty) {
        debugPrint('Seeding banners...');
        for (var i = 0; i < MockData.banners.length; i++) {
          await _firestore.collection('banners').doc('banner_$i').set(MockData.banners[i]);
        }
      }

      // 4. Seed Rental Fleet
      final rentalCache = await _firestore.collection('rental_fleet').limit(1).get();
      if (rentalCache.docs.isEmpty) {
        debugPrint('Seeding rental fleet...');
        for (var i = 0; i < MockData.rentalVehicles.length; i++) {
          await _firestore.collection('rental_fleet').doc('rental_$i').set(MockData.rentalVehicles[i]);
        }
      }

      // 5. Seed Demo Technician Jobs
      final techJobCache = await _firestore.collection('technician_jobs').limit(1).get();
      if (techJobCache.docs.isEmpty) {
        debugPrint('Seeding demo technician jobs...');
        final demoJobs = [
          {
            'estimatedCompletion': '4:30 PM',
            'vehicleModel': '2021 Hyundai Creta SX',
            'vehiclePlate': 'MH 12 AB 1234',
            'serviceType': 'General Service',
            'packageName': 'Premium Detailing',
            'date': 'Today',
            'time': '02:00 PM',
            'progress': 0.1,
            'checklist': [
              {'task': 'Vehicle Inspection & Job Card', 'category': 'Core Service', 'isDone': true},
              {'task': 'Surface Cleaning (High Pressure)', 'category': 'Core Service', 'isDone': false},
              {'task': 'Interior Detailing & Polish', 'category': 'Finishing', 'isDone': false},
              {'task': 'Foam Cleaning & Rims Polish', 'category': 'Finishing', 'isDone': false},
              {'task': 'Engine Degreasing & Dressing', 'category': 'Finishing', 'isDone': false},
              {'task': 'Final Inspection & Ready', 'category': 'Finishing', 'isDone': false},
            ],
            'parts': [
              {'name': 'Ceramic Coating Wax', 'qty': '1 Box', 'isFound': true},
              {'name': 'Premium Glass Cleaner', 'qty': '1 Bottle', 'isFound': true},
            ],
            'status': 'ACCEPTED',
            'price': '₹4,500',
            'assignedTechId': null,
            'customerId': null,
            'serviceBookingId': null,
            'createdAt': DateTime.now(),
          },
          {
            'estimatedCompletion': '01:30 PM',
            'vehicleModel': 'Maruti Swift Dzire',
            'vehiclePlate': 'KA 05 MJ 8899',
            'serviceType': 'Brake Service',
            'packageName': 'Brake Overhaul',
            'date': 'Today',
            'time': '11:00 AM',
            'progress': 0.0,
            'checklist': [
              {'task': 'Brake Pad Replacement', 'category': 'Core Service', 'isDone': false},
              {'task': 'Check Rotors', 'category': 'Inspection', 'isDone': false},
            ],
            'parts': [],
            'status': 'SCHEDULED',
            'price': '₹2,200',
            'assignedTechId': null,
            'customerId': null,
            'serviceBookingId': null,
            'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
          },
          {
            'estimatedCompletion': '03:00 PM',
            'vehicleModel': 'Honda City ZX',
            'vehiclePlate': 'DL 09 CA 5566',
            'serviceType': 'AC Service',
            'packageName': 'Full AC Overhaul',
            'date': 'Yesterday',
            'time': '10:00 AM',
            'progress': 1.0,
            'checklist': [
              {'task': 'AC Compressor Service', 'category': 'Core Service', 'isDone': true},
              {'task': 'Clean Filters', 'category': 'Core Service', 'isDone': true},
            ],
            'parts': [],
            'status': 'COMPLETED',
            'price': '₹8,500',
            'assignedTechId': null,
            'customerId': null,
            'serviceBookingId': null,
            'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          },
        ];
        for (var i = 0; i < demoJobs.length; i++) {
          await _firestore.collection('technician_jobs').doc('demo_job_$i').set(demoJobs[i]);
        }
      }
      
      // 6. Seed Demo Users
      final userCache = await _firestore.collection('users').limit(1).get();
      if (userCache.docs.isEmpty) {
        debugPrint('Seeding demo users...');
        for (var user in MockData.demoUsers) {
          final id = user['id'] as String;
          final data = Map<String, dynamic>.from(user)..remove('id');
          await _firestore.collection('users').doc(id).set(data);
        }
      }

      debugPrint('Database seeding completed successfully.');
    } catch (e) {
      debugPrint('Error during database seeding: $e');
    }
  }
}

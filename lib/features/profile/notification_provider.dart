import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import '../rentals/rental_providers.dart';

class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final bool isRead;
  final String? type; // 'rental_completion', 'offer', etc.

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.isRead = false,
    this.type,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      icon: icon,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier(this.ref) : super([]) {
    // Listen to rental state changes
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed && previous?.status != RentalStatus.completed) {
        _addRentalCompletionNotification(next!.vehicle['name'] ?? 'Vehicle');
      }
    });
  }

  final Ref ref;

  void _addRentalCompletionNotification(String vehicleName) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Rental Completed',
      description: 'Your rental time for $vehicleName has ended. Please complete payment and confirm drop-off.',
      timestamp: DateTime.now(),
      icon: Iconsax.timer_1,
      type: 'rental_completion',
    );
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier(ref);
});

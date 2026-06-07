// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/notification_repository.dart';
import '../profile/user_provider.dart';

class AppNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final bool isRead;
  final String? type;

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
  final Ref ref;
  StreamSubscription? _subscription;
  
  NotificationNotifier(this.ref) : super([]) {
    _listenToNotifications();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenToNotifications() {
    final user = ref.watch(userProvider).user;
    if (user == null) return;

    _subscription?.cancel();
    _subscription = ref.read(notificationRepositoryProvider).watchNotifications(user.id).listen((models) {
      state = models.map((m) => AppNotification(
        id: m.id,
        title: m.title,
        description: m.description,
        timestamp: m.timestamp,
        icon: _getIconForType(m.type),
        isRead: m.isRead,
        type: m.type,
      )).toList();
      
      // Fallback if empty (keep welcome message for new users)
      if (state.isEmpty) {
        _addWelcomeNotification();
      }
    });
  }


  void _addWelcomeNotification() {
    state = [
      AppNotification(
        id: 'welcome',
        title: 'Welcome to RoAd RoBo\'s!',
        description: 'Thank you for joining us. Book your first ride or service and get 20% off!',
        timestamp: DateTime.now(),
        icon: Icons.celebration_rounded,
      ),
    ];
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'rental': return Icons.car_rental;
      case 'service': return Icons.build;
      case 'ride': return Icons.local_taxi;
      case 'wallet': return Icons.account_balance_wallet;
      default: return Icons.notifications_active;
    }
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(userProvider).user;
    if (user != null) {
      await ref.read(notificationRepositoryProvider).markAllAsRead(user.id);
    }
  }

  void clearAll() {
    state = [];
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier(ref);
});

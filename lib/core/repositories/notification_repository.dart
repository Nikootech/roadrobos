import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Notification',
      description: map['description'] ?? '',
      timestamp: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      type: map['type'],
    );
  }
}

class NotificationRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    // This is a placeholder since the table might not exist yet.
    // If it fails, it will return an empty list or mock data.
    try {
      return _supabase
          .from('user_notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at')
          .map((data) =>
              data.map((map) => NotificationModel.fromMap(map)).toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('user_notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('user_notifications')
          .update({'is_read': true}).eq('user_id', userId);
    } catch (e) {
      // Handle error
    }
  }
}

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository());

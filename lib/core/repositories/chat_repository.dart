import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, (String, String)>((ref, arg) {
  final roomId = arg.$1;
  return ref.watch(chatRepositoryProvider).watchMessages(roomId);
});

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Watch messages stream for a specific room using Realtime
  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((list) => list
            .map((map) => ChatMessage.fromMap(map, map['id'].toString()))
            .toList());
  }

  /// Send a message
  Future<void> sendMessage(ChatMessage message) async {
    final cleanReceiverId = message.receiverId == 'support'
        ? '00000000-0000-0000-0000-000000000000'
        : message.receiverId;

    // 1. Ensure the chat room exists in chat_rooms table before inserting a message
    try {
      await _supabase.from('chat_rooms').upsert({
        'id': message.roomId,
        'participants': [message.senderId, cleanReceiverId],
        'last_message': message.message,
        'last_timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error upserting chat_rooms: $e');
    }

    // 2. Insert the message into chat_messages
    final messageData = message.toMap()..remove('receiver_id');
    await _supabase.from('chat_messages').insert(messageData);

    // 3. Dispatch notifications for support managers or clients in real-time
    try {
      if (cleanReceiverId == '00000000-0000-0000-0000-000000000000' || message.roomId.contains('_support')) {
        // Customer -> Support: notify all support managers
        if (cleanReceiverId == '00000000-0000-0000-0000-000000000000') {
          // Fetch sender's profile name
          final senderProfile = await _supabase
              .from('profiles')
              .select('name')
              .eq('id', message.senderId)
              .maybeSingle();
          final senderName = senderProfile?['name'] ?? 'User';

          // Fetch all support managers
          final managers = await _supabase
              .from('profiles')
              .select('id')
              .eq('role', 'support_manager');

          if (managers.isNotEmpty) {
            for (final manager in managers) {
              final managerId = manager['id'];
              await _supabase.from('user_notifications').insert({
                'user_id': managerId,
                'title': 'New Support Message',
                'description': 'From $senderName: ${message.message}',
                'type': 'chat_message',
                'is_read': false,
              });
            }
          }
        } else {
          // Support Manager -> Customer reply (since roomId contains _support but receiver is customer, not support UUID)
          final senderProfile = await _supabase
              .from('profiles')
              .select('name')
              .eq('id', message.senderId)
              .maybeSingle();
          final senderName = senderProfile?['name'] ?? 'Support Agent';

          await _supabase.from('user_notifications').insert({
            'user_id': message.receiverId,
            'title': 'Support Update',
            'description': '$senderName: ${message.message}',
            'type': 'chat_message',
            'is_read': false,
          });
        }
      }
    } catch (e) {
      debugPrint('Error sending support notification: $e');
    }
  }

  /// Send an automated system message to the chat
  Future<void> sendSystemMessage(String roomId, String text) async {
    try {
      await _supabase.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': 'system',
        'message': text,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'is_read': true,
      });
    } catch (e) {
      debugPrint('Error sending system message: $e');
    }
  }

  /// Submit user feedback/rating for the chat support session
  Future<void> submitFeedback(String roomId, String? userId, int rating, String comment) async {
    try {
      await _supabase.from('chat_feedback').insert({
        'room_id': roomId,
        'user_id': userId == 'demo' ? null : userId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error submitting chat feedback: $e');
    }
  }

  /// Complete data wipe of messages and room from database
  Future<void> wipeChatData(String roomId) async {
    try {
      // 1. Delete all messages for this room
      await _supabase.from('chat_messages').delete().eq('room_id', roomId);
      // 2. Delete the room itself
      await _supabase.from('chat_rooms').delete().eq('id', roomId);
    } catch (e) {
      debugPrint('Error wiping chat data: $e');
    }
  }
}

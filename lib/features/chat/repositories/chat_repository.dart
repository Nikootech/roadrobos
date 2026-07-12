import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  bool _isValidUuid(String str) {
    if (str.isEmpty) return false;
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str);
  }

  // Send a message
  Future<void> sendMessage({
    required String bookingId,
    required String receiverId,
    required String content,
  }) async {
    if (bookingId.isEmpty || !_isValidUuid(bookingId)) {
      throw ArgumentError('Cannot send message: invalid or empty bookingId');
    }
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) throw Exception('User not authenticated');

    await _supabase.from('messages').insert({
      'booking_id': bookingId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  // Stream messages for a specific booking
  Stream<List<ChatMessage>> streamMessages(String bookingId) {
    if (bookingId.isEmpty || !_isValidUuid(bookingId)) {
      return Stream.value(<ChatMessage>[]);
    }
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at')
        .map((data) => data.map((e) => ChatMessage.fromJson(e)).toList());
  }

  // Get older message history for pagination
  Future<List<ChatMessage>> getMessageHistory({
    required String bookingId,
    required int limit,
    required int offset,
  }) async {
    if (bookingId.isEmpty || !_isValidUuid(bookingId)) {
      return <ChatMessage>[];
    }
    final response = await _supabase
        .from('messages')
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  // Mark messages as read for a specific booking
  Future<void> markRead(String bookingId) async {
    if (bookingId.isEmpty || !_isValidUuid(bookingId)) return;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('booking_id', bookingId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  // Stream unread message count across all bookings for the current user
  Stream<int> streamUnreadCount() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .map((data) => data.where((e) => e['is_read'] == false).length);
  }
}

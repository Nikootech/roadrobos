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
        .from('chat')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((list) => list
            .map((map) => ChatMessage.fromMap(map, map['id'].toString()))
            .toList());
  }

  /// Send a message
  Future<void> sendMessage(ChatMessage message) async {
    await _supabase.from('chat').insert(message.toMap());
  }
}

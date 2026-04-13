import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, (String, String)>((ref, ids) {
  final (id1, id2) = ids;
  return ref.watch(chatRepositoryProvider).getMessages(id1, id2);
});

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get message stream for a specific conversation
  Stream<List<ChatMessage>> getMessages(String userId, String otherId) {
    final roomId = _getConversationId(userId, otherId);
    
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
    // Ensure room exists first
    await _supabase.from('chat_rooms').upsert({
      'id': message.roomId,
      'participants': [message.senderId, message.receiverId],
      'last_message': message.message,
      'last_timestamp': DateTime.now().toIso8601String(),
    });
    
    await _supabase.from('chat_messages').insert(message.toMap());
  }

  String _getConversationId(String id1, String id2) {
    final list = [id1, id2];
    list.sort();
    return list.join('_');
  }
}

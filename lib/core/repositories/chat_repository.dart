import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get message stream for a specific conversation
  Stream<List<ChatMessage>> getMessages(String userId, String driverId) {
    // Generate a consistent conversation ID
    final conversationId = _getConversationId(userId, driverId);
    
    return _db
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Send a message
  Future<void> sendMessage(ChatMessage message) async {
    final conversationId = _getConversationId(message.senderId, message.receiverId);
    
    final chatDoc = _db.collection('chats').doc(conversationId);
    
    await chatDoc.collection('messages').add(message.toMap());
    
    // Update top-level chat doc with last message info for list views
    await chatDoc.set({
      'lastMessage': message.message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': [message.senderId, message.receiverId],
    }, SetOptions(merge: true));
  }

  String _getConversationId(String id1, String id2) {
    final list = [id1, id2];
    list.sort();
    return list.join('_');
  }
}

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, (String, String)>((ref, ids) {
  final roomId = ids.$1;
  final userId = ids.$2;
  // If roomId contains an underscore, it's likely already a conversation ID
  // Otherwise, we might need more context. For now, we assume simple room IDs.
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList());
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final unreadMessagesCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  // Re-run the stream if auth state changes
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value(0);
  }
  return repository.streamUnreadCount();
});

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 30;

  RealtimeChannel? _chatChannel;
  RealtimeChannel? _presenceChannel;
  bool _isTyping = false;
  bool _isReceiverTyping = false;
  Timer? _typingTimer;

  late final ChatRepository _chatRepository;

  bool _isValidUuid(String str) {
    if (str.isEmpty) return false;
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str);
  }

  @override
  void initState() {
    super.initState();
    _chatRepository = ref.read(chatRepositoryProvider);
    _loadInitialMessages();
    _setupRealtime();
    _setupPresence();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatChannel?.unsubscribe();
    _presenceChannel?.unsubscribe();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) {
      setState(() {
        _messages = [];
        _isLoading = false;
        _hasMore = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final messages = await _chatRepository.getMessageHistory(
        bookingId: widget.bookingId,
        limit: _limit,
        offset: 0,
      );
      setState(() {
        _messages = messages;
        _offset = messages.length;
        _hasMore = messages.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _loadEarlierMessages() async {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) return;
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final olderMessages = await _chatRepository.getMessageHistory(
        bookingId: widget.bookingId,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _messages.addAll(
            olderMessages); // Append to the end of the list (older messages)
        _offset += olderMessages.length;
        _hasMore = olderMessages.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtime() {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) return;
    _chatChannel = Supabase.instance.client
        .channel('public:messages:booking_id=eq.${widget.bookingId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: widget.bookingId,
          ),
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            setState(() {
              // Insert at the beginning (index 0 is the newest since we use reverse: true)
              _messages.insert(0, newMessage);
              _offset++;
            });
            if (newMessage.receiverId ==
                Supabase.instance.client.auth.currentUser?.id) {
              _markAsRead();
            }
          },
        )
        .subscribe();
  }

  void _setupPresence() {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _presenceChannel =
        Supabase.instance.client.channel('presence:chat:${widget.bookingId}');

    _presenceChannel?.onPresenceSync((payload) {
      final presenceState = _presenceChannel?.presenceState();
      bool receiverTyping = false;

      if (presenceState != null) {
        for (var state in presenceState) {
          for (var presence in state.presences) {
            if (presence.payload['user_id'] == widget.receiverId &&
                presence.payload['is_typing'] == true) {
              receiverTyping = true;
            }
          }
        }
      }

      if (mounted && _isReceiverTyping != receiverTyping) {
        setState(() {
          _isReceiverTyping = receiverTyping;
        });
      }
    }).subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _presenceChannel?.track({'user_id': userId, 'is_typing': false});
      }
    });
  }

  void _onTyping(String text) {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) return;
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _presenceChannel?.track({
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'is_typing': true,
      });
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      _presenceChannel?.track({
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'is_typing': false,
      });
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping && mounted) {
        _isTyping = false;
        _presenceChannel?.track({
          'user_id': Supabase.instance.client.auth.currentUser?.id,
          'is_typing': false,
        });
      }
    });
  }

  Future<void> _markAsRead() async {
    if (widget.bookingId.isEmpty || !_isValidUuid(widget.bookingId)) return;
    try {
      await _chatRepository.markRead(widget.bookingId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _onTyping('');

    try {
      await _chatRepository.sendMessage(
        bookingId: widget.bookingId,
        receiverId: widget.receiverId,
        content: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName),
            if (_isReceiverTyping)
              const Text(
                'Typing...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_hasMore)
              TextButton(
                onPressed: _loadEarlierMessages,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Load earlier'),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // Show bottom to top
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == currentUserId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: isMe ? const Radius.circular(0) : null,
                          bottomLeft: !isMe ? const Radius.circular(0) : null,
                        ),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTyping,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

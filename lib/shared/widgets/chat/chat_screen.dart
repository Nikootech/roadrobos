import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/repositories/chat_repository.dart';
import '../../../core/models/chat_message.dart';
import '../../../features/profile/user_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String otherPartyName;

  const ChatScreen({
    super.key,
    required this.roomId,
    this.otherPartyName = 'Support Agent',
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  Timer? _busyMessageTimer;
  Timer? _closeChatTimer;
  bool _showingFeedback = false;
  int _selectedRating = 5;
  final _feedbackCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
  }

  void _setupMessageListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messagesStream = ref.read(chatRepositoryProvider).watchMessages(widget.roomId);
      _messagesSubscription = messagesStream.listen((messages) {
        _onMessagesUpdated(messages);
      });
    });
  }

  void _onMessagesUpdated(List<ChatMessage> messages) {
    if (messages.isEmpty) return;

    final currentUserId = ref.read(userProvider).user?.id ?? 'demo';
    final lastMessage = messages.last;

    // Check if the last message is sent by the customer (me)
    if (lastMessage.senderId == currentUserId) {
      _closeChatTimer?.cancel();
      _busyMessageTimer?.cancel();
      _busyMessageTimer = Timer(const Duration(minutes: 2), () {
        _sendAutomatedBusyMessage();
      });
    } else if (lastMessage.senderId == 'system') {
      _busyMessageTimer?.cancel();
      _closeChatTimer?.cancel();
      _closeChatTimer = Timer(const Duration(minutes: 1), () {
        _showFeedbackSheet();
      });
    } else {
      // Support agent/manager replied! Cancel all timers
      _busyMessageTimer?.cancel();
      _closeChatTimer?.cancel();
    }
  }

  Future<void> _sendAutomatedBusyMessage() async {
    await ref.read(chatRepositoryProvider).sendSystemMessage(
      widget.roomId,
      'All agents are currently busy. For immediate assistance, please call us at +919844991225.',
    );
  }

  void _showFeedbackSheet() {
    if (_showingFeedback) return;
    setState(() {
      _showingFeedback = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chat Session Closed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We hope we were able to assist you. Please rate your experience below.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Star Rating Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 40,
                          color: AppColors.accentAmber,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _selectedRating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Comment input box
                  TextField(
                    controller: _feedbackCommentController,
                    decoration: InputDecoration(
                      hintText: 'Any comments or feedback? (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleSubmitFeedback(skip: true),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleSubmitFeedback(skip: false),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSubmitFeedback({required bool skip}) async {
    final currentUserId = ref.read(userProvider).user?.id ?? 'demo';
    
    // Close bottom sheet
    Navigator.pop(context);

    if (!skip) {
      // Submit feedback to DB
      await ref.read(chatRepositoryProvider).submitFeedback(
        widget.roomId,
        currentUserId,
        _selectedRating,
        _feedbackCommentController.text.trim(),
      );
    }

    // Complete data wipe
    await ref.read(chatRepositoryProvider).wipeChatData(widget.roomId);

    // Return to the previous screen (e.g. Profile)
    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _busyMessageTimer?.cancel();
    _closeChatTimer?.cancel();
    _messageController.dispose();
    _feedbackCommentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = ref.read(userProvider).user?.id ?? 'demo';
    
    // Extract receiver ID assuming roomId format is "id1_id2" and one is currentUser
    final ids = widget.roomId.split('_');
    final receiverId = ids.firstWhere((id) => id != currentUserId, orElse: () => 'support');

    final message = ChatMessage(
      id: '',
      roomId: widget.roomId,
      senderId: currentUserId,
      receiverId: receiverId,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    ref.read(chatRepositoryProvider).sendMessage(message);
    _messageController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userProvider.select((s) => s.user?.id)) ?? 'demo';
    final messagesStream = ref.watch(chatRepositoryProvider).watchMessages(widget.roomId);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryBlue, size: 20),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherPartyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary),
            onPressed: () async {
              String phoneNumber = '+919844991225'; // Fallback support hotline
              try {
                final response = await Supabase.instance.client
                    .from('profiles')
                    .select('phone')
                    .eq('role', 'support_manager')
                    .not('phone', 'is', null)
                    .limit(1)
                    .maybeSingle();

                if (response != null &&
                    response['phone'] != null &&
                    response['phone'].toString().trim().isNotEmpty) {
                  phoneNumber = response['phone'].toString().trim();
                }
              } catch (e) {
                debugPrint('Error fetching support manager phone: $e');
              }

              final Uri url = Uri(scheme: 'tel', path: phoneNumber);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch dialer')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.message_text, size: 64, color: AppColors.textMuted.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        const Text('No messages yet. Say hi!', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Reverse index because we render bottom-up
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message, currentUserId);
                  },
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
                  child: const Icon(Icons.attachment_rounded, color: AppColors.textSecondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, String currentUserId) {
    final isMe = message.senderId == currentUserId;
    final isSystem = message.senderId == 'system';

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.accentOrange, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryBlue, size: 12),
            ),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: isMe ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Text(message.message, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : AppColors.textPrimary, height: 1.4)),
            ),
          ),
          
          if (isMe)
             const SizedBox(width: 8)
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

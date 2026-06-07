import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/repositories/chat_repository.dart';
import '../../profile/user_provider.dart';
import '../../../core/models/chat_message.dart';
import '../../../navigation/nav_helpers.dart';

class InAppChatScreen extends ConsumerStatefulWidget {
  final String peerName;
  final String chatRoomId;
  const InAppChatScreen({
    super.key, 
    this.peerName = 'Rajesh Kumar',
    this.chatRoomId = 'demo-room-1',
  });

  @override
  ConsumerState<InAppChatScreen> createState() => _InAppChatScreenState();
}

class _InAppChatScreenState extends ConsumerState<InAppChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final userId = ref.read(userProvider).user?.id ?? 'demo';
    ref.read(chatRepositoryProvider).sendMessage(ChatMessage(
      id: '',
      roomId: widget.chatRoomId,
      senderId: userId,
      receiverId: 'driver_id', 
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    ));
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider.select((s) => s.user?.id)) ?? 'demo';
    final messagesAsync = ref.watch(chatMessagesProvider((widget.chatRoomId, userId)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.successGreen),
                    SizedBox(width: 4),
                    Text('Online', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Iconsax.call, color: AppColors.primaryBlue), onPressed: () async {
            final Uri url = Uri(scheme: 'tel', path: '+18005550199');
            try {
              final success = await launchUrl(url);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
              }
            }
          }),        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == userId;
                  return _buildChatBubble(
                    msg.message, 
                    isMe, 
                    DateFormat('hh:mm a').format(msg.timestamp)
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading messages: $err')),
            ),
          ),
          
          // Quick Replies
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickReply('I\'m coming!'),
                _buildQuickReply('Okay, wait.'),
                _buildQuickReply('Call me.'),
                _buildQuickReply('Location shared.'),
              ],
            ),
          ),
          
          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
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
                    child: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : AppColors.bgLightGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(color: isMe ? Colors.white70 : AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: isMe ? 0.1 : -0.1, end: 0),
    );
  }

  Widget _buildQuickReply(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        onPressed: () {
          // Fix: Call the repository instead of modifying a non-existent local list
          final userId = ref.read(userProvider).user?.id ?? 'demo';
          ref.read(chatRepositoryProvider).sendMessage(ChatMessage(
            id: '',
            roomId: widget.chatRoomId,
            senderId: userId,
            receiverId: 'driver_id',
            message: text,
            timestamp: DateTime.now(),
          ));
          NavHelpers.showSuccess(context, 'Sent: $text');
        },
      ),
    );
  }
}


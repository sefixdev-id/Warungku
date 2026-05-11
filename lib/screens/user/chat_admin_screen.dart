import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/helpers/date_helper.dart';
import '../../models/chat_message_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/status_chip.dart';

class ChatAdminScreen extends StatefulWidget {
  const ChatAdminScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ChatAdminScreen> createState() => _ChatAdminScreenState();
}

class _ChatAdminScreenState extends State<ChatAdminScreen> {
  final _message = TextEditingController();
  final _chatService = ChatService();
  late final Future<String> _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = _chatService.getOrCreateUserChat(widget.user);
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send(String chatId) async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    _message.clear();
    await _chatService.sendMessage(
      chatId: chatId,
      sender: widget.user,
      receiverId: AppConstants.mainAdminId,
      message: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Admin',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Menu',
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _chatId,
        builder: (context, snapshot) {
          final chatId = snapshot.data;
          if (chatId == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Warungku',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                SizedBox(height: 4),
                                StatusChip(
                                  label: 'Online',
                                  color: AppColors.success,
                                  icon: Icons.circle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ChatMessageModel>>(
                      stream: _chatService.watchMessages(chatId),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? const [];
                        if (messages.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              ChatBubble(
                                message: 'Bang, stok minyak ada?',
                                mine: true,
                                time: '10.21',
                              ),
                              ChatBubble(
                                message:
                                    'Ada, stok minyak goreng kemasan 1L masih tersedia.',
                                mine: false,
                                time: '10.22',
                              ),
                              ChatBubble(
                                message: 'Harga berapa Bang?',
                                mine: true,
                                time: '10.23',
                              ),
                              ChatBubble(
                                message: 'Rp 18.000 kak per 1L.',
                                mine: false,
                                time: '10.23',
                              ),
                              ChatBubble(
                                message: 'Siap, nanti saya ambil ya Bang',
                                mine: true,
                                time: '10.24',
                              ),
                            ],
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) => ChatBubble(
                            message: messages[index].message,
                            mine: messages[index].senderId == widget.user.id,
                            time: formatDate(messages[index].createdAt),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _message,
                              decoration: const InputDecoration(
                                hintText: 'Ketik pesan...',
                                prefixIcon: Icon(Icons.chat_bubble_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: IconButton.filled(
                              onPressed: () => _send(chatId),
                              icon: const Icon(Icons.send),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';

class AdminChatDetailScreen extends StatefulWidget {
  const AdminChatDetailScreen({
    super.key,
    required this.admin,
    required this.chat,
  });

  final UserModel admin;
  final ChatModel chat;

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final _message = TextEditingController();
  final _service = ChatService();

  @override
  void initState() {
    super.initState();
    _service.markAdminRead(widget.chat.chatId);
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    _message.clear();
    await _service.sendMessage(
      chatId: widget.chat.chatId,
      sender: widget.admin,
      receiverId: widget.chat.userId,
      message: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.userName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _service.watchMessages(widget.chat.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = message.senderId == widget.admin.id;
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: mine
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: mine
                              ? null
                              : Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          message.message,
                          style: TextStyle(color: mine ? Colors.white : null),
                        ),
                      ),
                    );
                  },
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
                        hintText: 'Balas pesan',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

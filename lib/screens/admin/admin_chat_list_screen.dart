import 'package:flutter/material.dart';

import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'admin_chat_detail_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key, required this.admin});

  final UserModel admin;

  @override
  Widget build(BuildContext context) {
    final service = ChatService();
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Pelanggan')),
      body: StreamBuilder<List<ChatModel>>(
        stream: service.watchChats(),
        builder: (context, snapshot) {
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const EmptyStateWidget(message: 'Belum ada chat pelanggan');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    chat.userName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${chat.userPhone}\n${chat.lastMessage}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: chat.unreadAdmin > 0
                      ? Badge(label: Text('${chat.unreadAdmin}'))
                      : null,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminChatDetailScreen(admin: admin, chat: chat),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

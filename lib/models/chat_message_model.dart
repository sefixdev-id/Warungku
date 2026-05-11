import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String receiverId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data() ?? {};
    final timestamp = json['createdAt'];
    return ChatMessageModel(
      messageId: json['messageId']?.toString() ?? doc.id,
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? 'user',
      receiverId: json['receiverId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }
}

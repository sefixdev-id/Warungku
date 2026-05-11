import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  const ChatModel({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.adminId,
    required this.adminName,
    required this.lastMessage,
    required this.unreadAdmin,
    required this.unreadUser,
  });

  final String chatId;
  final String userId;
  final String userName;
  final String userPhone;
  final String adminId;
  final String adminName;
  final String lastMessage;
  final int unreadAdmin;
  final int unreadUser;

  factory ChatModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};
    return ChatModel(
      chatId: json['chatId']?.toString() ?? doc.id,
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',
      adminId: json['adminId']?.toString() ?? '',
      adminName: json['adminName']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      unreadAdmin: int.tryParse(json['unreadAdmin']?.toString() ?? '') ?? 0,
      unreadUser: int.tryParse(json['unreadUser']?.toString() ?? '') ?? 0,
    );
  }
}

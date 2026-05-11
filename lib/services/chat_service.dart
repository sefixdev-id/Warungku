import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String buildChatId(String userId, String adminId) =>
      'chat_${userId}_$adminId';

  Future<String> getOrCreateUserChat(UserModel user) async {
    final chatId = buildChatId(user.id, AppConstants.mainAdminId);
    final doc = _firestore.collection('chats').doc(chatId);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'chatId': chatId,
        'userId': user.id,
        'userName': user.name,
        'userPhone': user.phone,
        'adminId': AppConstants.mainAdminId,
        'adminName': AppConstants.mainAdminName,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadAdmin': 0,
        'unreadUser': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Stream<List<ChatModel>> watchChats() {
    return _firestore
        .collection('chats')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatModel.fromFirestore).toList());
  }

  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(ChatMessageModel.fromFirestore).toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required UserModel sender,
    required String receiverId,
    required String message,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();
    await _firestore.runTransaction((transaction) async {
      transaction.set(messageRef, {
        'messageId': messageRef.id,
        'chatId': chatId,
        'senderId': sender.id,
        'senderName': sender.name,
        'senderRole': sender.role,
        'receiverId': receiverId,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      transaction.update(chatRef, {
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (sender.isAdmin) 'unreadUser': FieldValue.increment(1),
        if (!sender.isAdmin) 'unreadAdmin': FieldValue.increment(1),
      });
    });
  }

  Future<void> markAdminRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({'unreadAdmin': 0});
  }
}

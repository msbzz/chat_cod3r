import 'package:chat_cod3r/core/models/chat_message.dart';
import 'package:chat_cod3r/core/models/chat_user.dart';
import 'package:chat_cod3r/core/services/chat/chat_firebase_service.dart';
//import 'package:chat_cod3r/core/services/chat/chat_mock_service.dart';

abstract class ChatService {
  Stream<List<ChatMessage>> messagesStream();
  Future<ChatMessage?> save(String texto, ChatUser user);

  factory ChatService() {
    return ChatFirebaseService();
    //return ChatMockService();
  }
}

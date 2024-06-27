import 'dart:async';
import 'package:chat_cod3r/core/models/chat_message.dart';
import 'package:chat_cod3r/core/models/chat_user.dart';
import 'package:chat_cod3r/core/services/chat/chat_service.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatFirebaseService implements ChatService {
  @override
  Stream<List<ChatMessage>> messagesStream() {
    final Query dbQuery = FirebaseDatabase.instance.ref()
    .child('chat')
    .orderByChild('createdAt');

    return dbQuery.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        return [];
      }

      final messages = data.entries.map((e) {
        final value = e.value as Map<dynamic, dynamic>;
        return ChatMessage(
          id: e.key,
          text: value['text'] as String,
          createdAt: DateTime.parse(value['createdAt'] as String),
          userId: value['userId'] as String,
          userName: value['userName'] as String,
          userImageUrl: value['userImageUrl'] as String,
        );
      }).toList();

      // Inverte a lista para ordem decrescente
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return messages;
    });
  }

  @override
  Future<ChatMessage?> save(String text, ChatUser user) async {
    final DatabaseReference db = FirebaseDatabase.instance.ref();

    final messageData = {
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'userId': user.id,
      'userName': user.name,
      'userImageUrl': user.imageUrl,
    };

    final newMessageRef = db.child('chat').push();
    await newMessageRef.set(messageData);

    final doc = await newMessageRef.get();
    /**
     *  O método get() retorna um DataSnapshot, 
     *  então usamos value para acessar os dados 
     *  e os convertemos para um 
     *  mapa de Map<dynamic, dynamic>.
     */
    final data = doc.value as Map<dynamic, dynamic>;

    return ChatMessage(
      id: newMessageRef.key!,
      text: data['text'],
      createdAt: DateTime.parse(data['createdAt']),
      userId: data['userId'],
      userName: data['userName'],
      userImageUrl: data['userImageUrl'],
    );
  }
}

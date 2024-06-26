import 'dart:io';
import 'dart:async';
import 'package:chat_cod3r/core/models/chat_user.dart';
import 'package:chat_cod3r/core/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthFirebaseService implements AuthService {
  static ChatUser? _currentUser;
  static final _userStream = Stream<ChatUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toChatUser(user);
      controller.add(_currentUser);
    }
  });

  @override
  ChatUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<ChatUser?> get userChanges {
    return _userStream;
  }

  @override
  Future<void> signup(
    String name,
    String email,
    String password,
    File? image,
  ) async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        //print('User creation failed');
        return;
      }

      // 1. Upload da foto do usuário
      final imageName = '${credential.user!.uid}.jpg';
      final imageURL = await _uploadUserImage(image, imageName);

      if (imageURL == null) {
        print('Image upload failed or no image provided');
        return;
      }

      // 2. Atualizar os atributos do usuário
      await credential.user?.updateDisplayName(name);
      await credential.user?.updatePhotoURL(imageURL);

      // 3. Salvar usuário no banco de dados
      await _saveChatUser(_toChatUser(credential.user!, name, imageURL));

      // 4. Forçar a recarga do usuário para garantir que as informações atualizadas estejam disponíveis
      await credential.user?.reload();
      _currentUser = _toChatUser(credential.user!, name, imageURL);

      //print('User profile updated with name: $name and imageURL: $imageURL');
    } catch (e) {
      //print('Signup error: $e');
    }
  }

  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;

    try {
      final storage = FirebaseStorage.instance;
      final imageRef = storage.ref().child('user_images').child(imageName);

      await imageRef.putFile(image).whenComplete(() {}).catchError((e) {
        print('Error during putFile: $e');
      });

      final downloadURL = await imageRef.getDownloadURL();
      print('Image uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      //print('Error in _uploadUserImage: $e');
      return null;
    }
  }

  Future<void> _saveChatUser(ChatUser user) async {
    try {
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      await db.child('users').child(user.id).set({
        'name': user.name,
        'email': user.email,
        'imageUrl': user.imageUrl,
      });
      //print('User saved successfully');
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  static ChatUser _toChatUser(User user, [String? name, String? imageUrl]) {
    return ChatUser(
      id: user.uid,
      name: name ?? user.displayName ?? user.email!.split('@')[0],
      email: user.email!,
      imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
    );
  }
}

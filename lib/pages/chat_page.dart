import 'package:chat_cod3r/components/messages.dart';
import 'package:chat_cod3r/components/new_message.dart';
import 'package:chat_cod3r/core/services/auth/auth_service.dart';
import 'package:chat_cod3r/core/services/notification/chat_notification_service.dart';
import 'package:chat_cod3r/pages/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  
  const ChatPage({super.key});
 
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  
  @override
  void initState() {
    super.initState();

    // Obtenha a instância do ChatNotificationService e chame getDeviceToken
    Future.microtask(() {
      //final chatNotificationService = Provider.of<ChatNotificationService>(context, listen: false);
      ChatNotificationService.getDeviceToken();
    });
  }

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cod3r Chat'),
        backgroundColor: Colors.amber,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 10),
                      Text('Sair'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'logout') {
                  AuthService().logout();
                }
              },
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) {
                      return const NotificationPage();
                    }),
                  );
                },
              ),
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  maxRadius: 10,
                  backgroundColor: Colors.red.shade800,
                  child: Text(
                    '${Provider.of<ChatNotificationService>(context).itemsCount}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: const [
            Expanded(child: Messages()),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}

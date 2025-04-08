import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatService(),
      child: MaterialApp(
        title: 'Real-time Chat',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: '/',
        routes: {'/': (context) => const LoginScreen()},
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final username = settings.arguments as String;
            return MaterialPageRoute(
              builder:
                  (context) => ChatScreen(
                    username: username,
                    // Connect to our local server
                    serverUrl: 'ws://127.0.0.1:8765',
                  ),
            );
          }
          return null;
        },
      ),
    );
  }
}

// For testing two users in the same app (dual view)
class DualChatScreen extends StatelessWidget {
  const DualChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two Users Demo')),
      body: Column(
        children: [
          Expanded(
            child: ChangeNotifierProvider(
              create: (context) => ChatService(),
              child: const ChatScreen(
                username: 'User1',
                serverUrl: 'ws://127.0.0.1:8765',
              ),
            ),
          ),
          const Divider(height: 2, thickness: 2),
          Expanded(
            child: ChangeNotifierProvider(
              create: (context) => ChatService(),
              child: const ChatScreen(
                username: 'User2',
                serverUrl: 'ws://127.0.0.1:8765',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

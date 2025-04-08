import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String serverUrl;

  const ChatScreen({
    super.key,
    required this.username,
    required this.serverUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatService _chatService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    // Get the chat service
    _chatService = Provider.of<ChatService>(context, listen: false);

    // Set the current user
    _chatService.currentUser = widget.username;

    // Connect to WebSocket server
    _chatService.connect(widget.serverUrl);
  }

  @override
  void dispose() {
    // Disconnect from WebSocket server
    _chatService.disconnect();

    // Dispose of the controller
    _messageController.dispose();

    super.dispose();
  }

  // Send a message
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _chatService.sendMessage(text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatService>(
          builder: (context, chatService, child) {
            _isConnected = chatService.isConnected;
            return Row(
              children: [
                Text('Chat (${widget.username})'),
                const SizedBox(width: 8),
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _chatService.disconnect();
              _chatService.connect(widget.serverUrl);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages (in reverse order - newest at top)
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                final messages = chatService.messages;

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  reverse: true, // Display latest messages at the top
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = message.sender == widget.username;

                    return MessageBubble(
                      message: message,
                      isMyMessage: isMyMessage,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send button
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

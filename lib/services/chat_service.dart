import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chat_message.dart';

/// ChatService manages WebSocket communication for the chat application.
///
/// This service is responsible for:
/// 1. Establishing and maintaining a WebSocket connection
/// 2. Sending messages to the server
/// 3. Processing incoming messages and history
/// 4. Managing connection state
/// 5. Notifying the UI about new messages and state changes
///
/// It uses the ChangeNotifier mixin for state management, allowing UI components
/// to rebuild when the chat state changes.
class ChatService with ChangeNotifier {
  // WebSocket channel
  WebSocketChannel? _channel;

  // Messages list (reverse order - newest first)
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // Current user
  String _currentUser = '';
  String get currentUser => _currentUser;
  set currentUser(String user) {
    _currentUser = user;
    notifyListeners();
  }

  // Connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Connects to a WebSocket server at the specified URL.
  ///
  /// This method:
  /// 1. Establishes a WebSocket connection to the provided [serverUrl]
  /// 2. Sets up listeners for incoming messages, connection close, and errors
  /// 3. Updates the connection status and notifies listeners
  ///
  /// If the connection fails, the error is caught, the connection status
  /// is set to false, and debug information is logged.
  ///
  /// @param serverUrl The WebSocket server URL (e.g., ws://127.0.0.1:8765)
  void connect(String serverUrl) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;

      // Listen for incoming messages
      _channel!.stream.listen(
        (dynamic message) {
          _handleIncomingMessage(message);
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();

          if (kDebugMode) {
            print('WebSocket disconnected');
          }
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();

          if (kDebugMode) {
            print('WebSocket error: $error');
          }
        },
      );

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();

      if (kDebugMode) {
        print('Could not connect to WebSocket: $e');
      }
    }
  }

  /// Disconnects from the WebSocket server.
  ///
  /// This method:
  /// 1. Gracefully closes the WebSocket connection if it exists
  /// 2. Sets the connection status to false
  /// 3. Notifies listeners about the disconnection
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Sends a text message to the WebSocket server.
  ///
  /// This method:
  /// 1. Validates the message (not empty), connection status, and user
  /// 2. Creates a JSON message with text and sender information
  /// 3. Sends the encoded message to the server via the WebSocket channel
  ///
  /// The method silently returns without sending if:
  /// - The connection is not established
  /// - No current user is set
  /// - The text is empty or only whitespace
  ///
  /// @param text The message text to send
  void sendMessage(String text) {
    if (!_isConnected || _currentUser.isEmpty || text.trim().isEmpty) {
      return;
    }

    final message = {'text': text, 'sender': _currentUser};

    _channel!.sink.add(jsonEncode(message));
  }

  /// Processes incoming messages from the WebSocket server.
  ///
  /// This private method:
  /// 1. Decodes the incoming JSON data
  /// 2. Identifies the message type ('history' or 'message')
  /// 3. Processes chat history by sorting and replacing current messages
  /// 4. Processes new messages by adding them to the top of the list
  /// 5. Notifies listeners about message list changes
  ///
  /// The method handles two types of server messages:
  /// - 'history': A batch of previous messages sent when initially connecting
  /// - 'message': A single new message broadcast to all clients
  ///
  /// @param data The raw data received from the WebSocket server
  void _handleIncomingMessage(dynamic data) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(data);

      if (jsonData['type'] == 'history') {
        // Handle chat history
        final List<dynamic> historyMessages = jsonData['messages'];
        final List<ChatMessage> parsedMessages =
            historyMessages
                .map((msgJson) => ChatMessage.fromJson(msgJson))
                .toList();

        // Sort by timestamp (newest first)
        parsedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        _messages.clear();
        _messages.addAll(parsedMessages);
        notifyListeners();
      } else if (jsonData['type'] == 'message') {
        // Handle new message
        final messageJson = jsonData['message'];
        final message = ChatMessage.fromJson(messageJson);

        // Add at the beginning (newest first)
        _messages.insert(0, message);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing message: $e');
      }
    }
  }
}

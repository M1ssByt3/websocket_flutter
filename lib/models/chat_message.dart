import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  // For displaying formatted time
  String get formattedTime {
    return DateFormat('HH:mm').format(timestamp);
  }

  // For displaying formatted date and time
  String get formattedDateTime {
    return DateFormat('MMM dd, HH:mm').format(timestamp);
  }

  // Convert message to JSON for sending to server
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      // We don't send timestamp - server will add it
    };
  }

  // Create a message from JSON received from server
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

# Real-time Chat Application

A fully functional Flutter chat application demonstrating real-time communication using WebSockets with a custom Python WebSocket server. This project showcases a complete end-to-end implementation of a chat system with modern UI and real-time capabilities.

## Features

- **Real-time Bidirectional Communication**: Instant message delivery between users
- **Custom WebSocket Server**: Python-based WebSocket server with broadcast capabilities
- **Message Timestamps**: All messages include precise timestamp information
- **Reverse Chronological Order**: Latest messages appear at the top of the chat view
- **Visual Message Distinction**: Clear visual difference between sent and received messages
- **Connection Status Indicator**: Real-time connection status monitoring
- **User-friendly Interface**: Intuitive chat interface with modern design elements
- **Message History**: New connections automatically receive chat history
- **Multiple User Testing**: Options for testing with multiple users

## Project Structure

### Server (Python)

- `server.py`: A custom WebSocket server built with Python's `websockets` library

### Flutter App

- **Models**:
  - `ChatMessage`: Represents a chat message with text, sender, and timestamp

- **Services**:
  - `ChatService`: Manages WebSocket connection and message handling

- **Widgets**:
  - `MessageBubble`: Displays individual chat messages with styling

- **Screens**:
  - `LoginScreen`: User authentication and name selection
  - `ChatScreen`: Main chat interface

## Getting Started

### Prerequisites

1. Flutter SDK (latest version recommended)
2. Python 3.7+ with the `websockets` library
3. An IDE (VS Code, Android Studio, etc.)

### Setup and Run

#### 1. Install Python Dependencies

```bash
pip install websockets
```

#### 2. Start the WebSocket Server

```bash
python server.py
```

The server will start on `ws://127.0.0.1:8765`

#### 3. Run the Flutter App

```bash
flutter run
```

## How to Test with Multiple Users

There are a few ways to test the chat with multiple users:

### Option 1: Quick Switch Between Users

On the login screen, use the "Alice" and "Bob" buttons to quickly switch between test users.

### Option 2: Multiple Browser Windows (Web)

If running on the web:
1. Run `flutter run -d chrome`
2. Open multiple browser windows/tabs with the app
3. Log in with different usernames

### Option 3: Multiple Devices/Emulators

Connect multiple physical devices or run multiple emulators, then run the app on each.

## Implementation Details

### WebSocket Server

The Python server:
- Maintains a list of connected clients
- Stores chat history (up to 100 messages)
- Broadcasts messages to all connected clients
- Adds timestamps to messages
- Sends chat history to newly connected clients

### Flutter App

- Uses the Provider pattern for state management
- WebSocket connection is handled by the `web_socket_channel` package
- Messages are displayed in reverse chronological order
- Each message shows the sender, text content, and timestamp
- Different styling for messages sent by the current user vs. others

## Troubleshooting

- If you cannot connect to the WebSocket server, ensure:
  - The server is running
  - You're connecting to the correct address (default is `ws://127.0.0.1:8765`)
  - No firewall is blocking the connection
  - Your device/emulator can access the hosting machine (when testing on physical devices)

- If the app doesn't show messages in real-time:
  - Check your connection status indicator in the app bar
  - Try using the refresh button in the app bar
  - Ensure the server is running with proper logging enabled
  - Check for any error messages in the server console

## Future Improvements

1. **User Authentication**: Add proper user authentication
2. **Message Persistence**: Store messages in a database
3. **Typing Indicators**: Show when users are typing
4. **Read Receipts**: Indicate when messages have been read
5. **Media Sharing**: Allow sharing of images and files
6. **Private Messaging**: Support for direct messages between users
7. **Group Chat**: Create and manage group conversations
8. **Push Notifications**: Notify users of new messages when the app is in the background

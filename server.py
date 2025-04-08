#!/usr/bin/env python3
"""
Real-time Chat WebSocket Server

This server provides real-time chat functionality using WebSockets.
It handles multiple client connections, broadcasts messages to all clients,
maintains a chat history, and provides detailed logging for debugging.

Features:
- Multiple client connections
- Message broadcasting
- Chat history storage and retrieval
- Timestamp addition to messages
- Detailed debug logging
- Error handling and recovery

Author: Cline
Date: April 2025
"""

import asyncio
import json
import websockets
import datetime
import logging
import signal
import sys

# Configure logging for better debugging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('chat_server')

# Global state
connected_clients = set()  # Set of active WebSocket connections
chat_history = []  # List of message objects with text, sender, and timestamp

async def handle_connection(websocket):
    """
    Handle a WebSocket connection from a client.
    
    This function:
    1. Registers the new client
    2. Sends existing chat history
    3. Processes incoming messages
    4. Broadcasts messages to all clients
    5. Handles disconnection
    
    Args:
        websocket: The WebSocket connection object
    """
    client_id = id(websocket)
    logger.info(f"New client connected: {client_id}")
    
    # Register client
    connected_clients.add(websocket)
    logger.info(f"Total connected clients: {len(connected_clients)}")
    
    try:
        # Send chat history to new client
        if chat_history:
            logger.info(f"Sending chat history to client {client_id}")
            history_json = json.dumps({
                "type": "history",
                "messages": chat_history
            })
            await websocket.send(history_json)
            logger.debug(f"Sent history: {history_json}")
        else:
            logger.info(f"No chat history to send to client {client_id}")
        
        # Handle messages
        logger.info(f"Waiting for messages from client {client_id}")
        async for message in websocket:
            try:
                logger.debug(f"Received message from client {client_id}: {message}")
                data = json.loads(message)
                
                if 'text' in data and 'sender' in data:
                    # Add timestamp
                    timestamp = datetime.datetime.now().isoformat()
                    message_obj = {
                        "text": data["text"],
                        "sender": data["sender"],
                        "timestamp": timestamp
                    }
                    
                    logger.info(f"Processed message from {data['sender']}: {data['text']}")
                    
                    # Add to history
                    chat_history.append(message_obj)
                    logger.debug(f"Added message to history. Total messages: {len(chat_history)}")
                    
                    # Limit history size (optional)
                    if len(chat_history) > 100:
                        chat_history.pop(0)
                        logger.debug("Trimmed chat history to 100 messages")
                    
                    # Broadcast to all clients
                    message_json = json.dumps({
                        "type": "message",
                        "message": message_obj
                    })
                    
                    logger.info(f"Broadcasting message to {len(connected_clients)} clients")
                    broadcast_tasks = []
                    for client in connected_clients:
                        try:
                            broadcast_tasks.append(client.send(message_json))
                        except Exception as e:
                            logger.error(f"Error preparing broadcast to client: {e}")
                    
                    if broadcast_tasks:
                        await asyncio.gather(*broadcast_tasks)
                        logger.debug("Broadcast complete")
                else:
                    logger.warning(f"Message missing required fields: {data}")
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON: {message}")
            except Exception as e:
                logger.error(f"Error processing message: {e}")
    except Exception as e:
        logger.error(f"Unexpected error for client {client_id}: {e}")
    finally:
        # Unregister client
        connected_clients.remove(websocket)
        logger.info(f"Client {client_id} disconnected. Remaining clients: {len(connected_clients)}")

# Handle graceful shutdown
def setup_signal_handlers(loop):
    """
    Setup signal handlers for graceful shutdown.
    
    Args:
        loop: The asyncio event loop
    """
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(
            sig,
            lambda: asyncio.create_task(shutdown(loop))
        )

async def shutdown(loop):
    """
    Perform a graceful shutdown.
    
    This function:
    1. Logs the shutdown
    2. Closes all client connections
    3. Stops the event loop
    
    Args:
        loop: The asyncio event loop
    """
    logger.info("Shutting down server...")
    
    # Close all WebSocket connections
    if connected_clients:
        logger.info(f"Closing {len(connected_clients)} client connections...")
        close_tasks = [client.close() for client in connected_clients]
        await asyncio.gather(*close_tasks, return_exceptions=True)
    
    # Stop the event loop
    logger.info("Stopping event loop...")
    loop.stop()

async def main():
    """
    Main entry point for the WebSocket server.
    
    This function:
    1. Sets up signal handlers for graceful shutdown
    2. Starts the WebSocket server
    3. Keeps the server running until closed
    
    Returns:
        None
    """
    try:
        # Get the event loop
        loop = asyncio.get_running_loop()
        
        # Setup signal handlers
        setup_signal_handlers(loop)
        
        # Start WebSocket server
        server_ip = "127.0.0.1"  # Use localhost for testing
        server_port = 8765
        
        logger.info(f"Starting WebSocket server on {server_ip}:{server_port}")
        server = await websockets.serve(
            handle_connection, 
            server_ip, 
            server_port
        )
        
        logger.info(f"WebSocket server running at ws://{server_ip}:{server_port}")
        print(f"WebSocket server running at ws://{server_ip}:{server_port}")
        print(f"Press Ctrl+C to stop the server")
        
        # Keep server running
        await server.wait_closed()
    except Exception as e:
        logger.error(f"Server error: {e}")
        raise

if __name__ == "__main__":
    try:
        # Run the main function
        asyncio.run(main())
    except KeyboardInterrupt:
        # This should be handled by signal handlers, but just in case
        logger.info("Server shutdown by user (KeyboardInterrupt)")
    except Exception as e:
        logger.error(f"Server crashed: {e}")
        sys.exit(1)

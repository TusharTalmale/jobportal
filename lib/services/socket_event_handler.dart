import 'package:flutter/foundation.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:jobportal/constants/socket_constants.dart';

/// Handles Socket.IO events and provides callbacks for UI updates
class SocketEventHandler {
  // Event callbacks
  Function(Message)? onNewMessage;
  Function(Conversation)? onNewConversation;
  Function(Map<String, dynamic>)? onMessagesRead;
  Function(Map<String, dynamic>)? onUserTyping;
  Function(Map<String, dynamic>)? onUserStoppedTyping;

  /// Handle incoming new message event
  void handleNewMessage(dynamic data) {
    try {
      final msg = Message.fromJson(Map<String, dynamic>.from(data));
      onNewMessage?.call(msg);
    } catch (e) {
      if (kDebugMode) print('Error parsing newMessage: $e');
    }
  }

  /// Handle incoming new conversation event
  void handleNewConversation(dynamic data) {
    try {
      final conv = Conversation.fromJson(Map<String, dynamic>.from(data));
      onNewConversation?.call(conv);
    } catch (e) {
      if (kDebugMode) print('Error parsing newConversation: $e');
    }
  }

  /// Handle messages read event
  void handleMessagesRead(dynamic data) {
    try {
      if (data is Map) {
        onMessagesRead?.call(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing messagesRead: $e');
    }
  }

  /// Handle user typing event
  void handleUserTyping(dynamic data) {
    try {
      if (data is Map) {
        onUserTyping?.call(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing userTyping: $e');
    }
  }

  /// Handle user stopped typing event
  void handleUserStoppedTyping(dynamic data) {
    try {
      if (data is Map) {
        onUserStoppedTyping?.call(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing userStoppedTyping: $e');
    }
  }

  /// Register this handler with socket manager
  void register(dynamic socketManager) {
    socketManager.on(SocketConstants.newMessage, handleNewMessage);
    socketManager.on(SocketConstants.newConversation, handleNewConversation);
    socketManager.on(SocketConstants.messagesRead, handleMessagesRead);
    socketManager.on(SocketConstants.userTyping, handleUserTyping);
    socketManager.on(
      SocketConstants.userStoppedTyping,
      handleUserStoppedTyping,
    );
  }

  /// Unregister all handlers
  void unregister(dynamic socketManager) {
    socketManager.off(SocketConstants.newMessage, handleNewMessage);
    socketManager.off(SocketConstants.newConversation, handleNewConversation);
    socketManager.off(SocketConstants.messagesRead, handleMessagesRead);
    socketManager.off(SocketConstants.userTyping, handleUserTyping);
    socketManager.off(
      SocketConstants.userStoppedTyping,
      handleUserStoppedTyping,
    );
  }

  /// Clear all callbacks
  void clear() {
    onNewMessage = null;
    onNewConversation = null;
    onMessagesRead = null;
    onUserTyping = null;
    onUserStoppedTyping = null;
  }
}

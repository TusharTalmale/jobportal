import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/constants/socket_constants.dart';

enum SocketConnectionState { disconnected, connecting, connected, error }

typedef SocketEventCallback = Function(dynamic data);

/// Manages Socket.IO connection and event handling for real-time chat
class SocketManager {
  IO.Socket? _socket;
  SocketConnectionState _state = SocketConnectionState.disconnected;

  final Map<String, List<SocketEventCallback>> _listeners = {};

  SocketConnectionState get state => _state;
  bool get isConnected => _state == SocketConnectionState.connected;
  String? get socketId => _socket?.id;

  /// Initialize socket connection with user credentials
  void connect({
    required int userId,
    required String userType,
    required Function(SocketConnectionState) onStateChange,
  }) {
    if (_socket != null) return;

    _updateState(SocketConnectionState.connecting, onStateChange);

    final uri = ApiConstants.baseUrl;
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {
        SocketConstants.userIdQuery: userId.toString(),
        SocketConstants.typeQuery: userType,
      },
    });

    _setupEventListeners(onStateChange);
  }

  /// Setup all socket event listeners
  void _setupEventListeners(Function(SocketConnectionState) onStateChange) {
    _socket?.on(SocketConstants.connect, (_) {
      if (kDebugMode) print('Socket connected: ${_socket?.id}');
      _updateState(SocketConnectionState.connected, onStateChange);
      _emitEvent(SocketConstants.connect, null);
    });

    _socket?.on(SocketConstants.disconnect, (_) {
      if (kDebugMode) print('Socket disconnected');
      _updateState(SocketConnectionState.disconnected, onStateChange);
      _emitEvent(SocketConstants.disconnect, null);
    });

    _socket?.on(SocketConstants.connectError, (err) {
      if (kDebugMode) print('Socket connect error: $err');
      _updateState(SocketConnectionState.error, onStateChange);
      _emitEvent(SocketConstants.connectError, err);
    });

    _socket?.on(SocketConstants.error, (err) {
      if (kDebugMode) print('Socket error: $err');
      _updateState(SocketConnectionState.error, onStateChange);
      _emitEvent(SocketConstants.error, err);
    });

    _socket?.on(SocketConstants.newMessage, (data) {
      _emitEvent(SocketConstants.newMessage, data);
    });

    _socket?.on(SocketConstants.newConversation, (data) {
      _emitEvent(SocketConstants.newConversation, data);
    });

    _socket?.on(SocketConstants.messagesRead, (data) {
      _emitEvent(SocketConstants.messagesRead, data);
    });

    _socket?.on(SocketConstants.userTyping, (data) {
      _emitEvent(SocketConstants.userTyping, data);
    });

    _socket?.on(SocketConstants.userStoppedTyping, (data) {
      _emitEvent(SocketConstants.userStoppedTyping, data);
    });
  }

  /// Register a callback for a specific socket event
  void on(String eventName, SocketEventCallback callback) {
    if (!_listeners.containsKey(eventName)) {
      _listeners[eventName] = [];
    }
    _listeners[eventName]!.add(callback);
  }

  /// Unregister a callback for a specific socket event
  void off(String eventName, SocketEventCallback callback) {
    _listeners[eventName]?.remove(callback);
  }

  /// Emit a socket event to all registered listeners
  void _emitEvent(String eventName, dynamic data) {
    final callbacks = _listeners[eventName];
    if (callbacks != null) {
      for (var callback in callbacks) {
        callback(data);
      }
    }
  }

  /// Send a socket event to the server
  void emit(String eventName, [dynamic data]) {
    if (!isConnected) {
      if (kDebugMode) print('Socket not connected. Cannot emit: $eventName');
      return;
    }
    _socket?.emit(eventName, data);
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    emit(SocketConstants.joinConversation, conversationId);
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    emit(SocketConstants.leaveConversation, conversationId);
  }

  /// Notify others that user is typing
  void emitStartTyping(String conversationId, Map<String, dynamic> user) {
    emit(SocketConstants.startTyping, {
      'conversationId': conversationId,
      'user': user,
    });
  }

  /// Notify others that user stopped typing
  void emitStopTyping(String conversationId, Map<String, dynamic> user) {
    emit(SocketConstants.stopTyping, {
      'conversationId': conversationId,
      'user': user,
    });
  }

  /// Update connection state and notify listeners
  void _updateState(
    SocketConnectionState newState,
    Function(SocketConnectionState) onStateChange,
  ) {
    if (_state != newState) {
      _state = newState;
      onStateChange(newState);
    }
  }

  /// Disconnect socket and clean up
  void disconnect() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _listeners.clear();
    _state = SocketConnectionState.disconnected;
  }

  /// Rejoin all rooms (useful for reconnection)
  void rejoinRooms(List<String> conversationIds) {
    for (var id in conversationIds) {
      joinConversation(id);
    }
  }
}

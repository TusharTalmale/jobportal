import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:jobportal/services/socket_manager.dart';
import 'package:jobportal/services/socket_event_handler.dart';
import 'package:jobportal/services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final _api = ApiClient();
  final LocalStorageService _storageService = LocalStorageService();
  late SocketManager _socketManager;
  late SocketEventHandler _eventHandler;

  int? userId;
  String userType = 'user';

  SocketConnectionState _socketState = SocketConnectionState.disconnected;
  SocketConnectionState get socketState => _socketState;

  List<Conversation> conversations = [];
  final Map<String, List<Message>> messages = {};

  /// Initialize chat provider with user data from local storage
  Future<void> initializeFromStorage() async {
    try {
      final storedUserId = _storageService.getUserId();
      final storedUserType = _storageService.getUserType() ?? 'user';

      if (storedUserId != null) {
        await init(userId: storedUserId, type: storedUserType);
      } else {
        if (kDebugMode) print('No user ID found in storage');
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing from storage: $e');
    }
  }

  Future<void> init({required int userId, String type = 'user'}) async {
    // Prevent re-initialization if the user ID is already set and matches.
    if (this.userId == userId) {
      return;
    }

    this.userId = userId;
    userType = type;
    await fetchConversations();
    _initializeSocket();
  }

  /// Initialize socket manager and event handlers with stored authentication
  void _initializeSocket() {
    _socketManager = SocketManager();
    _eventHandler = SocketEventHandler();

    // Setup event callbacks
    _eventHandler.onNewMessage = _handleNewMessage;
    _eventHandler.onNewConversation = _handleNewConversation;
    _eventHandler.onMessagesRead = _handleMessagesRead;
    _eventHandler.onUserTyping = _handleUserTyping;
    _eventHandler.onUserStoppedTyping = _handleUserStoppedTyping;

    // Register event handler
    _eventHandler.register(_socketManager);

    // Connect socket
    _socketManager.connect(
      userId: userId ?? 0,
      userType: userType,
      onStateChange: _updateSocketState,
    );
  }

  Future<void> fetchConversations() async {
    if (userId == null) {
      if (kDebugMode) print('Cannot fetch conversations: userId is null');
      return;
    }
    try {
      final list = await _api.chatApiService.getUserConversations(
        userId: userId!,
      );
      conversations = list;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('fetchConversations error: $e');
      rethrow;
    }
  }

  /// Fetch messages for a conversation. If [append] is true, new pages
  /// will be appended to existing messages (older messages).
  Future<List<Message>> fetchMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
    bool append = false,
  }) async {
    try {
      final resp = await _api.chatApiService.getMessagesForConversation(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );
      final msgs = resp.messages;

      if (append) {
        final existing = messages[conversationId] ?? [];
        // messages are expected newest-first; when appending older pages, add to end
        messages[conversationId] = [...existing, ...msgs];
      } else {
        messages[conversationId] = msgs.toList();
      }
      notifyListeners();
      return msgs;
    } catch (e) {
      if (kDebugMode) print('fetchMessages error: $e');
      return [];
    }
  }

  Future<Conversation> startConversation(int companyId) async {
    try {
      final conv = await _api.chatApiService.findOrCreateConversation(
        <String, dynamic>{'userId': userId ?? 0, 'companyId': companyId},
      );
      // ensure in-memory list updated
      final exists = conversations.any((c) => c.id == conv.id);
      if (!exists) {
        conversations.insert(0, conv);
      }
      // join room
      _socketManager.joinConversation(conv.id);
      notifyListeners();
      return conv;
    } catch (e) {
      if (kDebugMode) print('startConversation error: $e');
      rethrow;
    }
  }

  /// Remove a conversation locally (used by Inbox Dismissible)
  void removeConversation(Conversation conversation) {
    conversations.removeWhere((c) => c.id == conversation.id);
    messages.remove(conversation.id);
    notifyListeners();
  }

  Future<void> sendMessage(
    String conversationId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final msg = await _api.chatApiService.sendMessage(
        conversationId: conversationId,
        messagePayload: payload,
      );

      // Add message to local cache
      messages.putIfAbsent(conversationId, () => []);
      messages[conversationId]!.insert(0, msg);

      // Move conversation to top
      final idx = conversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        final conv = conversations.removeAt(idx);
        conversations.insert(0, conv);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('sendMessage error: $e');
      rethrow;
    }
  }

  Future<int> markAsRead(
    String conversationId,
    Map<String, dynamic> recipient,
  ) async {
    try {
      final response = await _api.chatApiService.markAsRead(
        conversationId: conversationId,
        body: {'recipient': recipient},
      );
      notifyListeners();

      // Parse count from the response map - backend returns { message: "X messages marked as read." }
      if (response['updatedCount'] != null) {
        final count = response['updatedCount'];
        if (count is int) return count;
        if (count is String) return int.tryParse(count) ?? 0;
      }

      // Fallback: parse from message string
      if (response['message'] is String) {
        final message = response['message'] as String;
        final match = RegExp(r'(\d+)').firstMatch(message);
        if (match != null) return int.tryParse(match.group(1)!) ?? 0;
      }

      return 0;
    } catch (e) {
      if (kDebugMode) print('markAsRead error: $e');
      return 0;
    }
  }

  /// Handle new message from socket
  void _handleNewMessage(Message message) {
    messages.putIfAbsent(message.conversationId, () => []);

    // Avoid adding duplicate messages
    if (messages[message.conversationId]!.any((m) => m.id == message.id)) {
      return;
    }

    messages[message.conversationId]!.insert(0, message);
    _bringConversationToTop(message.conversationId);
    notifyListeners();
  }

  /// Handle new conversation from socket
  void _handleNewConversation(Conversation conversation) {
    final exists = conversations.any((c) => c.id == conversation.id);
    if (!exists) conversations.insert(0, conversation);
    notifyListeners();
  }

  /// Handle messages read event
  void _handleMessagesRead(Map<String, dynamic> data) {
    notifyListeners();
  }

  /// Handle user typing event
  void _handleUserTyping(Map<String, dynamic> data) {
    notifyListeners();
  }

  /// Handle user stopped typing event
  void _handleUserStoppedTyping(Map<String, dynamic> data) {
    notifyListeners();
  }

  /// Bring conversation to top of list
  void _bringConversationToTop(String conversationId) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final conv = conversations.removeAt(idx);
      conversations.insert(0, conv);
    }
  }

  /// Update socket connection state
  void _updateSocketState(SocketConnectionState newState) {
    _socketState = newState;
    notifyListeners();
  }

  /// Disconnect socket and clean up
  void disposeSocket() {
    _eventHandler.unregister(_socketManager);
    _eventHandler.clear();
    _socketManager.disconnect();
  }

  @override
  void dispose() {
    disposeSocket();
    super.dispose();
  }
}

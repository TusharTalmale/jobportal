/// Socket.IO event names and constants for real-time chat functionality
class SocketConstants {
  // Connection events
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connect_error';
  static const String error = 'error';

  // Message events
  static const String newMessage = 'newMessage';
  static const String messagesRead = 'messagesRead';

  // Conversation events
  static const String newConversation = 'newConversation';

  // Typing events
  static const String startTyping = 'startTyping';
  static const String stopTyping = 'stopTyping';
  static const String userTyping = 'userTyping';
  static const String userStoppedTyping = 'userStoppedTyping';

  // Room management events
  static const String joinConversation = 'joinConversation';
  static const String leaveConversation = 'leaveConversation';
  static const String startConversation = 'startConversation';

  // Query parameters
  static const String userIdQuery = 'userId';
  static const String typeQuery = 'type';

  // Socket types
  static const String userType = 'user';
  static const String companyType = 'company';
}

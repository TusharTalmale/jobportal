import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:jobportal/model.dart/job.dart';

class ChatProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];

  List<Conversation> get conversations => _conversations;

  // Method to add a new conversation (e.g., when starting a chat from a job)
  void addConversation(Conversation newConversation) {
    _conversations.add(newConversation);
    notifyListeners();
  }

  // Method to remove a conversation
  void removeConversation(Conversation conversationToRemove) {
    _conversations.removeWhere((c) => c.id == conversationToRemove.id);
    notifyListeners();
  }

  // Method to send a new message
  void sendMessage(
    String conversationId,
    MessageSender sender,
    String text, {
    String? repliedToMessageId,
  }) {
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (conversationIndex != -1) {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sender,
        text: text,
        timestamp: DateTime.now(),
        repliedToMessageId: repliedToMessageId,
      );
      _conversations[conversationIndex].messages.add(newMessage);
      _conversations[conversationIndex] = Conversation(
        id: _conversations[conversationIndex].id,
        companyName: _conversations[conversationIndex].companyName,
        companyLogoUrl: _conversations[conversationIndex].companyLogoUrl,
        companyData: _conversations[conversationIndex].companyData,
        lastMessage: text,
        lastMessageTime: newMessage.timestamp,
        messages: _conversations[conversationIndex].messages,
      );
      notifyListeners();
    }
  }

  // Method to send a file message
  void sendFile(
    String conversationId,
    MessageSender sender,
    String fileName,
    String fileUrl,
  ) {
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (conversationIndex != -1) {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sender,
        type: MessageType.file,
        fileName: fileName,
        fileUrl: fileUrl,
        timestamp: DateTime.now(),
      );
      _conversations[conversationIndex].messages.add(newMessage);
      notifyListeners();
    }
  }

  // Method to send a job message
  void sendJob(
    String conversationId,
    MessageSender sender,
    Job jobData, {
    String? text,
  }) {
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (conversationIndex != -1) {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: sender,
        type: MessageType.job,
        jobData: jobData,
        text: text,
        timestamp: DateTime.now(),
      );
      _conversations[conversationIndex].messages.add(newMessage);
      notifyListeners();
    }
  }

  // Helper to find a message by ID within a conversation
  Message? findMessageById(String conversationId, String messageId) {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
    );
    return conversation.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => null as Message,
    );
  }

  // Helper to find an existing conversation or create a new one
  Conversation findOrCreateConversation(Company company) {
    // Try to find a conversation with the same company.
    // In a real app, you'd use a unique company ID.
    final existingConversation = _conversations.where(
      (c) =>
          c.companyData.website ==
          company.website, // Using website as a unique key
    );

    if (existingConversation.isNotEmpty) {
      return existingConversation.first;
    } else {
      // Create a new conversation if one doesn't exist
      final newConversation = Conversation(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        companyName:
            company.companyName, // You should have a name property in Company model
        companyLogoUrl:
            'assets/images/google_logo.png', // Placeholder, get from Company model
        companyData: company,
        lastMessage: 'Conversation started.',
        lastMessageTime: DateTime.now(),
        messages: [],
      );
      _conversations.insert(0, newConversation); // Add to the top of the list
      notifyListeners();
      return newConversation;
    }
  }
}

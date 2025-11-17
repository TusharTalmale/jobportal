import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/message.dart';

class Conversation {
  final String id;
  final String companyName; // Explicitly store company name for display
  final String companyLogoUrl; // Explicitly store company logo for display
  final Company companyData; // Link to the full Company data
  final String lastMessage;
  final DateTime lastMessageTime;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.companyName,
    required this.companyLogoUrl,
    required this.companyData,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messages,
  });
}
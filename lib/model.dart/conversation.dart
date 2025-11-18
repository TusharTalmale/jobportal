import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

@JsonSerializable(explicitToJson: true)
class Conversation {
  final String id;
  final int userId;
  final int companyId;
  @JsonKey(name: 'Company')
  final Company? company;
  final List<Message> messages; // often includes last message only
  final int unreadCount;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.companyId,
    this.company,
    this.messages = const [],
    this.unreadCount = 0,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);
  // Convenience getters to support UI code expecting older Conversation shape
  String get companyName => company?.companyName ?? 'Company $companyId';

  String get companyLogoUrl => company?.companyLogo ?? '';

  String get lastMessage =>
      messages.isNotEmpty ? (messages.first.text ?? '') : '';

  DateTime get lastMessageTime =>
      messages.isNotEmpty
          ? messages.first.createdAt
          : (updatedAt ?? DateTime.now());
}

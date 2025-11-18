import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/message.dart';

part 'paginated_messages.g.dart';

@JsonSerializable(explicitToJson: true)
class PaginatedMessages {
  final int totalPages;
  final int currentPage;
  final List<Message> messages;

  PaginatedMessages({
    required this.totalPages,
    required this.currentPage,
    required this.messages,
  });

  factory PaginatedMessages.fromJson(Map<String, dynamic> json) =>
      _$PaginatedMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedMessagesToJson(this);
}

import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:jobportal/model.dart/paginated_messages.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ChatApiService {
  factory ChatApiService(Dio dio, {String baseUrl}) = _ChatApiService;

  /// Find or create a conversation between a user and a company.
  @POST(ApiConstants.chatConversations)
  Future<Conversation> findOrCreateConversation(
    @Body() Map<String, dynamic> body,
  );

  /// Get conversations for a user. Returns a list of Conversation objects.
  @GET(ApiConstants.chatConversations)
  Future<List<Conversation>> getUserConversations({
    @Query('userId') required int userId,
  });

  /// Get paginated messages for a conversation.
  @GET(ApiConstants.chatMessages)
  Future<PaginatedMessages> getMessagesForConversation({
    @Path('conversationId') required String conversationId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  /// Send a message to a conversation. messagePayload should include the fields
  /// accepted by the backend (senderId, senderType, messageType, text, etc.)
  @POST(ApiConstants.chatMessages)
  Future<Message> sendMessage({
    @Path('conversationId') required String conversationId,
    @Body() required Map<String, dynamic> messagePayload,
  });

  /// Mark messages as read for a conversation by a recipient object { id, type }
  @PATCH(ApiConstants.chatMarkRead)
  Future<Map<String, dynamic>> markAsRead({
    @Path('conversationId') required String conversationId,
    @Body() required Map<String, dynamic> body,
  });
}

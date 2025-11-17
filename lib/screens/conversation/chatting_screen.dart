import 'package:flutter/material.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:jobportal/model.dart/job.dart'; // For job messages

class ChattingScreen extends StatefulWidget {
  final Conversation conversation;
  final ChatProvider chatProvider;
  final Job? initialJob; // Optional: to start a chat by sharing a job

  const ChattingScreen({
    super.key,
    required this.conversation,
    required this.chatProvider,
    this.initialJob,
  });

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Message? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    // If an initial job is provided, send it as the first message
    if (widget.initialJob != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.chatProvider.sendJob(
          widget.conversation.id,
          MessageSender.user,
          widget.initialJob!,
          text: 'I\'m interested in this job:',
        );
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController
          .position
          .minScrollExtent, // Use minScrollExtent for reverse: true
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      widget.chatProvider.sendMessage(
        widget.conversation.id,
        MessageSender.user,
        _messageController.text,
        repliedToMessageId: _replyingToMessage?.id,
      );
      _messageController.clear();
      _replyingToMessage = null; // Clear reply state
    });
    _scrollToBottom();
  }

  void _sendFile() {
    // Simulate file sending
    widget.chatProvider.sendFile(
      widget.conversation.id,
      MessageSender.user,
      'Document.pdf',
      'assets/files/document.pdf',
    ); // Placeholder
    _scrollToBottom();
  }

  // Helper to find a message by ID within the current conversation
  Message? _findMessageInConversation(String messageId) {
    return widget.conversation.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => null as Message,
    );
  }

  Widget _buildMessageBubble(Message message, bool isUser) {
    final repliedToMessage =
        message.repliedToMessageId != null
            ? _findMessageInConversation(message.repliedToMessageId!)
            : null;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _replyingToMessage = message;
        });
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (repliedToMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border(
                      left: BorderSide(
                        color: isUser ? Colors.blue : Colors.grey,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repliedToMessage.sender == MessageSender.user
                            ? 'You replied to:'
                            : '${widget.conversation.companyName} replied to:',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isUser ? Colors.blue : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      if (repliedToMessage.type == MessageType.text)
                        Text(
                          repliedToMessage.text!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (repliedToMessage.type == MessageType.file)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              repliedToMessage.fileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      if (repliedToMessage.type == MessageType.job)
                        Text(
                          'Job: ${repliedToMessage.jobData!.jobTitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
              if (message.type == MessageType.text && message.text != null)
                Text(message.text!),
              if (message.type == MessageType.file && message.fileName != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file, size: 20),
                    const SizedBox(width: 8),
                    Text(message.fileName!),
                    const SizedBox(width: 8),
                    const Icon(Icons.download_for_offline, size: 20),
                  ],
                ),
              if (message.type == MessageType.job && message.jobData != null)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text != null) ...[
                        Text(
                          message.text!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                            // message.jobData!.company!.companyGallery!.first
                            //         .startsWith('http')
                            //     ?
                            NetworkImage(
                              message.jobData!.company!.companyGallery!.first,
                            ),
                            // : AssetImage(
                            //       message
                            //           .jobData!
                            //           .company
                            //           .companyGallery!
                            //           .first,
                            //     )
                            //     as ImageProvider,
                            radius: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.jobData!.jobTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.jobData!.company!.companyName!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      Text(
                        '${message.jobData!.company!.companyName} • ${message.jobData!.salary}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4.0),
              Text(
                DateFormat.jm().format(message.timestamp), // e.g., 5:30 PM
                style: TextStyle(color: Colors.grey[600], fontSize: 10.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the ChatProvider
    final currentConversation = widget.chatProvider.conversations.firstWhere(
      (conv) => conv.id == widget.conversation.id,
    );
    final messages = currentConversation.messages;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CircleAvatar(
              backgroundImage:
                  (currentConversation.companyData.companyGallery?.isNotEmpty ??
                          false)
                      ? NetworkImage(
                        currentConversation.companyData.companyGallery!.first,
                      )
                      : null,
              radius: 15,
            ),
          ],
        ),
        title: Text(
          currentConversation.companyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Show latest messages at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message =
                    messages[messages.length -
                        1 -
                        index]; // Display in chronological order
                final isUser = message.sender == MessageSender.user;
                return _buildMessageBubble(message, isUser);
              },
            ),
          ),
          if (_replyingToMessage != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_replyingToMessage!.type == MessageType.text)
                          Text(
                            _replyingToMessage!.text!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (_replyingToMessage!.type == MessageType.file)
                          Text(
                            'File: ${_replyingToMessage!.fileName!}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (_replyingToMessage!.type == MessageType.job)
                          Text(
                            'Job: ${_replyingToMessage!.jobData!.jobTitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyingToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendFile, // Simulate file sending
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText:
                          _replyingToMessage != null
                              ? 'Reply to message...'
                              : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leadingWidth: 80,
//         leading: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             CircleAvatar(
//               backgroundImage:
//                   conversation.companyLogoUrl.startsWith('http')
//                       ? NetworkImage(widget.conversation.companyLogoUrl)
//                       : AssetImage(widget.conversation.companyLogoUrl)
//                           as ImageProvider,
//               radius: 15,
//             ),
//           ],
//         ),
//         title: Text(
//           widget.conversation.companyName,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8.0),
//               reverse: true, // Show latest messages at the bottom
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message =
//                     _messages[_messages.length -
//                         1 -
//                         index]; // Display in chronological order
//                 final isUser = message.sender == MessageSender.user;
//                 return Align(
//                   alignment:
//                       isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4.0),
//                     padding: const EdgeInsets.all(10.0),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue[100] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: Column(
//                       crossAxisAlignment:
//                           isUser
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                       children: [
//                         Text(message.text),
//                         const SizedBox(height: 4.0),
//                         Text(
//                           DateFormat.jm().format(
//                             message.timestamp,
//                           ), // e.g., 5:30 PM
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 10.0,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  Message? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages();

    _scrollController.addListener(() {
      // Check if we're at the top of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreMessages();
      }
    });
  }

  Future<void> _fetchInitialMessages() async {
    setState(() => _isLoading = true);
    await widget.chatProvider.fetchMessages(widget.conversation.id);
    if (mounted) {
      setState(() => _isLoading = false);
    }

    // If an initial job is provided, send it after fetching messages
    if (widget.initialJob != null) {
      _sendJobMessage(widget.initialJob!);
    }
  }

  Future<void> _fetchMoreMessages() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    _currentPage++;
    final newMessages = await widget.chatProvider.fetchMessages(
      widget.conversation.id,
      page: _currentPage,
      append: true,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasMore = newMessages.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final payload = {
      'senderId': widget.chatProvider.userId,
      'senderType': widget.chatProvider.userType,
      'messageType': 'text',
      'text': _messageController.text.trim(),
      if (_replyingToMessage != null)
        'repliedToMessageId': _replyingToMessage!.id,
    };

    await widget.chatProvider.sendMessage(widget.conversation.id, payload);

    if (mounted) {
      setState(() {
        _messageController.clear();
        _replyingToMessage = null; // Clear reply state
      });
    }
  }

  void _sendJobMessage(Job job) async {
    final payload = {
      'senderId': widget.chatProvider.userId,
      'senderType': widget.chatProvider.userType,
      'messageType': 'job',
      'jobId': job.id,
      'text': 'I\'m interested in this job:',
    };
    await widget.chatProvider.sendMessage(widget.conversation.id, payload);
  }

  void _sendFile() async {
    // This is a placeholder. In a real app, you would use a file picker
    // to get a file, upload it to a server to get a URL, then send the message.
    final payload = {
      'senderId': widget.chatProvider.userId,
      'senderType': widget.chatProvider.userType,
      'messageType': 'file',
      'fileName': 'document.pdf',
      'fileUrl':
          'https://example.com/document.pdf', // This should be a real URL
    };
    await widget.chatProvider.sendMessage(widget.conversation.id, payload);
  }

  // Helper to find a message by ID within the current conversation
  Message? _findMessageInConversation(String messageId) {
    final messages = widget.chatProvider.messages[widget.conversation.id] ?? [];
    try {
      return messages.firstWhere((msg) => msg.id.toString() == messageId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildMessageBubble(Message message, bool isUser) {
    final repliedToMessage = message.repliedTo;

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
                        repliedToMessage.senderType == MessageSender.user
                            ? 'You replied'
                            : '${widget.conversation.companyName} replied to:',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isUser ? Colors.blue : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      if (repliedToMessage.messageType == MessageType.text)
                        Text(
                          repliedToMessage.text!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (repliedToMessage.messageType == MessageType.file)
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
                      if (repliedToMessage.messageType == MessageType.job)
                        Text(
                          'Job: ${repliedToMessage.jobData?.jobTitle ?? ''}',
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
              if (message.messageType == MessageType.text &&
                  message.text != null)
                Text(message.text!),
              if (message.messageType == MessageType.file &&
                  message.fileName != null)
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
              if (message.messageType == MessageType.job &&
                  message.jobData != null)
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
                            backgroundImage: NetworkImage(
                              message.jobData?.company?.companyLogo ?? '',
                            ),
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
                        message.jobData?.company?.companyName ?? '',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      Text(
                        '${message.jobData?.company?.companyName ?? ''} • ${message.jobData?.salary ?? ''}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4.0),
              Text(
                DateFormat.jm().format(message.createdAt), // e.g., 5:30 PM
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
    // Use a Consumer to listen for changes in the provider
    final messages =
        context.watch<ChatProvider>().messages[widget.conversation.id] ?? [];

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
                  (widget.conversation.company?.companyLogo?.isNotEmpty ??
                          false)
                      ? NetworkImage(widget.conversation.company!.companyLogo!)
                      : const AssetImage('assets/images/google_logo.png')
                          as ImageProvider,
              radius: 15,
            ),
          ],
        ),
        title: Text(
          widget.conversation.companyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading && messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      reverse: true, // Show latest messages at the bottom
                      itemCount: messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isLoading && index == messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final message = messages[index];
                        final isUser =
                            message.senderId == widget.chatProvider.userId;
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
                        if (_replyingToMessage!.messageType == MessageType.text)
                          Text(
                            _replyingToMessage!.text!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (_replyingToMessage!.messageType == MessageType.file)
                          Text(
                            'File: ${_replyingToMessage!.fileName!}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (_replyingToMessage!.messageType == MessageType.job)
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

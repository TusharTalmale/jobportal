import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/model.dart/message.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<ChatProvider>(context, listen: false);
    prov.fetchMessages(
      widget.conversationId,
      page: 1,
      limit: 30,
      append: false,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() async {
    if (!_hasMore || _isLoadingMore) return;
    if (!_scrollController.hasClients) return;
    final threshold = 200.0;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      // load older messages
      _isLoadingMore = true;
      _currentPage += 1;
      final prov = Provider.of<ChatProvider>(context, listen: false);
      final newMsgs = await prov.fetchMessages(
        widget.conversationId,
        page: _currentPage,
        limit: 30,
        append: true,
      );
      if (newMsgs.isEmpty) _hasMore = false;
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, prov, _) {
                final list = prov.messages[widget.conversationId] ?? [];
                if (list.isEmpty)
                  return const Center(child: Text('No messages'));
                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: list.length,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      itemBuilder: (context, index) {
                        final m = list[index];
                        final isMe =
                            (prov.userId != null) &&
                            (m.senderId == prov.userId) &&
                            (m.senderType == MessageSender.user);
                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe
                                      ? Colors.blueAccent
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: Radius.circular(isMe ? 12 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.messageType == MessageType.text) ...[
                                  Text(
                                    m.text ?? '',
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ] else if (m.messageType ==
                                    MessageType.file) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        color:
                                            isMe
                                                ? Colors.white
                                                : Colors.black54,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          m.fileName ?? 'File',
                                          style: TextStyle(
                                            color:
                                                isMe
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (m.messageType ==
                                    MessageType.job) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work,
                                        color:
                                            isMe
                                                ? Colors.white
                                                : Colors.black54,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          m.jobData?.jobTitle ?? 'Job Shared',
                                          style: TextStyle(
                                            color:
                                                isMe
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  m.createdAt.toLocal().toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isMe ? Colors.white70 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (_isLoadingMore)
                      const Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(hintText: 'Message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _ctrl.text.trim();
                    if (text.isEmpty) return;
                    final prov = Provider.of<ChatProvider>(
                      context,
                      listen: false,
                    );
                    final payload = {
                      'senderId': prov.userId ?? 0,
                      'senderType': prov.userType,
                      'messageType': 'text',
                      'text': text,
                    };
                    await prov.sendMessage(widget.conversationId, payload);
                    _ctrl.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

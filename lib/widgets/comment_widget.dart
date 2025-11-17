import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final int level;

  const CommentWidget({super.key, required this.comment, this.level = 0});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();

  void _postReply() {
    if (_replyController.text.trim().isEmpty) return;

    final provider = Provider.of<NetworkProvider>(context, listen: false);
    // Assuming you have a way to get the current user's ID
    const currentUserId = 1; // Placeholder

    provider.addReplyToComment(
      widget.comment.id,
      _replyController.text,
      currentUserId,
    );

    // Reset the state
    setState(() {
      _isReplying = false;
      _replyController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NetworkProvider>(context);
    final isLiked = provider.likedComments.contains(widget.comment.id);

    // Placeholder for the current user's ID
    const currentUserId = 1; // Placeholder
    final bool isCurrentUser = widget.comment.userId == currentUserId;

    return Padding(
      padding: EdgeInsets.only(
        // Indent replies, but not top-level comments
        left: 16.0 + (widget.level * 32.0),
        right: 16.0,
        top: 12.0,
        bottom: 4.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    (widget.comment.user?.profilePicture != null)
                        ? NetworkImage(widget.comment.user!.profilePicture!)
                        : null,
                child:
                    (widget.comment.user?.profilePicture == null)
                        ? const Icon(Icons.person)
                        : null,
              ),
              const SizedBox(width: 12),
              // Comment Content
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCurrentUser ? Colors.blue[600] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.user?.name ?? 'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isCurrentUser ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.comment.text,
                            style: TextStyle(
                              color:
                                  isCurrentUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Actions (Like, Reply, Time)
          Padding(
            padding: EdgeInsets.only(
              left: isCurrentUser ? 0 : 50.0,
              right: isCurrentUser ? 16 : 0,
              top: 4.0,
            ),
            child: Row(
              mainAxisAlignment:
                  isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(
                  formatTimeAgo(widget.comment.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap:
                      () => provider.toggleCommentLike(
                        widget.comment.id,
                        currentUserId,
                      ),
                  child: Text(
                    'Like (${widget.comment.likesCount})',
                    style: TextStyle(
                      color: isLiked ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isReplying = !_isReplying;
                    });
                  },
                  child: const Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reply Input Field
          if (_isReplying)
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Write a reply...',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _postReply,
                  ),
                ],
              ),
            ),

          // Render Replies
          if (widget.comment.replies != null &&
              widget.comment.replies!.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.comment.replies!.length,
              itemBuilder: (context, index) {
                return CommentWidget(
                  comment: widget.comment.replies![index],
                  level: widget.level + 1,
                );
              },
            ),
        ],
      ),
    );
  }
}

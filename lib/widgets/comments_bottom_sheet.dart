import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:provider/provider.dart';

void showCommentsBottomSheet(BuildContext context, int postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommentsSheet(postId: postId),
  );
}

class CommentsSheet extends StatefulWidget {
  final int postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Comment>> futureComments;
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    futureComments = context.read<NetworkProvider>().loadComments(widget.postId);
  }

  void _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<NetworkProvider>();
    final userId = LocalStorageService().getUserId();

    final newComment =
        await provider.addComment(widget.postId, text, userId!);

    if (newComment != null) {
      setState(() => comments.insert(0, newComment));
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.55; // 55% height

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: futureComments,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                comments = snapshot.data!;

                if (comments.isEmpty) {
                  return const Center(
                    child: Text("No comments yet",
                        style: TextStyle(fontSize: 14)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return CommentWidget(
                      comment: comments[index],
                      onDelete: (id) {
                        setState(() {
                          comments.removeWhere((c) => c.id == id);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // input section like Instagram
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _addComment,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final int level;
  final Function(int)? onDelete;

  const CommentWidget({
    super.key,
    required this.comment,
    this.level = 0,
    this.onDelete,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool showReply = false;
  final replyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.comment.isLikedByUser;

    return Padding(
      padding: EdgeInsets.only(left: widget.level * 24, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    widget.comment.user?.imageUrl != null
                        ? NetworkImage(widget.comment.user!.imageUrl)
                        : null,
                child: widget.comment.user?.imageUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // name + text bubble
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "${widget.comment.user?.fullName ?? "User"}  ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: widget.comment.text,
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(formatTimeAgo(widget.comment.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            )),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            context.read<NetworkProvider>().toggleCommentLike(
                                  widget.comment,
                                  LocalStorageService().getUserId()!,
                                );
                          },
                          child: Text(
                            "Like (${widget.comment.likesCount})",
                            style: TextStyle(
                              fontSize: 12,
                              color: isLiked ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() => showReply = !showReply);
                          },
                          child: const Text(
                            "Reply",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton(
                onSelected: (v) {
                  if (v == "delete") {
                    context.read<NetworkProvider>().deleteComment(
                      widget.comment.id,
                      widget.comment.postId,
                      LocalStorageService().getUserId()!,
                    );
                    widget.onDelete?.call(widget.comment.id);
                  }
                },
                itemBuilder: (c) => const [
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              )
            ],
          ),

          if (showReply)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 45),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyCtrl,
                      decoration: const InputDecoration(
                        hintText: "Write a reply...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final uid = LocalStorageService().getUserId();

                      final newReply =
                          await context.read<NetworkProvider>().addReplyToComment(
                                widget.comment.id,
                                replyCtrl.text,
                                uid!,
                              );

                      if (newReply != null) {
                        setState(() {
                          widget.comment.replies.add(newReply);
                          replyCtrl.clear();
                          showReply = false;
                        });
                      }
                    },
                  )
                ],
              ),
            ),

          // replies
          if (widget.comment.replies.isNotEmpty)
            ...widget.comment.replies.map(
              (r) => CommentWidget(
                comment: r,
                level: widget.level + 1,
                onDelete: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}


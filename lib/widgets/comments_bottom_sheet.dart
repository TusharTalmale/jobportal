import 'package:flutter/material.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/widgets/comment_widget.dart';
import 'package:provider/provider.dart';

void showCommentsBottomSheet(BuildContext context, int postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Important for height management
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsBottomSheet(postId: postId),
  );
}

class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    final provider = Provider.of<NetworkProvider>(context, listen: false);
    const currentUserId = 1; // Placeholder

    provider.addComment(widget.postId, _commentController.text, currentUserId);

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Make the sheet take up 90% of the screen height
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle to indicate draggable sheet
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<NetworkProvider>(
                  builder: (context, provider, child) {
                    final post = provider.currentPost;
                    if (post == null || post.comments == null) {
                      return const Center(child: Text("No comments yet."));
                    }
                    return ListView.builder(
                      controller: controller,
                      itemCount: post.comments!.length,
                      itemBuilder: (context, index) {
                        return CommentWidget(comment: post.comments![index]);
                      },
                    );
                  },
                ),
              ),
              // Input Field
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _postComment,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

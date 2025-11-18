import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/widgets/comments_bottom_sheet.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class CompanyPostCard extends StatelessWidget {
  final CompanyPost post;

  const CompanyPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Assuming you have a way to get the current user's ID
    const currentUserId = 1; // Placeholder

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (post.company?.companyLogo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.company!.companyLogo!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, err, st) =>
                              const Icon(Icons.business, size: 40),
                    ),
                  )
                else
                  const Icon(Icons.business, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.company?.companyName ?? 'A Company',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        formatTimeAgo(post.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- Content ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (post.description != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ],
          // Only show image/video container if the post type is correct and URL exists
          if (post.fileUrl != null &&
              (post.postType == PostType.image ||
                  post.postType == PostType.video)) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.fileUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // --- Actions ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Consumer<NetworkProvider>(
              builder: (context, provider, child) {
                final isLiked = provider.likedPosts.contains(post.id);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed:
                          () => provider.toggleLike(post.id, currentUserId),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      label: Text(
                        '${post.likesCount} Likes',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                                                  showCommentsBottomSheet(context, post.id);

                     
                      },
                      icon: const Icon(
                        Icons.comment_outlined,
                        color: Colors.grey,
                      ),
                      label: Text(
                        '${post.commentsCount} Comments',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        /* TODO: Implement share */
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Share',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

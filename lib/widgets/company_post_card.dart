import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:jobportal/widgets/comments_bottom_sheet.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';
import 'package:provider/provider.dart';

class CompanyPostCard extends StatelessWidget {
  final CompanyPost post;

  const CompanyPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Get current user ID from storage
    final currentUserId = LocalStorageService().getUserId() ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                // Navigate to company detail screen
                if (post.company?.id != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.companyDetails,
                    arguments: post.company?.id,
                  );
                }
              },
              child: Row(
                children: [
                  if (post.company?.companyLogo != null &&
                      post.company!.companyLogo!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.company!.companyLogo!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (ctx, err, st) => Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.business,
                                size: 28,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 28,
                        color: Colors.grey,
                      ),
                    ),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    onPressed: () {
                      // TODO: Implement more options (edit, delete)
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- Title & Description ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.isNotEmpty)
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (post.description != null &&
                    post.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.description!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // --- Media (Image/Video) ---
          if (post.fileUrl != null &&
              post.fileUrl!.isNotEmpty &&
              (post.postType == PostType.image ||
                  post.postType == PostType.video)) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.fileUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder:
                      (ctx, err, st) => Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ],

          // --- Tags ---
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                children:
                    post.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // --- Actions ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Consumer<NetworkProvider>(
              builder: (context, provider, child) {
                final isLiked = provider.likedPosts.contains(post.id);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Like Button
                    _buildActionButton(
                      context,
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      iconColor: isLiked ? Colors.red : Colors.grey,
                      label:
                          '${post.likesCount} Like${post.likesCount != 1 ? 's' : ''}',
                      onTap: () => provider.toggleLike(post.id, currentUserId),
                    ),
                    // Comment Button
                    _buildActionButton(
                      context,
                      icon: Icons.comment_outlined,
                      iconColor: Colors.grey,
                      label:
                          '${post.commentsCount} Comment${post.commentsCount != 1 ? 's' : ''}',
                      onTap: () => showCommentsBottomSheet(context, post.id),
                    ),
                    // Share Button
                    _buildActionButton(
                      context,
                      icon: Icons.share_outlined,
                      iconColor: Colors.grey,
                      label: 'Share',
                      onTap: () {
                        // TODO: Implement share
                      },
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/screens/common/apply_job/apply_job_page.dart';
import 'package:jobportal/screens/conversation/chatting_screen.dart';
import 'package:provider/provider.dart';

import '../utils/app_routes.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final bool showMoreOptions;

  const JobCard({super.key, required this.job, this.showMoreOptions = false});

  Widget _buildLogo() {
    final imageUrl = job.company?.companyLogo;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback for loading errors
            return _buildFallbackIcon();
          },
        ),
      );
    }
    // Fallback if URL is null or empty
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    // Fallback icon
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.business),
    );
  }

  Widget _buildStatusTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusOrPostedDate(Job job) {
    if (job.isExpired) {
      return _buildStatusTag(
        'Expired',
        Colors.red.shade100,
        Colors.red.shade800,
      );
    }
    if (job.applicationStatus.toLowerCase() == 'interviewed') {
      return _buildStatusTag(
        'Interview',
        Colors.green.shade100,
        Colors.green.shade800,
      );
    }
    if (job.isApplied) {
      return _buildStatusTag(
        'Applied',
        Colors.blue.shade100,
        Colors.blue.shade800,
      );
    }
    return Text(
      "Posted ${formatTimeAgo(job.postedAt)}",
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFFAAA6B9),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create tags from job properties
    final tags =
        [
          job.specialization,
          job.jobType,
          job.position,
        ].where((t) => t != null && t.isNotEmpty).toList();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.jobDetail, arguments: job.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(),
                  const Spacer(),
                  if (showMoreOptions)
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => JobOptionsSheet(job: job),
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF524B6B),
                          size: 24,
                        ),
                      ),
                    )
                  else
                    Consumer<JobProvider>(
                      builder: (context, jobProvider, child) {
                        final isSaved = jobProvider.isJobSaved(job);
                        return IconButton(
                          onPressed: () => jobProvider.toggleSaveJob(job),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              key: ValueKey<bool>(
                                isSaved,
                              ), // Important for AnimatedSwitcher
                              color: const Color(0xFF524B6B),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                job.jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D0140),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${job.company?.companyName ?? 'N/A'} · ${job.jobLocation ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF524B6B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0, // Horizontal space between tags
                runSpacing: 8.0, // Vertical space between lines of tags
                children:
                    tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF524B6B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusOrPostedDate(job),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: job.salary,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D0140),
                          ),
                        ),
                        const TextSpan(
                          text: '', // Salary from API already contains this
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF524B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Job Options Bottom Sheet
class JobOptionsSheet extends StatelessWidget {
  final Job job;

  const JobOptionsSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _OptionItem(
            icon: Icons.send_outlined,
            label: 'Send message',
            onTap: () async {
              Navigator.pop(context);

              if (job.company == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Company information not available'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                final conversation = await chatProvider.startConversation(
                  job.company!.id,
                );

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChattingScreen(
                            conversation: conversation,
                            chatProvider: chatProvider,
                            initialJob: job,
                          ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error starting conversation: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          _OptionItem(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
          ),
          _OptionItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: () {
              Provider.of<JobProvider>(
                context,
                listen: false,
              ).removeJobFromSaved(job);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job removed from saved')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplyJobPage(job: job),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF130160),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 22,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF524B6B), size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D0140),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

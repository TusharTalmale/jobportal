import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobportal/model.dart/job_application_comment.dart';
import 'package:provider/provider.dart';

import '../../model.dart/job_application.dart';
import '../../provider/job_application_provider.dart';

class ApplicationDetailsPage extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailsPage({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final job = application.jobDetails;
    final company = job?['company'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Application Details",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildJobHeader(job, company),
          const SizedBox(height: 20),
          _buildStatusTimeline(),
          const SizedBox(height: 20),
          _buildResumeSection(context),
          const SizedBox(height: 20),
          _buildShareProfile(context),
          const SizedBox(height: 20),
          _buildCommentsSection(context),
          const SizedBox(height: 20),
          _buildReviewNotes(),
          const SizedBox(height: 40),
          _buildWithdrawButton(context),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // JOB HEADER
  // ----------------------------------------------------------
  Widget _buildJobHeader(dynamic job, dynamic company) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              company["companyLogo"] ?? "",
              width: 55,
              height: 55,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.apartment, size: 55),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job?["jobTitle"] ?? "Unknown Title",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  company["companyName"] ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat("dd MMM yyyy").format(
                    application.createdAt ?? DateTime.now(),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // STATUS TIMELINE
  // ----------------------------------------------------------
  Widget _buildStatusTimeline() {
    List<String> allStages = [
      "applied",
      "shortlisted",
      "interviewed",
      "hired"
    ];

    int currentIndex = allStages.indexOf(application.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Application Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),

          // Timeline
          Column(
            children: List.generate(allStages.length, (i) {
              bool isDone = i <= currentIndex;
              bool isCurrent = i == currentIndex;

              return Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    allStages[i].toUpperCase(),
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isDone ? Colors.green : Colors.grey.shade700,
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // RESUME PREVIEW
  // ----------------------------------------------------------
  Widget _buildResumeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Resume",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (application.resumeFiles?.isEmpty ?? true)
            const Text("No resume uploaded",
                style: TextStyle(color: Colors.grey))
          else
            Column(
              children: application.resumeFiles!.map((fileUrl) {
                return GestureDetector(
                  onTap: () {
                    // Open PDF viewer
                    // TODO: implement viewer
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            fileUrl.split("/").last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SHARE PROFILE
  // ----------------------------------------------------------
  Widget _buildShareProfile(BuildContext context) {
    final provider = Provider.of<JobApplicationProvider>(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Share Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Switch(
            value: application.sharedProfile,
            onChanged: (value) async {
              await provider.toggleShare(application.id, value);
            },
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // COMMENTS SECTION (Opens Bottom Sheet)
  // ----------------------------------------------------------
  Widget _buildCommentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Comments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => CommentsSheet(application: application),
                ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("View Comments"),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // REVIEW NOTES
  // ----------------------------------------------------------
  Widget _buildReviewNotes() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Review Notes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            application.reviewNotes ?? "No review notes added.",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WITHDRAW BUTTON
  // ----------------------------------------------------------
  Widget _buildWithdrawButton(BuildContext context) {
    final provider = Provider.of<JobApplicationProvider>(context);

    if (application.status == "withdrawn" ||
        application.status == "rejected" ||
        application.status == "hired") {
      return const SizedBox();
    }

    return ElevatedButton(
      onPressed: () async {
        await provider.withdraw(application.id);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("Withdraw Application"),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
            color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
      ],
    );
  }
}



class CommentsSheet extends StatefulWidget {
  final JobApplication application;

  const CommentsSheet({super.key, required this.application});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<JobApplicationComment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.application.comments ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobApplicationProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.40,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _comments.isEmpty
                    ? const Center(
                        child: Text(
                          "No comments yet",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _comments.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return _buildCommentTile(_comments[index], provider);
                        },
                      ),
              ),

              _buildInputBox(provider),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // COMMENT ITEM TILE (Instagram Style)
  // ----------------------------------------------------------
  Widget _buildCommentTile(
    JobApplicationComment comment,
    JobApplicationProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name
                  Text(
                    comment.authorName ?? "User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // text
                  Text(
                    comment.text,
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  // timestamp + hide/delete option
                  Row(
                    children: [
                      Text(
                        _formatTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(width: 10),

                      PopupMenuButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        onSelected: (value) async {
                          if (value == "hide") {
                            await provider.updateCommentStatus(
                              widget.application.id,
                              comment.id.toString(),
                              "hidden",
                            );
                            setState(() {
                              comment = comment.copyWith(status: "hidden");
                              _comments.remove(comment);
                            });
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: "hide",
                            child: Text("Hide comment"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // COMMENT INPUT BOX
  // ----------------------------------------------------------
  Widget _buildInputBox(JobApplicationProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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
                hintText: "Write a comment...",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.indigo,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSend(provider),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SEND COMMENT ACTION
  // ----------------------------------------------------------
  Future<void> _handleSend(JobApplicationProvider provider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final success =
        await provider.addComment(widget.application.id, text);

    if (success) {
      setState(() {
        _comments.insert(
          0,
          JobApplicationComment(
            id: DateTime.now().millisecondsSinceEpoch,
            text: text,
            authorId: provider.userId,
            authorName: "You",
            createdAt: DateTime.now(),
            status: "visible",
          ),
        );
      });
    }

    _controller.clear();
  }
  
  
  String _formatTime(DateTime? time) {
    if (time == null) return "";

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return "${time.day}/${time.month}/${time.year}";
  }}
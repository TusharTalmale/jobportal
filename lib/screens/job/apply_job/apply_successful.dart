import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/model.dart/job_application.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/screens/job/apply_job/apply_job_page.dart';

class ApplySuccessfulPage extends StatelessWidget {
  final Job job;
  final UploadedFile file;
  final JobApplication? jobApplication;

  const ApplySuccessfulPage({
    super.key,
    required this.job,
    required this.file,
    this.jobApplication,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate back to the home or job list
            Navigator.of(
              context,
            ).popUntil((route) => route.isFirst); // Go back to root
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFileUploadedBox(),
            const SizedBox(height: 48),
            _buildSuccessGraphic(),
            const SizedBox(height: 24),
            Text(
              'Successful',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations, your application has been sent',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (jobApplication != null) ...[
              const SizedBox(height: 24),
              _buildApplicationStatusCard(),
            ],
            const SizedBox(height: 48),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          if (job.company?.companyGallery?.isNotEmpty ?? false)
            Image.network(
              job.company!.companyGallery!.first,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.business, size: 80, color: Colors.grey),
            )
          else
            const Icon(Icons.business, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            job.jobTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                job.company?.companyName ?? 'N/A',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (job.jobLocation != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.circle, size: 6, color: Colors.grey),
                ),
                Text(
                  job.jobLocation!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
              const Icon(Icons.circle, size: 6, color: Colors.grey),
              Text(
                "Posted ${formatTimeAgo(job.postedAt)}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadedBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/pdf_icon.png', // Use local asset
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.fileSize} • ${file.date}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessGraphic() {
    // Placeholder graphic
    return const Icon(
      Icons.check_circle_outline,
      color: Colors.green,
      size: 100,
    );
  }

  Widget _buildApplicationStatusCard() {
    if (jobApplication == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Details',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                'Status',
                jobApplication!.status.toUpperCase(),
                _getStatusColor(jobApplication!.status),
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                'Submitted',
                jobApplication!.createdAt != null
                    ? formatTimeAgo(jobApplication!.createdAt)
                    : 'Just now',
                Colors.blue,
              ),
              if (jobApplication!.resumeFiles?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Resume',
                  '${jobApplication!.resumeFiles!.length} file(s) uploaded',
                  Colors.green,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'shortlisted':
        return Colors.orange;
      case 'interviewed':
        return Colors.purple;
      case 'hired':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Logic to find similar jobs
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6DFFF), // Light purple
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Center(
              child: Text(
                'FIND A SIMILAR JOB',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30009C), // Dark purple text
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF30009C), // Dark purple
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                'BACK TO HOME',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/job_application_provider.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:jobportal/screens/common/apply_job/apply_successful.dart';

/// A simple model to represent an uploaded file for this screen.
class UploadedFile {
  final String fileName;
  final String fileSize;
  final String date;
  final String filePath;

  UploadedFile({
    required this.fileName,
    required this.fileSize,
    required this.date,
    required this.filePath,
  });

  /// Get file size from file path
  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

class ApplyJobPage extends StatefulWidget {
  final Job job;
  const ApplyJobPage({super.key, required this.job});

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  UploadedFile? _uploadedFile;
  final TextEditingController _infoController = TextEditingController();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() {
    final provider = context.read<JobApplicationProvider>();
    if (provider.currentUserId == null) {
      // Set current user if not already set
      provider.setCurrentUser(1, 'user'); // In real app, get from auth
    }
  }

  Future<void> _pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final fileSize = UploadedFile.getFileSize(filePath);

        setState(() {
          _uploadedFile = UploadedFile(
            fileName: fileName,
            fileSize: fileSize,
            date: 'Now',
            filePath: filePath,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume uploaded: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _uploadedFile = null;
    });
  }

  Future<void> _submitApplication() async {
    if (_uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your CV/Resume'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      final provider = context.read<JobApplicationProvider>();

      final response = await provider.createApplication(
        jobId: widget.job.id,
        userId: provider.currentUserId ?? 1,
        resumeFilePaths: [_uploadedFile!.filePath],
      );

      if (response != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => ApplySuccessfulPage(
                  job: widget.job,
                  file: _uploadedFile!,
                  jobApplication: response.application,
                ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to submit application',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildUploadCVSection(),
            const SizedBox(height: 24),
            _buildInformationSection(),
            _buildApplyButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // bottomSheet: _buildApplyButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          if (widget.job.company?.companyLogo?.isNotEmpty ?? false)
            Image.network(
              widget.job.company!.companyLogo!,
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
            widget.job.jobTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            children: [
              Text(
                widget.job.company?.companyName ?? 'N/A',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (widget.job.jobLocation != null) ...[
                const Icon(Icons.circle, size: 6, color: Colors.grey),
                Text(
                  widget.job.jobLocation!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
              const Icon(Icons.circle, size: 6, color: Colors.grey),
              Text(
                "Posted ${formatTimeAgo(widget.job.postedAt)}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildUploadCVSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Upload Your CV'),
          const SizedBox(height: 10),
          Text(
            'Submit your resume to apply for this job',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _uploadedFile == null
              ? _buildUploadBox()
              : _buildFileUploadedBox(_uploadedFile!),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickResumeFile,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: const Color(0xFF30009C).withOpacity(0.3),
                strokeWidth: 2.5,
                radius: const Radius.circular(14),
                dashPattern: const [10, 6],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF30009C).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30009C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF30009C),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload CV/Resume',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30009C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'or drag and drop',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStoredResumesSection(),
      ],
    );
  }

  Widget _buildStoredResumesSection() {
    return Consumer<JobApplicationProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Or use stored resume',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile resume picker - coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.person, size: 20),
              label: const Text('Select from Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF30009C),
                side: const BorderSide(color: Color(0xFF30009C), width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileUploadedBox(UploadedFile file) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/pdf_icon.png',
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${file.fileSize} • ${file.date}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _removeFile,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tell Us About Yourself'),
          const SizedBox(height: 16),
          TextField(
            controller: _infoController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Explain why you\'re the right fit for this role...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF30009C),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            'Tips: Mention relevant skills, achievements, or experience',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Consumer<JobApplicationProvider>(
        builder: (context, provider, _) {
          final isLoading = _isApplying || provider.isLoading;
          return CustomButton(
            label: isLoading ? 'SUBMITTING...' : 'APPLY NOW',
            onPressed: _submitApplication,
            isLoading: isLoading,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }
}

/// A custom painter to draw a dashed border around a rounded rectangle.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Radius radius;
  final List<double> dashPattern;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.radius = const Radius.circular(0),
    this.dashPattern = const [8, 4],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            radius,
          ),
        );

    final dashWidth = dashPattern.isNotEmpty ? dashPattern[0] : 5.0;
    final dashSpace = dashPattern.length > 1 ? dashPattern[1] : 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

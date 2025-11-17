import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/screens/job/apply_job/apply_successful.dart';

/// A simple model to represent an uploaded file for this screen.
class UploadedFile {
  final String fileName;
  final String fileSize;
  final String date;

  UploadedFile({
    required this.fileName,
    required this.fileSize,
    required this.date,
  });
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

  void _uploadFile() {
    // This is a simulation. In a real app, you'd use file_picker
    setState(() {
      _uploadedFile = UploadedFile(
        fileName: 'My_CV_Resume.pdf',
        fileSize: '867 Kb',
        date: 'Uploaded today',
      );
    });
  }

  void _removeFile() {
    setState(() {
      _uploadedFile = null;
    });
  }

  void _submitApplication() {
    // In a real app, you'd send the data to a server
    if (_uploadedFile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  ApplySuccessfulPage(job: widget.job, file: _uploadedFile!),
        ),
      );
    } else {
      // Show some error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your CV/Resume'),
          backgroundColor: Colors.red,
        ),
      );
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
            _buildUploadCVSection(),
            const SizedBox(height: 24),
            _buildInformationSection(),
          ],
        ),
      ),
      bottomSheet: _buildApplyButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          if (widget.job.company?.companyGallery?.isNotEmpty ?? false)
            Image.network(
              widget.job.company!.companyGallery!.first,
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUploadCVSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Upload CV'),
          const SizedBox(height: 8),
          Text(
            'Add your CV/Resume to apply for a job',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _uploadedFile == null
              ? _buildUploadBox()
              : _buildFileUploadedBox(_uploadedFile!),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _uploadFile,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.grey[400]!,
          strokeWidth: 2,
          radius: const Radius.circular(12),
          dashPattern: const [8, 4],
        ),
        child: Container(
          // The painter draws on the border, so the child needs padding
          // to not overlap with the border.
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                'Upload CV/Resume',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadedBox(UploadedFile file) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/pdf_icon.png', width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            // This will prevent the row from overflowing
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
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _removeFile,
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
          _buildSectionTitle('Information'),
          const SizedBox(height: 16),
          TextField(
            controller: _infoController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Explain why you are the right person for this job',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[700]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF30009C), // Dark purple
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'APPLY NOW',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
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

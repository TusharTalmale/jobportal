import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/screens/job/apply_job/apply_job_page.dart';
import 'package:jobportal/screens/conversation/chatting_screen.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobId;

  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  // 0 = Description, 1 = Company
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Add the job to the recent list when the page is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final job = jobProvider.getJobById(widget.jobId);
      if (job != null) {
        // No need to await here, just fire and forget.
        // The provider will handle saving and notify listeners.
        jobProvider.addRecentJob(job);
      }
    });
  }

  void _shareJob(Job job, BuildContext context) {
    final String jobTitle = job.jobTitle;
    final String companyName = job.company?.companyName ?? 'a company';
    // In a real app, you would generate a deep link to this specific job page.
    final String textToShare =
        'Check out this job opening for a "$jobTitle" at $companyName. Find more details in the app!';
    final String subject = 'Job Opening: $jobTitle at $companyName';

    Share.share(textToShare, subject: subject);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context);
    final job = jobProvider.getJobById(widget.jobId);

    // Handle the case where the job might not be found
    if (job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Job not found!')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              jobProvider.isJobSaved(job)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: Colors.black,
            ),
            onPressed: () {
              jobProvider.toggleSaveJob(job);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              _shareJob(job, context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(job),
            const SizedBox(height: 16),
            _buildTabSwitcher(),
            const SizedBox(height: 24),
            // Show content based on the selected tab
            IndexedStack(
              index: _selectedTabIndex,
              children: <Widget>[
                _buildDescriptionContent(job),
                _buildCompanyContent(job),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomButtons(chatProvider, jobProvider, job),
    );
  }

  Widget _buildHeader(Job job) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (job.company?.companyLogo != null &&
              job.company!.companyLogo!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                job.company!.companyLogo!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.business,
                      size: 80,
                      color: Colors.grey,
                    ),
              ),
            )
          else
            const Icon(Icons.business, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            job.jobTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8.0, // Horizontal spacing between items
            runSpacing: 4.0, // Vertical spacing between lines
            children: [
              if (job.company?.companyName != null)
                Text(
                  job.company!.companyName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              if (job.jobLocation != null) ...[
                const Icon(Icons.circle, size: 6, color: Colors.grey),
                Text(
                  job.jobLocation!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
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

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Description', 0)),
          Expanded(child: _buildTabItem('Company', 1)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- DESCRIPTION CONTENT ---

  Widget _buildDescriptionContent(Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoTabs(job),
        const SizedBox(height: 24),
        _buildSectionTitle('Job Description'),
        _buildDescription(job),
        const SizedBox(height: 24),
        _buildSectionTitle('Requirements'),
        _buildRequirements(job),
        const SizedBox(height: 24),
        _buildSectionTitle('Location'),
        _buildLocation(job),
        const SizedBox(height: 24),
        _buildSectionTitle('Informations'),
        _buildInformations(job),
        const SizedBox(height: 24),
        _buildSectionTitle('Facilities and Others'),
        _buildFacilities(job),
      ],
    );
  }

  Widget _buildInfoTabs(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoTab('Salary', job.salary, Icons.money_outlined),
          _buildInfoTab('Job Type', job.jobType, Icons.work_outline),
          _buildInfoTab('Position', job.position, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildInfoTab(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty)
      return const Expanded(child: SizedBox());
    return Expanded(
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue[700], size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescription(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobDescription ?? 'No description available.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {
              // Expand text logic
            },
            child: Text(
              'Read more',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child:
          job.requirements != null && job.requirements!.isNotEmpty
              ? Column(
                children:
                    (job.requirements ?? '')
                        .split('\n')
                        .map((req) => _buildRequirementItem(req))
                        .toList(),
              )
              : const Text("No requirements specified."),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(job.latitude, job.longitude),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jobportal',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(job.latitude, job.longitude),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.jobLocation ?? 'Location not specified.',
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildInformations(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildInfoRow('Position', job.position),
          _buildInfoRow('Qualification', job.qualification),
          _buildInfoRow('Experience', job.experience),
          _buildInfoRow('Job Type', job.jobType),
          _buildInfoRow('Status', job.status?.toUpperCase()),
          _buildInfoRow('Expires At', formatFullDate(job.expiresAt)),
          _buildInfoRow('Specialization', job.specialization),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      // This was missing a null check
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilities(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child:
          job.facilities != null && job.facilities!.isNotEmpty
              ? Column(
                children:
                    (job.facilities ?? '')
                        .split('\n')
                        .map((facility) => _buildRequirementItem(facility))
                        .toList(),
              )
              : const Text("No facilities listed."),
    );
  }

  // --- COMPANY CONTENT ---

  Widget _buildCompanyContent(Job job) {
    final company = job.company;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About Company'),
          Text(
            // Null check
            company?.aboutCompany ??
                'No information available about the company.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Website', company?.website ?? '-'),
          _buildInfoRow('Industry', company?.industry),
          _buildInfoRow('Email', company?.email),
          _buildInfoRow('Phone', company?.phone),
          _buildInfoRow('Employee size', company?.companySize ?? '-'),
          _buildInfoRow('Head office', company?.headOffice ?? '-'),
          _buildInfoRow('Type', company?.companyType ?? '-'),
          _buildInfoRow('Since', company?.establishedSince.toString() ?? '-'),
          _buildInfoRow('Specialization', company?.specialization ?? '-'),
          const SizedBox(height: 24),
          _buildSectionTitle('Company Gallery'),
          _buildCompanyGallery(company?.companyGallery ?? []),
        ],
      ),
    );
  }

  Widget _buildCompanyGallery(List<String> images) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(images.isNotEmpty ? images[0] : ''),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // This will be called if the image fails to load, e.g., due to CORS
                    debugPrint(
                      "Error loading company gallery image: $exception",
                    );
                  },
                ),
                color: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(images.length > 1 ? images[1] : ''),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint(
                      "Error loading company gallery image: $exception",
                    );
                  },
                ),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${images.length - 2} pics',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMMON WIDGETS ---

  Widget _buildBottomButtons(
    ChatProvider chatProvider,
    JobProvider jobProvider,
    Job job,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: Row(
          children: [
            // Bookmark button
            GestureDetector(
              onTap: () {
                ;
                jobProvider.toggleSaveJob(job);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  jobProvider.isJobSaved(job)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Chat button
            OutlinedButton(
              onPressed: () async {
                final conversation = await chatProvider.startConversation(
                  job.company!.id, // Use company ID
                );
                if (mounted) {
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
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue[700]!),
              ),
              child: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Apply Now button (Expanded)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ApplyJobPage(job: job),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'APPLY NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

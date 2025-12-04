import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/screens/common/details/company_detail_screen.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/screens/common/apply_job/apply_job_page.dart';
import 'package:jobportal/screens/conversation/chatting_screen.dart';
import 'package:jobportal/utils/date_formatter.dart';
import 'package:jobportal/widgets/common_job_card.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.getJobById(widget.jobId);
    });
  }

  void _shareJob(Job job) {
    final String jobTitle = job.jobTitle;
    final String companyName = job.company?.companyName ?? 'a company';
    final String textToShare =
        'Check out this job opening for a "$jobTitle" at $companyName. Find more details in the app!';
    final String subject = 'Job Opening: $jobTitle at $companyName';

    Share.share(textToShare, subject: subject);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context);
    final job = jobProvider.selectedJob;

    if (jobProvider.isJobLoading || job == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: jobProvider.errorMessage != null
              ? Text(
                  jobProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
       
        backgroundColor: Colors.grey[100],
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                pinned: true,
                floating: false,
                
                expandedHeight: 280,
                                    title: Text(job!.jobTitle , style: TextStyle(color: Colors.black  ,fontSize: 12 , fontWeight: FontWeight.bold),) ,

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
                      _shareJob(job);
                    },
                  ),
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    bottom: false,
                    child: _buildHeader(job),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(_buildTabBar()),
              ),
            ];
          },
          body: Container(
            color: Colors.grey[100],
            child: TabBarView(
              children: [
                _buildDescriptionContent(job),
                _buildCompanyContent(job),
                _buildSimilarJobs(jobProvider.similarJobs),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomButtons(
          chatProvider,
          jobProvider,
          job,
          context,
        ),
      ),
    );
  }

  // ---------------- HEADER (Company + Job info) ----------------

  Widget _buildHeader(Job job) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30,),
          if (job.company?.companyLogo != null &&
              job.company!.companyLogo!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                job.company!.companyLogo!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            )
          else
            const Icon(Icons.business, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            job.jobTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              if (job.company?.companyName != null)
                Text(
                  job.company!.companyName!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              if (job.jobLocation != null) ...[
                const Icon(Icons.circle, size: 6, color: Colors.grey),
                Text(
                  job.jobLocation!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                                const Icon(Icons.circle, size: 6, color: Colors.grey),

                 Text(
                "Posted ${formatTimeAgo(job.postedAt)}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              ],
             
            ],
          ),
          const SizedBox(height: 16),
          if (job.isExpired)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Expired",
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!job.isExpired && job.isApplied)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Applied (${job.applicationStatus})",
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- TAB BAR (3 tabs) ----------------

  TabBar _buildTabBar() {
    return TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue[700],
      ),
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: 'Description'),
        Tab(text: 'Company'),
        Tab(text: 'Similar Jobs'),
      ],
    );
  }

  // ---------------- DESCRIPTION TAB ----------------

  Widget _buildDescriptionContent(Job job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildInfoTabs(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoTab('Salary', job.salary ?? "${job.maxSalary} - ${job.minSalary}" , Icons.money_outlined),
          _buildInfoTab('Job Type', job.jobType, Icons.work_outline),
          _buildInfoTab('Position', job.position, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildInfoTab(String label, String? value, IconData icon) {
    if (value == null || value.isEmpty) {
      return const Expanded(child: SizedBox());
    }
    return Expanded(
      child: Card(
        elevation: 0,
        color: const Color(0xFFF8F9FA),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        job.jobDescription ?? 'No description available.',
        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
      ),
    );
  }

  Widget _buildRequirements(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: job.requirements != null && job.requirements!.isNotEmpty
          ? Column(
              children: (job.requirements ?? '')
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
                  initialCenter: LatLng(
                    job.lattitude ?? 0.0,
                    job.longitude ?? 0.0,
                  ),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jobportal',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          job.lattitude ?? 0.0,
                          job.longitude ?? 0.0,
                        ),
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

  Widget _buildFacilities(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: job.facilities != null && job.facilities!.isNotEmpty
          ? Column(
              children: (job.facilities ?? '')
                  .split('\n')
                  .map((facility) => _buildRequirementItem(facility))
                  .toList(),
            )
          : const Text("No facilities listed."),
    );
  }

  // ---------------- COMPANY TAB ----------------

  Widget _buildCompanyContent(Job job) {
    final company = job.company;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About Company'),
          Text(
            company?.aboutCompany ??
                'No information available about the company.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              if (company != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyDetailScreen(companyId: company.id),
                  ),
                );
              }
            },
            child: _buildInfoRow(
              'Website',
              company?.website ?? '-',
              isLink: true,
            ),
          ),
          _buildInfoRow('Industry', company?.industry),
          _buildInfoRow('Email', company?.email),
          _buildInfoRow('Phone', company?.phone ?? '-'),
          _buildInfoRow('Employee size', company?.companySize ?? '-'),
          _buildInfoRow('Head office', company?.headOffice ?? '-'),
          _buildInfoRow('Type', company?.companyType ?? '-'),
          _buildInfoRow('Since', company?.establishedSince?.toString() ?? '-'),
          _buildInfoRow('Specialization', company?.specialization ?? '-'),
          const SizedBox(height: 24),
          if (company?.companyGallery?.isNotEmpty ?? false) ...[
            _buildSectionTitle('Company Gallery'),
            _buildCompanyGallery(company!.companyGallery!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {bool isLink = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isLink ? Colors.blue[700] : Colors.black,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyGallery(List<String> images) {
    if (images.isEmpty) return const Text("No gallery images available.");

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
            child: images.length > 1
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(images[1]),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint(
                            "Error loading company gallery image: $exception",
                          );
                        },
                      ),
                      color: Colors.grey[200],
                    ),
                    child: images.length > 2
                        ? Center(
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
                                '+${images.length - 2}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : null,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // ---------------- SIMILAR JOBS TAB ----------------

  Widget _buildSimilarJobs(List<Job> jobs) {
    return jobs.isEmpty
        ? Center(
            child: Text(
              "No similar jobs available.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final j = jobs[index];
              return JobCard(job: j);
            },
          );
  }

  // ---------------- BOTTOM BUTTONS ----------------

  Widget _buildBottomButtons(
    ChatProvider chatProvider,
    JobProvider jobProvider,
    Job job,
    BuildContext context,
  ) {
    if (job.isApplied) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: ElevatedButton(
          onPressed: () async {
            if (job.company == null) return;
            final c = await chatProvider.startConversation(job.company!.id);
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChattingScreen(
                  conversation: c,
                  chatProvider: chatProvider,
                  initialJob: job,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Chat with Recruiter",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => jobProvider.toggleSaveJob(job),
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
          OutlinedButton(
            onPressed: job.isExpired
                ? null
                : () async {
                    if (job.company == null) return;
                    final c =
                        await chatProvider.startConversation(job.company!.id);
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChattingScreen(
                          conversation: c,
                          chatProvider: chatProvider,
                          initialJob: job,
                        ),
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              side: BorderSide(color: Colors.blue[700]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Chat",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: job.isExpired
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplyJobPage(job: job),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                job.isExpired ? "EXPIRED" : "APPLY NOW",
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

// ---------------- TABBAR SLIVER DELEGATE ----------------

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

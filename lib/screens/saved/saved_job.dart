import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobportal/provider/job_application_provider.dart';
import 'package:jobportal/widgets/applied_job_card.dart';
import 'package:jobportal/widgets/common_job_card.dart';
import 'package:provider/provider.dart';

import '../../provider/job_provider.dart';
import '../../model.dart/job.dart'; // Assuming Job model is here

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobApplicationProvider =
          Provider.of<JobApplicationProvider>(context, listen: false);
      if (jobApplicationProvider.applications.isEmpty) {
        jobApplicationProvider.loadFirstPage();
      }
    });
    _tabController = TabController(length: 2, vsync: this);
    // Add listener to update UI on search query change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _tabController.addListener(() {
      // To update the visibility of the "Delete All" button
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Jobs',
                    style: TextStyle(
                      color: Color(0xFF0D0140),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Consumer<JobProvider>(
                    builder: (context, jobProvider, _) {
                      final showDelete =
                          _tabController.index == 0 &&
                          jobProvider.savedJobs.isNotEmpty;
                      if (!showDelete) return const SizedBox();
                      return GestureDetector(
                        onTap: () => _showDeleteAllConfirmation(context),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(
                            color: Color(0xFFFF9228),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      _tabController.index == 0
                          ? 'Search saved jobs by title or company...'
                          : 'Search applied jobs by title or company...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                ),
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.orange,
                tabs: const [
                  Tab(text: 'Saved Jobs'),
                  Tab(text: 'Applied Jobs'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildSavedJobsList(), _buildAppliedJobsList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final isSavedTab = _tabController.index == 0;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Delete All?'),
          content: Text(
            'Are you sure you want to delete all ${isSavedTab ? 'saved' : 'applied'} jobs? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                jobProvider.deleteAllJobs();
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<Job> _filterJobs(List<Job> jobs) {
    if (_searchQuery.isEmpty) {
      return jobs;
    }
    return jobs.where((job) {
      final query = _searchQuery.toLowerCase();
      final title = job.jobTitle.toLowerCase();
      final company = (job.company?.companyName ?? '').toLowerCase();
      final location = (job.jobLocation ?? '').toLowerCase();
      final jobType = (job.jobType ?? '').toLowerCase();
      final position = (job.position ?? '').toLowerCase();

      return title.contains(query) ||
          company.contains(query) ||
          location.contains(query) ||
          jobType.contains(query) ||
          position.contains(query);
    }).toList();
  }

  Widget _buildSavedJobsList() {
    return Consumer<JobProvider>(
      builder: (context, provider, _) {
        if (provider.savedJobs.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Saved Jobs',
            message:
                'You don\'t have any jobs saved yet.\nStart searching and save jobs you like!',
          );
        }
        final filtered = _filterJobs(provider.savedJobs);

        if (filtered.isEmpty && _searchQuery.isNotEmpty) {
          return _buildEmptySearchResults();
        }

        final groupedJobs = _groupJobsByMonth(filtered);
        return _buildGroupedJobListWithHeader(
          groupedJobs,
          filtered.length,
          provider.savedJobs.length,
        );
      },
    );
  }

  Widget _buildAppliedJobsList() {
    return Consumer<JobApplicationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.applications.isEmpty) {
          return _buildShimmerList();
        }

        if (provider.applications.isEmpty) {
          return const EmptyStateWidget(
            title: "No Applied Jobs",
            message:
                "You haven't applied for any jobs yet. Your applied jobs will appear here.",
          );
        }

        final apps = provider.applications;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!provider.isLoadMore &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              provider.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length + (provider.isLoadMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == apps.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return AppliedJobCard(application: apps[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder:
          (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results for "$_searchQuery"',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching by job title, company name,\nlocation, job type, or position',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedJobListWithHeader(
    Map<String, List<Job>> groupedJobs,
    int filteredCount,
    int totalCount,
  ) {
    if (groupedJobs.isEmpty && _searchQuery.isNotEmpty) {
      return _buildEmptySearchResults();
    }

    final months = groupedJobs.keys.toList();

    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Found $filteredCount of $totalCount result${filteredCount != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final jobsInMonth = groupedJobs[month]!;
              return _buildMonthSection(month, jobsInMonth);
            },
          ),
        ),
      ],
    );
  }

  Map<String, List<Job>> _groupJobsByMonth(List<Job> jobs) {
    final Map<String, List<Job>> grouped = {};
    for (var job in jobs) {
      // Assuming Job has a 'createdAt' DateTime property
      final monthYear = DateFormat(
        'MMMM yyyy',
      ).format(job.postedAt ?? DateTime.now());
      if (grouped[monthYear] == null) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(job);
    }
    return grouped;
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD28F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 15,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC0CB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 35,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB380),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 35,
                    right: 50,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4B3F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E3FDF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D0140),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF524B6B),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to search/jobs page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF130160),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'FIND A JOB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
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

Widget _buildMonthSection(String month, List<Job> jobs) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
        child: Text(
          month,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
      ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index]; // This is a Job object
          return JobCard(
            job: job,
            showMoreOptions: true,
          ); // Assuming JobCard exists and takes a Job
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
      const SizedBox(height: 24),
    ],
  );
}

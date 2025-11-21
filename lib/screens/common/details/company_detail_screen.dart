import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/widgets/company_post_card.dart';
import 'package:provider/provider.dart';
import '../../../widgets/common_job_card.dart';

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(
        context,
        listen: false,
      ).fetchPostsByCompany(widget.companyId, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final company = jobProvider.getCompanyById(widget.companyId);

    if (company == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Company Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Company not found or still loading...'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // Company Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  // Company Logo
                  // if (company.companyLogo != null &&
                  //     company.companyLogo!.isNotEmpty)
                  //   Container(
                  //     width: 60,
                  //     height: 60,
                  //     decoration: BoxDecoration(
                  //       color: Colors.blue[100],
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: ClipOval(
                  //       child: Image.network(
                  //         company.companyLogo!,
                  //         fit: BoxFit.cover,
                  //         errorBuilder: (context, error, stackTrace) {
                  //           return const Icon(
                  //             Icons.business,
                  //             size: 40,
                  //             color: Colors.blue,
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   Container(
                  //     width: 60,
                  //     height: 60,
                  //     decoration: BoxDecoration(
                  //       color: Colors.blue[100],
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: const Icon(
                  //       Icons.business,
                  //       size: 30,
                  //       color: Colors.blue,
                  //     ),
                  //   ),
                  // const SizedBox(height: 12),
// Company Logo
if (company.companyLogo != null && company.companyLogo!.isNotEmpty)
  Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(8), // small rounded square
    ),
    child: Image.network(
      company.companyLogo!,
      fit: BoxFit.contain, // show full logo without cropping
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.business,
          size: 40,
          color: Colors.blue,
        );
      },
    ),
  )
else
  Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.business,
      size: 40,
      color: Colors.blue,
    ),
  ),
const SizedBox(height: 12),

                  // Job Title
                  Text(
                    company.companyName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Company Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 8),
                      //   width: 4,
                      //   height: 4,
                      //   decoration: const BoxDecoration(
                      //     color: Colors.black,
                      //     shape: BoxShape.circle,
                      //   ),
                      // ),
                      Text(
                        company.location ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 8),
                      //   width: 4,
                      //   height: 4,
                      //   decoration: const BoxDecoration(
                      //     color: Colors.black,
                      //     shape: BoxShape.circle,
                      //   ),
                      // ),
                      // const Text(
                      //   '1 day ago',
                      //   style: TextStyle(fontSize: 14, color: Colors.black87),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            company,
                            isFollowButton: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            company,
                            isFollowButton: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      
                    ),
                  
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.orange,
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("About us"),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Posts"),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Jobs"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[100],
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: TabBar(
                  //     labelColor: Colors.white,
                  //     unselectedLabelColor: Colors.black,

                  //     indicator: BoxDecoration(
                  //       color: Colors.orange,
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     dividerColor: Colors.transparent,
                  //     labelStyle: const TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //     tabs: const [
                  //       Tab(text: 'About us'),
                  //       Tab(text: 'Post'),
                  //       Tab(text: 'Jobs'),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildAboutSection(company),
                  _buildPostsSection(company),
                  _buildJobsSection(company),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Company company, {
    required bool isFollowButton,
  }) {
    final provider = Provider.of<NetworkProvider>(context);
    final isFollowing = provider.following.contains(company.id);

    if (isFollowButton) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: isFollowing ? Colors.pink[50] : Colors.pink[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => provider.toggleFollow(company.id),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFollowing ? Icons.check : Icons.add,
                  color: Colors.pink,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    color: Colors.pink,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (company.website != null && company.website!.isNotEmpty) {
                final Uri url = Uri.parse(company.website!);
                if (!await launchUrl(url)) {
                  // Optionally, show a snackbar or toast on failure
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch ${company.website}')),
                    );
                  }
                }
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_new, color: Colors.pink, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Visit website',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildAboutSection(Company company) {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Company',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              company.aboutCompany ?? 'No information available.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoTile('Website', company.website, isLink: true),
            _buildInfoTile('Industry', company.industry),
            _buildInfoTile('Email', company.email),
            _buildInfoTile('Phone', company.phone),
            _buildInfoTile('LinkedIn', company.linkedin),
            _buildInfoTile('Instagram', company.instagram),
            _buildInfoTile('Employee size', company.companySize),
            _buildInfoTile('Head office', company.headOffice),
            _buildInfoTile('Type', company.companyType),
            _buildInfoTile(
              'Since',
              company.establishedSince?.toString() ?? 'N/A',
            ),
            _buildInfoTile('Specialization', company.specialization),
            const SizedBox(height: 20),
            if (company.companyGallery?.isNotEmpty ?? false) ...[
              const Text(
                'Company Gallery',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount:
                    company.companyGallery!.length > 4
                        ? 4
                        : company.companyGallery!.length,
                itemBuilder: (context, index) {
                  if (index == 3 && company.companyGallery!.length > 4) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '+${company.companyGallery!.length - 4}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      company.companyGallery![index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value, {bool isLink = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isLink ? Colors.orange : Colors.grey[700],
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection(Company company) {
    return Consumer<NetworkProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isCompanyPostsLoading(company.id);
        final posts = provider.getPostsForCompany(company.id);

        if (isLoading && posts.isEmpty) {
          return Container(
            color: Colors.grey[100],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (posts.isEmpty) {
          return Container(
            color: Colors.grey[100],
            child: const Center(
              child: Text('No recent activity from this company.'),
            ),
          );
        }

        return Container(
          color: Colors.grey[100],
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return CompanyPostCard(post: post);
            },
          ),
        );
      },
    );
  }

  Widget _buildJobsSection(Company company) {
    return Builder(
      builder: (context) {
        final companyJobs = company.companyJobs;
        if (companyJobs == null || companyJobs.isEmpty) {
          return Container(
            color: Colors.grey[100],
            child: const Center(child: Text('No open jobs at this company.')),
          );
        }
        return Container(
          color: Colors.grey[100],
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companyJobs.length,
            itemBuilder: (context, index) {
              final job = companyJobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(job: job ,),
              );
            },
          ),
        );
      },
    );
  }
}

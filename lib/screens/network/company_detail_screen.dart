import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/widgets/company_post_card.dart';
import 'package:provider/provider.dart';

import '../../widgets/common_job_card.dart' as common_job_card;

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailScreen({Key? key, required this.companyId})
      : super(key: key);

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(context, listen: false)
          .fetchPostsByCompany(widget.companyId, isRefresh: true);
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Company Profile',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                ),
              ],
              pinned: true,
              expandedHeight: 300.0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildCompanyHeader(context, company),
              ),
              bottom: TabBar(
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.orange,
                tabs: const [
                  Tab(text: 'About us'),
                  Tab(text: 'Post'),
                  Tab(text: 'Jobs'),
                ],
              ),
            ),
            SliverFillRemaining(
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

  Widget _buildCompanyHeader(BuildContext context, Company company) {
    final provider = Provider.of<NetworkProvider>(context);
    final isFollowing = provider.following.contains(company.id);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (company.companyLogo != null && company.companyLogo!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                company.companyLogo!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                // Gracefully handle image loading errors
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.business, size: 30),
                  );
                },
              ),
            )
          else
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.business, size: 30),
            ),
          const SizedBox(height: 12),
          Text(
            company.companyName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${company.location ?? 'N/A'} • ${company.followersCount ?? 0} Followers',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.toggleFollow(company.id),
                  icon: Icon(isFollowing ? Icons.check : Icons.add),
                  label: Text(isFollowing ? 'Following' : 'Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowing ? Colors.pink : Colors.transparent,
                    foregroundColor: isFollowing ? Colors.white : Colors.pink,
                    side: BorderSide(
                      color:
                          isFollowing ? Colors.transparent : Colors.grey[300]!,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text('Visit website'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Company company) {
    return SingleChildScrollView(
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
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildInfoTile('Website', company.website),
          _buildInfoTile('Industry', company.industry),
          _buildInfoTile('Email', company.email),
          _buildInfoTile('Phone', company.phone),
          _buildInfoTile('LinkedIn', company.linkedin),
          _buildInfoTile('Instagram', company.instagram),
          _buildInfoTile('Employee size', company.companySize),
          _buildInfoTile('Head office', company.headOffice),
          _buildInfoTile('Type', company.companyType),
          _buildInfoTile('Since', company.establishedSince.toString() ?? 'N/A'),
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
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (posts.isEmpty) {
          return const Center(
            child: Text('No recent activity from this company.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return CompanyPostCard(post: post);
          },
          // TODO: Add scroll listener for pagination (loadMoreCompanyPosts)
        );
      },
    );
  }

  Widget _buildJobsSection(Company company) {
    return Builder(
      builder: (context) {
        final companyJobs = company.companyJobs;
        if (companyJobs == null || companyJobs.isEmpty) {
          return const Center(child: Text('No open jobs at this company.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: companyJobs.length,
          itemBuilder: (context, index) {
            final job = companyJobs[index];
            return common_job_card.JobCard(job: job);
          },
        );
      },
    );
  }
}

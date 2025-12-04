import 'package:flutter/material.dart';
import 'package:jobportal/animationsLoading/animated_linking_dots.dart';

import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/widgets/company_follow_card.dart';
import 'package:jobportal/widgets/company_post_card.dart';
import 'package:provider/provider.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final _companyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    _companyScrollController.addListener(() {
      if (_companyScrollController.position.pixels ==
          _companyScrollController.position.maxScrollExtent) {
        jobProvider.loadMoreCompanies();
      }
    });
  }

  @override
  void dispose() {
    _companyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: const Text(
                  'Network',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                pinned: true,
                floating: true,
                bottom: TabBar(
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.orange,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [Tab(text: 'Posts'), Tab(text: 'Companies')],
                ),
              ),
            ];
          },
          body: Consumer2<NetworkProvider, JobProvider>(
            builder: (context, networkProvider, jobProvider, child) {
              // Show loading state for both tabs
              if ((networkProvider.isLoading &&
                      networkProvider.posts.isEmpty) ||
                  (jobProvider.isCompanyLoading &&
                      jobProvider.companies.isEmpty)) {
                return Center(
                  child: DotLinkLoader(
                    dotCount: 25,
                    dotSize: 4,
                    color: Colors.grey,
                    addSpeed: Duration(milliseconds: 150),
                  ),
                );
              }

              // Show error state
              if ((networkProvider.errorMessage != null &&
                      networkProvider.posts.isEmpty) ||
                  (jobProvider.errorMessage != null &&
                      jobProvider.companies.isEmpty)) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          networkProvider.fetchPosts(isRefresh: true);
                          jobProvider.loadCompaniesFirstPage();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                children: [
               

                  // Posts Tab
                  _buildPostsTab(networkProvider),
                  // Companies Tab
                  _buildCompaniesTab(context, networkProvider, jobProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(NetworkProvider networkProvider) {
    if (networkProvider.posts.isEmpty) {
      return const Center(child: Text("No posts in the network yet."));
    }

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = networkProvider.posts[index];
            return CompanyPostCard(post: post);
          }, childCount: networkProvider.posts.length),
        ),
        if (networkProvider.canLoadMorePosts)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: OutlinedButton(
                onPressed: () => networkProvider.loadMorePosts(),
                child: const Text('Load More'),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildCompaniesTab(
    BuildContext context,
    NetworkProvider networkProvider,
    JobProvider jobProvider,
  ) {
    return CustomScrollView(
      controller: _companyScrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: 12,
            ),
            child: Text(
              'Companies to Follow',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final company = jobProvider.companies[index];
              return buildCompanyFollowCard(context, networkProvider, company);
            }, childCount: jobProvider.companies.length),
          ),
        ),
        if (jobProvider.isCompanyLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: DotLinkLoader(
                  dotCount: 25,
                  dotSize: 4,
                  color: Colors.grey,
                  addSpeed: Duration(milliseconds: 150),
                ),
              ),
            ),
          ),
        if (!jobProvider.isCompanyLoadingMore)
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

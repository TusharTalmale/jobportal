import 'package:flutter/material.dart';

import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/widgets/company_follow_card.dart';
import 'package:jobportal/widgets/company_post_card.dart';
import 'package:provider/provider.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Consumer<NetworkProvider>(
        builder: (context, networkProvider, child) {
          if (networkProvider.isLoading && networkProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Watch JobProvider here to get company data
          final companiesToFollow = context.watch<JobProvider>().allCompanies;

          return CustomScrollView(
            slivers: [
              // --- Feed Section ---
              if (networkProvider.posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text("No posts in the network yet.")),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = networkProvider.posts[index];
                    return CompanyPostCard(post: post);
                  }, childCount: networkProvider.posts.length),
                ),

              // --- Load More Button ---
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

              // --- "Companies to Follow" Title ---
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

              // --- Companies Grid ---
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
                    final company = companiesToFollow[index];
                    return buildCompanyFollowCard(
                      context,
                      networkProvider,
                      company,
                    );
                  }, childCount: companiesToFollow.length),
                ),
              ),
              // Add some padding at the bottom
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

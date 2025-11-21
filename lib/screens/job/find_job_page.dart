import 'package:flutter/material.dart'; // This file is not directly modified, but the EmptyStateWidget is provided as a separate entity.
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/screens/job/filter_page.dart'; // Ensure this import is correct
import 'package:jobportal/widgets/common_job_card.dart';
import 'package:provider/provider.dart';

import '../../widgets/empty_widget.dart';

class JobListingScreen extends StatelessWidget {
  const JobListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: Consumer<JobProvider>(
          builder: (context, jobProvider, child) {
            // Show loading state
            if (jobProvider.isLoading && jobProvider.filteredJobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error state
            if (jobProvider.errorMessage != null &&
                jobProvider.filteredJobs.isEmpty) {
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
                      'Error: ${jobProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => jobProvider.fetchJobs(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _header(context, jobProvider),
                const SizedBox(height: 15),
                _filterRow(context, jobProvider),
                const SizedBox(height: 15),
                Expanded(
                  child:
                      jobProvider.filteredJobs.isEmpty
                          ? const EmptyStateWidget()
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: jobProvider.filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = jobProvider.filteredJobs[index];
                              return JobCard(job: job);
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- HEADER WIDGET ----------------
  Widget _header(BuildContext context, JobProvider jobProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2e236c), Color(0xff3e2ea0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // back button
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(height: 10),

          // Search field
          _searchField(
            hint: "Design",
            icon: Icons.search,
            controller: jobProvider.designationController,
          ),

          const SizedBox(height: 15),

          // Location field
          _searchField(
            hint: "California, USA",
            icon: Icons.location_on_outlined,
            controller: jobProvider.locationController,
          ),
        ],
      ),
    );
  }

  // ---------- SEARCH FIELD WIDGET ----------
  Widget _searchField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------- FILTER ROW ----------
  Widget _filterRow(BuildContext context, JobProvider jobProvider) {
    List<Widget> filterChips = [];

    // Add Job Type chips
    jobProvider.availableJobTypes.forEach((jobTypeOption) {
      filterChips.add(
        _chip(
          jobTypeOption,
          selected:
              jobProvider.activeFilters['jobType']?.contains(jobTypeOption) ??
              false,
          onTap: () => jobProvider.toggleJobType(jobTypeOption),
        ),
      );
    });

    // Add Position Level chips
    jobProvider.availablePositions.forEach((positionOption) {
      filterChips.add(
        _chip(
          positionOption,
          selected:
              jobProvider.activeFilters['position']?.contains(positionOption) ??
              false,
          onTap: () => jobProvider.setPositionLevel(positionOption),
        ),
      );
    });

    // Check if any of the new explicit filters are active
    final anyExplicitFilterActive =
        jobProvider.lastUpdate != "Any time" ||
        jobProvider.workplace != "On-site" ||
        jobProvider.jobTypes.isNotEmpty || // Check if any job type is selected
        jobProvider.positions.isNotEmpty || // Check if any position is selected
        jobProvider.cities.isNotEmpty ||
        jobProvider.experience != "No experience" ||
        jobProvider.specialization.isNotEmpty ||
        jobProvider.salaryRange.start != 5 ||
        jobProvider.salaryRange.end != 40;

    // Check if any filter is active
    final anyFilterActive =
        anyExplicitFilterActive ||
        jobProvider.activeFilters.values.any((s) => s.isNotEmpty);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(
            "All Filters",
            selected:
                anyFilterActive, // Use the combined check for all active filters
            icon: Icons.tune,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterPage()),
              );
            },
          ), // Placeholder for a filter dialog
          ...filterChips,
        ],
      ),
    );
  }

  // ---------- CHIP ----------
  Widget _chip(
    String text, {
    bool selected = false,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff2e236c) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

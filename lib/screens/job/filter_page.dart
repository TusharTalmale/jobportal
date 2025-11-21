import 'package:flutter/material.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  @override
  void initState() {
    super.initState();
    // Initialize temporary filters when the page is first built
    Provider.of<JobProvider>(context, listen: false).initFilterEditing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Resetting clears both active and temp filters
              Provider.of<JobProvider>(context, listen: false).clearFilters();
            },
            child: const Text('RESET',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Job Type'),
                _buildMultiSelectChipGroup(
                  options: provider.availableJobTypes, // from available options
                  selected: provider.tempJobTypes.toSet(), // use temp state
                  onToggle: provider.toggleJobType,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Specialization'),
                _buildMultiSelectChipGroup(
                  options: provider.availableSpecializations,
                  selected: provider.tempSpecialization.toSet(), // use temp state
                  onToggle: provider.toggleSpecialization,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Salary Range'),
                _buildSalarySlider(context, provider),
                const SizedBox(height: 24),
                _buildSectionTitle('Position Level'),
                _buildSingleSelectChipGroup(
                  options: provider.availablePositions,
                  selected: provider.tempPositions.isNotEmpty
                      ? provider.tempPositions.first
                      : null, // use temp state
                  onSelected: provider.setPositionLevel,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Experience'),
                _buildSingleSelectChipGroup(
                  options: provider.availableExperiences,
                  selected: provider.tempExperience, // use temp state
                  onSelected: provider.setExperience,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Workplace'),
                _buildSingleSelectChipGroup(
                  options: provider.availableWorkplaces,
                  selected: provider.tempWorkplace, // use temp state
                  onSelected: provider.setWorkplace,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Last Update'),
                _buildSingleSelectChipGroup(
                  options: provider.availableLastUpdates,
                  selected: provider.tempLastUpdate, // use temp state
                  onSelected: provider.setLastUpdate,
                ),
                const SizedBox(height: 100), // Space for the button
              ],
            ),
          );
        },
      ),
      bottomSheet: _buildApplyButton(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMultiSelectChipGroup({
    required List<String> options,
    required Set<String> selected,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          options.map((option) {
            final isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onToggle(option),
              selectedColor: const Color(0xff2e236c),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xff2e236c) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSingleSelectChipGroup({
    required List<String> options,
    required String? selected,
    required void Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: const Color(0xff2e236c),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xff2e236c) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSalarySlider(BuildContext context, JobProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // Use temp value, with a fallback to the active one
              '\$${(provider.tempSalaryRange?.start ?? provider.salaryRange.start).toInt()}k',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${(provider.tempSalaryRange?.end ?? provider.salaryRange.end).toInt()}k',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        RangeSlider(
          values: provider.tempSalaryRange ?? provider.salaryRange,
          min: 5,
          max: 40,
          divisions: 35,
          activeColor: const Color(0xff2e236c),
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            '\$${(provider.tempSalaryRange?.start ?? provider.salaryRange.start).round()}k',
            '\$${(provider.tempSalaryRange?.end ?? provider.salaryRange.end).round()}k',
          ),
          onChanged: (values) {
            provider.setSalaryRange(values);
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Commit the temporary filters and apply them
            Provider.of<JobProvider>(context, listen: false).applyFilters();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF130160),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
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
    );
  }
}

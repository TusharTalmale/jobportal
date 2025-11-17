import 'package:flutter/material.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

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
              Provider.of<JobProvider>(context, listen: false).clearFilters();
            },
            child: const Text('RESET', style: TextStyle(color: Colors.white)),
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
                  options: provider.availableJobTypes,
                  selected: provider.jobTypes.toSet(),
                  onToggle: provider.toggleJobType,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Specialization'),
                _buildMultiSelectChipGroup(
                  options: provider.availableSpecializations,
                  selected: provider.specialization.toSet(),
                  onToggle: provider.toggleSpecialization,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Salary Range'),
                _buildSalarySlider(context, provider),
                const SizedBox(height: 24),
                _buildSectionTitle('Position Level'),
                _buildSingleSelectChipGroup(
                  options: provider.availablePositions,
                  selected:
                      provider.positions.isNotEmpty
                          ? provider.positions.first
                          : null,
                  onSelected: provider.setPositionLevel,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Experience'),
                _buildSingleSelectChipGroup(
                  options: provider.availableExperiences,
                  selected: provider.experience,
                  onSelected: provider.setExperience,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Workplace'),
                _buildSingleSelectChipGroup(
                  options: provider.availableWorkplaces,
                  selected: provider.workplace,
                  onSelected: provider.setWorkplace,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Last Update'),
                _buildSingleSelectChipGroup(
                  options: provider.availableLastUpdates,
                  selected: provider.lastUpdate,
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
              '\$${provider.salaryRange.start.toInt()}k',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${provider.salaryRange.end.toInt()}k',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        RangeSlider(
          values: provider.salaryRange,
          min: 5,
          max: 40,
          divisions: 35,
          activeColor: const Color(0xff2e236c),
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            '\$${provider.salaryRange.start.round()}k',
            '\$${provider.salaryRange.end.round()}k',
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
            // The provider state is already updated, so we just need to pop
            // The `_applyFilters` method in the provider is called on every change.
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

extension on JobProvider {
  void updateSalaryRange(RangeValues newRange) {
    // This is a placeholder for a potential future method in the provider
    // if you decide to only update the state on "Apply".
    // For now, `setSalaryRange` directly applies the filter.
  }
}

class FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final Set<String> selectedOptions;
  final Function(String) onOptionSelected;

  const FilterSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children:
              options.map((option) {
                final isSelected = selectedOptions.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    onOptionSelected(option);
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

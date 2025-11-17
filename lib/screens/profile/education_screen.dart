import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class EducationScreenWrapper extends StatefulWidget {
  final int? index;
  const EducationScreenWrapper({super.key, this.index});

  @override
  State<EducationScreenWrapper> createState() => _EducationScreenWrapperState();
}

class _EducationScreenWrapperState extends State<EducationScreenWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().initializeEducationForm(widget.index);
  }

  @override
  void dispose() {
    context.read<ProfileProvider>().disposeEducationForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    return Scaffold(
      appBar: AppBar(
        title: Text(index == null ? 'Add Education' : 'Change Education'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final education = provider.editingEducation;
          if (education == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Form(
              key: provider.educationFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSearchableField(
                      context,
                      'Level of education',
                      education.levelOfEducation,
                      _educationLevels,
                      (value) {
                        provider.updateEditingEducation(
                          levelOfEducation: value,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSearchableField(
                      context,
                      'Institution name',
                      education.institutionName,
                      _institutionNames,
                      (value) {
                        provider.updateEditingEducation(institutionName: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSearchableField(
                      context,
                      'Field of study',
                      education.fieldOfStudy,
                      _fieldsOfStudy,
                      (value) {
                        provider.updateEditingEducation(fieldOfStudy: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      context,
                      'Start date',
                      education.startDate,
                      (date) =>
                          provider.updateEditingEducation(startDate: date),
                    ),
                    const SizedBox(height: 16),
                    if (!education.isCurrentPosition)
                      Column(
                        children: [
                          _buildDateField(
                            context,
                            'End date',
                            education.endDate ?? DateTime.now(),
                            (date) =>
                                provider.updateEditingEducation(endDate: date),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Row(
                      children: [
                        Checkbox(
                          value: education.isCurrentPosition,
                          onChanged: (val) {
                            if (val != null) {
                              provider.updateEditingEducation(
                                isCurrentPosition: val,
                              );
                            }
                          },
                          activeColor: AppColors.accentColor,
                        ),
                        const Text('This is my position now'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: education.description,
                      onChanged:
                          (value) => provider.updateEditingEducation(
                            description: value,
                          ),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Write additional information here',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'SAVE',
                      onPressed: () => _saveEducation(context),
                    ),
                    if (index != null) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'REMOVE',
                        onPressed: () => _removeEducation(context, index),
                        isSecondary: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchableField(
    BuildContext context,
    String label,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap:
              () => _showSearchableList(
                context,
                label,
                currentValue,
                options,
                onChanged,
              ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentValue.isEmpty ? label : currentValue,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          currentValue.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchableList(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Use a local controller for the search field inside the modal
        final searchController = TextEditingController();
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (stfContext, stfSetState) {
                final filteredList =
                    options
                        .where(
                          (item) => item.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search $title',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => stfSetState(() {}),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredList.length,
                          itemBuilder: (listContext, index) {
                            return ListTile(
                              title: Text(filteredList[index]),
                              onTap: () {
                                onChanged(filteredList[index]);
                                Navigator.pop(modalContext);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1990),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, color: AppColors.accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveEducation(BuildContext context) {
    context.read<ProfileProvider>().saveEducation();
    Navigator.pop(context);
  }

  void _removeEducation(BuildContext context, int index) {
    context.read<ProfileProvider>().removeEducation(index);
    Navigator.pop(context);
  }

  // Data moved here to keep the widget clean
  final List<String> _educationLevels = const [
    'Bachelor of Electronic Engineering (Industrial Electronics)',
    'Bachelor of Information Technology',
    'Economics (Bachelor of Science), Psychology',
    'Bachelor of Arts (Hons) Mass Communication With Public Relations',
    'Bachelor of Science in Computer Science',
    'Bachelors of Science in Marketing',
    'Bachelor of Engineering With A Major in Engineering Product Development (Robotic Track)',
    'Bachelor of Business (Economics/Finance)',
    'Bachelors of Science in Marketing',
    'Bachelors of Business Administration',
  ];

  final List<String> _institutionNames = const [
    'University of Oxford',
    'National University of Lesotho International School',
    'University of Chester CF Academy',
    'University of Chester Academy Northwich',
    'University of Birmingham School',
    'Bloomsburg University of Pennsylvania',
    'California University of Pennsylvania',
    'Clarion University of Pennsylvania',
    'East Stroudsburg State University of Pennsylvania',
  ];

  final List<String> _fieldsOfStudy = const [
    'Information Technology',
    'Business Information Systems',
    'Computer Information Science',
    'Computer Information Systems',
    'Health Information Management',
    'History and Information',
    'Information Assurance',
    'Information Security',
    'Information Systems',
    'Information Systems Major',
  ];
}

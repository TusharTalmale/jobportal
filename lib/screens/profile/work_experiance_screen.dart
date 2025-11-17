import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class WorkExperienceScreenWrapper extends StatefulWidget {
  final int? index;
  const WorkExperienceScreenWrapper({super.key, this.index});

  @override
  State<WorkExperienceScreenWrapper> createState() =>
      _WorkExperienceScreenWrapperState();
}

class _WorkExperienceScreenWrapperState
    extends State<WorkExperienceScreenWrapper> {
  late final ProfileProvider _profileProvider;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    final workExperience = _profileProvider.getWorkExperienceForEdit(
      widget.index,
    );

    _jobTitleController = TextEditingController(
      text: workExperience?.jobTitle ?? '',
    );
    _companyController = TextEditingController(
      text: workExperience?.company ?? '',
    );
    _descriptionController = TextEditingController(
      text: workExperience?.description ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.initializeWorkExperienceForm(widget.index);
      // Sync controllers after initialization
      final currentWorkExperience = _profileProvider.editingWorkExperience;
      _jobTitleController.text = currentWorkExperience?.jobTitle ?? '';
      _companyController.text = currentWorkExperience?.company ?? '';
      _descriptionController.text = currentWorkExperience?.description ?? '';
    });
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _profileProvider.disposeWorkExperienceForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          index == null ? 'Add work experience' : 'Change work experience',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final workExperience = provider.editingWorkExperience;
          if (workExperience == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Form(
              key: provider.workExperienceFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Job title',
                        hintText: 'e.g. Manager',
                      ),
                      onChanged:
                          (value) => provider.updateEditingWorkExperience(
                            jobTitle: value,
                          ),
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Job title cannot be empty.'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company',
                        hintText: 'e.g. Amazon Inc',
                      ),
                      onChanged:
                          (value) => provider.updateEditingWorkExperience(
                            company: value,
                          ),
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Company name cannot be empty.'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      'Start date',
                      workExperience.startDate,
                      (date) =>
                          provider.updateEditingWorkExperience(startDate: date),
                    ),
                    const SizedBox(height: 16),
                    if (!workExperience.isCurrentPosition)
                      Column(
                        children: [
                          _buildDateField(
                            'End date',
                            workExperience.endDate ?? DateTime.now(),
                            (date) => provider.updateEditingWorkExperience(
                              endDate: date,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Row(
                      children: [
                        Checkbox(
                          value: workExperience.isCurrentPosition,
                          onChanged: (val) {
                            if (val != null) {
                              provider.updateEditingWorkExperience(
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
                      controller: _descriptionController,
                      onChanged:
                          (value) => provider.updateEditingWorkExperience(
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
                      onPressed: () => _saveWorkExperience(context),
                    ),
                    if (index != null) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'REMOVE',
                        onPressed: () => _removeWorkExperience(context, index),
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

  Widget _buildDateField(
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

  void _saveWorkExperience(BuildContext context) {
    context.read<ProfileProvider>().saveWorkExperience();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work experience saved!'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  void _removeWorkExperience(BuildContext context, int index) {
    context.read<ProfileProvider>().removeWorkExperience(index);
    Navigator.pop(context);
  }
}

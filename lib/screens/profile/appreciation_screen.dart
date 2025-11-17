import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class AppreciationScreen extends StatefulWidget {
  final int? index;
  const AppreciationScreen({super.key, this.index});

  @override
  State<AppreciationScreen> createState() => _AppreciationScreenState();
}

class _AppreciationScreenState extends State<AppreciationScreen> {
  late final ProfileProvider _profileProvider;
  late final TextEditingController _titleController;
  late final TextEditingController _organizationController;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    final appreciation = _profileProvider.getAppreciationForEdit(widget.index);

    _titleController = TextEditingController(text: appreciation?.title ?? '');
    _organizationController = TextEditingController(
      text: appreciation?.organization ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.initializeAppreciationForm(widget.index);
      // Sync controllers after initialization
      final currentAppreciation = _profileProvider.editingAppreciation;
      _titleController.text = currentAppreciation?.title ?? '';
      _organizationController.text = currentAppreciation?.organization ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _profileProvider.disposeAppreciationForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.index == null ? 'Add Appreciation' : 'Edit Appreciation',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final appreciation = provider.editingAppreciation;
          if (appreciation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Form(
              key: provider.appreciationFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g., Best Performer',
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Title cannot be empty' : null,
                      onChanged:
                          (value) =>
                              provider.updateEditingAppreciation(title: value),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Organization',
                        hintText: 'e.g., Google',
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Organization cannot be empty'
                                  : null,
                      onChanged:
                          (value) => provider.updateEditingAppreciation(
                            organization: value,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildDateField(
                      context,
                      'Date',
                      appreciation.date,
                      (date) => provider.updateEditingAppreciation(date: date),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'SAVE',
                      onPressed: () => _saveAppreciation(context),
                    ),
                    if (widget.index != null) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'REMOVE',
                        onPressed:
                            () => _removeAppreciation(context, widget.index!),
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

  void _saveAppreciation(BuildContext context) {
    context.read<ProfileProvider>().saveAppreciation();
    Navigator.pop(context);
  }

  void _removeAppreciation(BuildContext context, int index) {
    context.read<ProfileProvider>().removeAppreciation(index);
    Navigator.pop(context);
  }
}

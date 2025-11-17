import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  late final ProfileProvider _profileProvider;
  late final TextEditingController _aboutMeController;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    _aboutMeController = TextEditingController(
      text: _profileProvider.editingAboutMe,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.initializeAboutMeForm();
      // Sync controller with provider state after initialization
      _aboutMeController.text = _profileProvider.editingAboutMe;
    });
  }

  @override
  void dispose() {
    _profileProvider.disposeAboutMeForm();
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About me'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _aboutMeController,
              onChanged:
                  (value) => _profileProvider.updateEditingAboutMe(value),
              decoration: const InputDecoration(
                labelText: 'Tell me about you',
                hintText: 'Write a brief description about yourself...',
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'SAVE', onPressed: () => _saveAboutMe(context)),
          ],
        ),
      ),
    );
  }

  void _saveAboutMe(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    provider.saveAboutMe();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('About saved successfully!'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
}

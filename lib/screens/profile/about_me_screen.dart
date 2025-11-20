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
  late final ProfileProvider _provider;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ProfileProvider>();
    _provider.initializeAboutMeForm();
    _controller = TextEditingController(text: _provider.editingAboutMe);
  }

  @override
  void dispose() {
    _provider.disposeAboutMeForm();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About me'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Tell me about you'),
              onChanged: _provider.updateEditingAboutMe,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'SAVE',
              onPressed: () {
                _provider.saveAboutMe();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

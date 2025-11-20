import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().initializeBasicInfoForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final basicInfo = provider.editingBasicInfo;

          if (basicInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Edit Form
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: basicInfo.fullName,
                        decoration: const InputDecoration(
                          labelText: 'Fullname',
                          hintText: 'Enter your full name',
                        ),
                        onChanged:
                            (value) => provider.updateEditingBasicInfo(
                              fullName: value,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: basicInfo.email,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          hintText: 'Enter your email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (value) =>
                                provider.updateEditingBasicInfo(email: value),
                      ),
                      const SizedBox(height: 16),
                      _buildPhoneField(provider, basicInfo.phoneNumber ?? ''),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: basicInfo.location,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Enter your location',
                        ),
                        onChanged:
                            (value) => provider.updateEditingBasicInfo(
                              location: value,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildGenderSelector(context, provider, basicInfo.gender ?? ''),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'SAVE',
                        onPressed: () => _saveBasicInfo(context),
                        isLoading: provider.isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneField(ProfileProvider provider, String phoneNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                value: '+1',
                underline: const SizedBox(),
                items:
                    ['+1', '+44', '+91', '+81']
                        .map(
                          (code) =>
                              DropdownMenuItem(value: code, child: Text(code)),
                        )
                        .toList(),
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: phoneNumber)
                  ..selection = TextSelection.collapsed(
                    offset: phoneNumber.length,
                  ),
                keyboardType: TextInputType.phone,
                onChanged:
                    (value) =>
                        provider.updateEditingBasicInfo(phoneNumber: value),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelector(
    BuildContext context,
    ProfileProvider provider,
    String currentGender,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => provider.updateEditingBasicInfo(gender: 'male'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          currentGender == 'male'
                              ? AppColors.accentColor
                              : AppColors.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              currentGender == 'male'
                                  ? AppColors.accentColor
                                  : Colors.white,
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child:
                            currentGender == 'male'
                                ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Male'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => provider.updateEditingBasicInfo(gender: 'female'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          currentGender == 'female'
                              ? AppColors.accentColor
                              : AppColors.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              currentGender == 'female'
                                  ? AppColors.accentColor
                                  : Colors.white,
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child:
                            currentGender == 'female'
                                ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('Female'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveBasicInfo(BuildContext context) {
    Provider.of<ProfileProvider>(context, listen: false).saveBasicInfo();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully!'),
        backgroundColor: AppColors.successColor,
      ),
    );
    Navigator.pop(context);
  }
}

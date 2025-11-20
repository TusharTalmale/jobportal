import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

// ============= RESUME SCREEN =============
class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Resume'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Use null-aware operator and provide a default empty list
                if (provider.profile?.resumes?.isEmpty ?? true)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickResume,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.borderColor,
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_present_outlined,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload CV/Resume',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Upload files in PDF format up to 5 MB. just upload it once and you\ncan use it in your next application.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.profile?.resumes?.length ?? 0,
                    itemBuilder: (context, index) {
                      final resume = provider.profile!.resumes![index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.file_present,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resume.fileName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${resume.size} · ${resume.uploadDate.toLocal()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeResume(resume.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                if (provider.profile?.resumes?.isEmpty ?? true)
                  CustomButton(
                    label: 'SAVE',
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  CustomButton(
                    label: 'ADD ANOTHER RESUME',
                    onPressed: _pickResume,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickResume() async {
    final provider = context.read<ProfileProvider>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);

      // Size check
      final sizeMB = (await file.length()) / (1024 * 1024);
      if (sizeMB > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size cannot exceed 5 MB')),
        );
        return;
      }

      // Set file for provider (IMPORTANT!)
      provider.setNewResumeFile(file);

      // Local representation
      final resume = Resume(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: result.files.single.name,
        size: '${sizeMB.toStringAsFixed(2)} MB',
        uploadDate: DateTime.now(),
      );

      // Add into list
      provider.addResume(resume);
    } catch (e) {
      // Handle any errors from file picking
      print("Error picking resume: $e");
    }
  }

  void _removeResume(String resumeId) {
    Provider.of<ProfileProvider>(context, listen: false).removeResume(resumeId);
  }
}

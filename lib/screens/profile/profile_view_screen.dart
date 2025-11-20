import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/screens/profile/profile_header.dart';
import 'package:jobportal/screens/profile/profile_section_card.dart';
import 'package:jobportal/widgets/profile_list_section.dart';
import 'package:jobportal/utils/appconstants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen>
    with TickerProviderStateMixin {
  bool _isAboutMeExpanded = false;
  final int _maxLines = 4;

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    Resume resume,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete the resume: ${resume.fileName}?',
                ),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ProfileProvider>(
                  context,
                  listen: false,
                ).removeResume(resume.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${resume.fileName} deleted.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumeItem(BuildContext context, Resume res) {
    final uploadDate = DateFormat(
      'd MMM yyyy \'at\' hh:mm a',
    ).format(res.uploadDate);

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              color: AppColors.primaryColor,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.fileName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${res.size} · $uploadDate',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.accentColor,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Edit ${res.fileName}')));
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _showDeleteConfirmationDialog(context, res),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.userProfile == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          final UserProfile profile = provider.userProfile!;
          final List<Resume> resumes = profile.resumes ?? [];

          return CustomScrollView(
            slivers: <Widget>[
              // New Profile Header
              ProfileHeader(profile: profile),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ProfileSectionCard(
                      title: 'About Me',
                      iconData: Icons.person_outline,
                      isEmpty: profile.aboutMe == null || profile.aboutMe!.isEmpty,
                      editModeOnContent: true,
                      onAdd:
                          () => Navigator.pushNamed(context, AppRoutes.aboutMe),
                      onEdit:
                          () => Navigator.pushNamed(context, AppRoutes.aboutMe),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: profile.aboutMe,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: _maxLines,
                            textDirection: Directionality.of(context),
                          );
                          textPainter.layout(maxWidth: constraints.maxWidth);

                          final bool isTextOverflowing =
                              textPainter.didExceedMaxLines;

                          return AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.aboutMe ?? '',
                                  maxLines:
                                      _isAboutMeExpanded ? null : _maxLines,
                                  overflow:
                                      _isAboutMeExpanded
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (isTextOverflowing) _buildReadMoreButton(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Work Experience Section
                    ProfileListSection<WorkExperience>(
                      title: 'Work Experience',
                      iconData: Icons.work_outline,
                      items: profile.workExperiences ?? [],
                      emptyMessage: 'No work experience added yet.',
                      onAdd:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.workExperience,
                          ),
                      onEdit:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.workExperience,
                          ),
                      itemBuilder:
                          (context, exp, index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.workExperience,
                                        arguments: {'index': index},
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.jobTitle,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        exp.company,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${exp.startDate.year} - ${exp.isCurrentPosition ? 'Present' : exp.endDate?.year}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.accentColor,
                                  size: 20,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.workExperience,
                                      arguments: {'index': index},
                                    ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Education Section
                    ProfileListSection<Education>(
                      title: 'Education',
                      iconData: Icons.school_outlined,
                      items: profile.educations ?? [],
                      emptyMessage: 'No education added yet.',
                      onAdd:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.education),
                      onEdit:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.education),
                      itemBuilder:
                          (context, edu, index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.education,
                                        arguments: {'index': index},
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        edu.levelOfEducation,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        edu.institutionName,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${edu.startDate.year} - ${edu.isCurrentPosition ? 'Present' : edu.endDate?.year}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.accentColor,
                                  size: 20,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.education,
                                      arguments: {'index': index},
                                    ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Skills Section
                    ProfileSectionCard(
                      title: 'Skills',
                      iconData: Icons.star_outline,
                      isEmpty: profile.skills?.isEmpty ?? true,
                      editModeOnContent: true,
                      onAdd:
                          () => Navigator.pushNamed(context, AppRoutes.skills),
                      onEdit:
                          () => Navigator.pushNamed(context, AppRoutes.skills),
                      child:
                          (profile.skills?.isEmpty ?? true)
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('No skills added yet.'),
                                ),
                              )
                              : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    (profile.skills ?? [])
                                        .map(
                                          (skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundColor,
                                              border: Border.all(
                                                color: AppColors.borderColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              skill,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Languages Section
                    ProfileListSection<Language>(
                      title: 'Languages',
                      iconData: Icons.language_outlined,
                      items: profile.languages ?? [],
                      emptyMessage: 'No languages added yet.',
                      onAdd:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.languages),
                      onEdit:
                          () =>
                              Navigator.pushNamed(context, AppRoutes.languages),
                      itemBuilder:
                          (context, lang, index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.languages,
                                        arguments: {'index': index},
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Oral: Level ${lang.oralLevel}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Written: Level ${lang.writtenLevel}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.accentColor,
                                  size: 20,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.languages,
                                      arguments: {'index': index},
                                    ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Resumes Section
                    ProfileSectionCard(
                      title: 'Resumes',
                      iconData: Icons.file_copy_outlined,
                      isEmpty: resumes.isEmpty,
                      onAdd:
                          () => Navigator.pushNamed(context, AppRoutes.resume),
                      onEdit:
                          () => Navigator.pushNamed(context, AppRoutes.resume),
                      child:
                          resumes.isEmpty
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text('No resumes uploaded yet.'),
                                ),
                              )
                              : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: resumes.length,
                                separatorBuilder:
                                    (context, index) => const Divider(
                                      height: 16,
                                      color: Colors.transparent,
                                    ),
                                itemBuilder: (context, index) {
                                  final res = resumes[index];
                                  return _buildResumeItem(context, res);
                                },
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Appreciations Section
                    ProfileListSection<Appreciation>(
                      title: 'Appreciations',
                      iconData: Icons.favorite_border,
                      items: profile.appreciations ?? [],
                      emptyMessage: 'No appreciations added yet.',
                      onAdd:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.appreciation,
                          ),
                      onEdit:
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.appreciation,
                          ),
                      itemBuilder:
                          (context, app, index) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.appreciation,
                                        arguments: {'index': index},
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        app.organization,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        app.date.year.toString(),
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.accentColor,
                                  size: 20,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.appreciation,
                                      arguments: {'index': index},
                                    ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadMoreButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAboutMeExpanded = !_isAboutMeExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          _isAboutMeExpanded ? 'Read less' : 'Read more',
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

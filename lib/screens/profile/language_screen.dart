import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class LanguageScreenWrapper extends StatefulWidget {
  final int? index;

  const LanguageScreenWrapper({super.key, this.index});

  @override
  State<LanguageScreenWrapper> createState() => _LanguageScreenWrapperState();
}

class _LanguageScreenWrapperState extends State<LanguageScreenWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initializeLanguageForm(widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          index == null ? 'Add Language' : 'Edit Language',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final language = provider.editingLanguage;
          if (language == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLanguageSelector(context, provider),
                const SizedBox(height: 24),

                // First language toggle
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        "First language",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: language.isFirstLanguage,
                          activeColor: const Color(0xFFFF9F43),
                          side: const BorderSide(
                            color: Color(0xFF9E9E9E),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              provider.updateEditingLanguage(
                                isFirstLanguage: val,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Oral level section
                _buildLevelSection(
                  title: 'Oral',
                  level: language.oralLevel,
                  placeholder: 'level ${language.oralLevel}',
                  onChanged:
                      (val) => provider.updateEditingLanguage(
                        oralLevel: val.toInt(),
                      ),
                ),
                const SizedBox(height: 24),

                // Written level section
                _buildLevelSection(
                  title: 'Written',
                  level: language.writtenLevel,
                  placeholder: 'Choose your speaking skill level',
                  onChanged:
                      (val) => provider.updateEditingLanguage(
                        writtenLevel: val.toInt(),
                      ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    'Proficiency level : 0 - Poor, 10 - Very good',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                CustomButton(
                  label: 'SAVE',
                  onPressed: () => _saveLanguage(context),
                ),

                // Remove button for edit mode
                if (index != null) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'REMOVE',
                    onPressed:
                        () => _showRemoveDialog(context, index, language.name),
                    isSecondary: true,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    ProfileProvider provider,
  ) {
    final selected = provider.editingLanguage?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (selected.isNotEmpty)
              Row(
                children: [
                  _getLanguageIcon(selected),
                  const SizedBox(width: 8),
                  Text(
                    selected,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (selected.isEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showLanguageList(context, provider),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select language',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _getLanguageIcon(String language) {
    // This is a simplified version. In production, you'd use actual flag icons
    final colors = {
      'Indonesian': const Color(0xFFFF0000),
      'English': const Color(0xFF012169),
      'Arabic': const Color(0xFF007A3D),
      'Malaysian': const Color(0xFFCC0001),
      'French': const Color(0xFF0055A4),
      'German': const Color(0xFF000000),
      'Hindi': const Color(0xFFFF9933),
      'Italian': const Color(0xFF009246),
      'Japanese': const Color(0xFFBC002D),
      'Korean': const Color(0xFF003478),
    };

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colors[language] ?? Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLevelSection({
    required String title,
    required int level,
    required String placeholder,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showLevelSelector(context, title, level, onChanged),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text(
              placeholder,
              style: TextStyle(
                color:
                    level == 0 && title == 'Written'
                        ? const Color(0xFF9E9E9E)
                        : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageList(BuildContext context, ProfileProvider provider) {
    final tempSelectedLanguages = <String>{};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Add Language",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search skills',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF9E9E9E),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.availableLanguages.length,
                        itemBuilder: (listContext, index) {
                          final lang = provider.availableLanguages[index];
                          final isSelected = tempSelectedLanguages.contains(
                            lang,
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFE6D5FF)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.trailing,
                              activeColor: const Color(0xFF6C3FB5),
                              secondary: _getLanguageIcon(lang),
                              title: Text(
                                lang,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                stfSetState(() {
                                  if (value == true) {
                                    tempSelectedLanguages.add(lang);
                                  } else {
                                    tempSelectedLanguages.remove(lang);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: CustomButton(
                    label: 'ADD',
                    onPressed: () {
                      if (tempSelectedLanguages.isNotEmpty) {
                        provider.updateEditingLanguage(
                          name: tempSelectedLanguages.first,
                        );
                      }
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLevelSelector(
    BuildContext context,
    String title,
    int current,
    ValueChanged<double> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Level $current',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 11,
              itemBuilder: (context, i) {
                return RadioListTile<int>(
                  title: Text(
                    "Level $i",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  value: i,
                  groupValue: current,
                  activeColor: const Color(0xFFFF9F43),
                  onChanged: (val) {
                    if (val != null) {
                      onChanged(val.toDouble());
                      Navigator.pop(dialogContext);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1548),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context, int index, String languageName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Remove $languageName ?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to delete this $languageName language?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileProvider>().removeLanguage(index);
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1548),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(child: Text('CONTINUE FILLING')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E1548),
                      backgroundColor: const Color(0xFFE6D5FF),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'UNDO CHANGES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveLanguage(BuildContext context) {
    context.read<ProfileProvider>().saveLanguage();
    Navigator.pop(context);
  }
}

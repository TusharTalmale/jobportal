import 'package:flutter/material.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  late final ProfileProvider _profileProvider;
  late final TextEditingController _skillController;

  // Predefined list of skills for suggestions
  final List<String> _allSkills = [
    'Graphic Design',
    'Graphic Thinking',
    'UI/UX Design',
    'Adobe Indesign',
    'Web Design',
    'InDesign',
    'Canva Design',
    'User Interface Design',
    'Product Design',
    'User Experience Design',
    'Leadership',
    'Teamwork',
    'Visioner',
    'Target oriented',
    'Consistent',
    'Good communication skills',
    'English',
    'Responsibility',
  ];

  List<String> _filteredSkills = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    _skillController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.initializeSkillsForm();
    });
  }

  @override
  void dispose() {
    _skillController.dispose();
    _profileProvider.disposeSkillsForm();
    super.dispose();
  }

  void _filterSkills(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSkills = [];
        _showSuggestions = false;
      } else {
        _filteredSkills =
            _allSkills
                .where(
                  (skill) =>
                      skill.toLowerCase().contains(query.toLowerCase()) &&
                      !_profileProvider.skillsToAdd.contains(skill),
                )
                .toList();
        _showSuggestions = true;
      }
    });
  }

  void _addSkill(String skill) {
    _profileProvider.addSkillToLocalList(skill);
    _skillController.clear();
    setState(() {
      _showSuggestions = false;
      _filteredSkills = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.read<ProfileProvider>().saveSkills();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Skill',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Field
                        TextFormField(
                          controller: _skillController,
                          onChanged: (value) {
                            provider.updateNewSkillText(value);
                            _filterSkills(value);
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon:
                                _skillController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _skillController.clear();
                                        setState(() {
                                          _showSuggestions = false;
                                          _filteredSkills = [];
                                        });
                                      },
                                    )
                                    : null,
                            hintText: 'Search skills',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        // Suggestions List
                        if (_showSuggestions && _filteredSkills.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredSkills.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap:
                                      () => _addSkill(_filteredSkills[index]),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      _filteredSkills[index],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Selected Skills as Chips
                        if (provider.skillsToAdd.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                provider.skillsToAdd.map((skill) {
                                  final index = provider.skillsToAdd.indexOf(
                                    skill,
                                  );
                                  // Highlight specific skill (like "Responsibility" in orange)
                                  final isHighlighted =
                                      skill == 'Responsibility';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isHighlighted
                                              ? Colors.orange.shade100
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          skill,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                isHighlighted
                                                    ? Colors.orange.shade800
                                                    : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            provider.removeSkillFromLocalList(
                                              index,
                                            );
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color:
                                                isHighlighted
                                                    ? Colors.orange.shade800
                                                    : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Save Button at Bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'SAVE',
                    onPressed: () {
                      context.read<ProfileProvider>().saveSkills();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

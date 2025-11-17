import 'package:flutter/material.dart';
import 'package:jobportal/screens/profile/profile_section_card.dart';

class ProfileListSection<T> extends StatelessWidget {
  final String title;
  final IconData iconData;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final String emptyMessage;
  final bool editModeOnContent;

  const ProfileListSection({
    super.key,
    required this.title,
    required this.iconData,
    required this.items,
    required this.itemBuilder,
    required this.onAdd,
    required this.onEdit,
    this.emptyMessage = 'No items added yet.',
    this.editModeOnContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: title,
      iconData: iconData,
      isEmpty: items.isEmpty,
      onAdd: onAdd,
      onEdit: onEdit,
      editModeOnContent: editModeOnContent,
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(emptyMessage),
              ),
            )
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => itemBuilder(context, items[index], index),
            ),
    );
  }
}
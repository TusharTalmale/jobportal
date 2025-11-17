import 'package:flutter/material.dart';
import 'package:jobportal/utils/appconstants.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Widget child;
  final bool isEmpty;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  // New flag to control button behavior based on designs
  final bool editModeOnContent;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.iconData,
    required this.child,
    required this.isEmpty,
    required this.onEdit,
    required this.onAdd,
    this.editModeOnContent = false, // Default to always showing "Add"
  });

  @override
  Widget build(BuildContext context) {
    // Determine which icon and action to use
    bool showEditIcon = editModeOnContent && !isEmpty;
    IconData iconToShow =
        showEditIcon ? Icons.edit_outlined : Icons.add_circle_outline;
    VoidCallback actionToTake = showEditIcon ? onEdit : onAdd;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Card Header ---
          Row(
            children: [
              Icon(iconData, color: AppColors.accentColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(iconToShow, color: AppColors.primaryColor, size: 24),
                onPressed: actionToTake,
              ),
            ],
          ),
          // --- Card Content ---
          if (!isEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }
}

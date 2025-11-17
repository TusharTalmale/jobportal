import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/utils/app_routes.dart';

Widget buildCompanyFollowCard(
  BuildContext context,
  NetworkProvider provider,
  Company company,
) {
  final isFollowing = provider.following.contains(company.id);

  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(
        context,
        AppRoutes.companyDetails,
        arguments: company.id,
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (company.companyLogo != null && company.companyLogo!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                company.companyLogo!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.business, size: 40),
              ),
            )
          else
            const Icon(Icons.business, size: 40),
          const SizedBox(height: 12),
          Text(
            company.companyName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            '${company.followersCount ?? '0'} Followers',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.toggleFollow(company.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.blue : Colors.white,
                foregroundColor: isFollowing ? Colors.white : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isFollowing ? Colors.transparent : Colors.blue,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

extension on ElevatedButton {
  ElevatedButton withCallback(VoidCallback callback) {
    return ElevatedButton(
      onPressed: onPressed != null ? () => callback : null,
      child: child,
    );
  }
}

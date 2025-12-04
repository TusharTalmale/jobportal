import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobportal/screens/saved/applied_job_details.dart';
import '../model.dart/job_application.dart';

class AppliedJobCard extends StatelessWidget {
  final JobApplication application;

  const AppliedJobCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final job = application.jobDetails;
    final company = job?["company"] ?? {};

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ApplicationDetailsPage(application: application),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                company["companyLogo"] ?? "",
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.apartment, size: 55),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job?["jobTitle"] ?? "No Title",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    company["companyName"] ?? "",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(application.createdAt ?? DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _statusChip(application.status),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "shortlisted":
        color = Colors.blue;
        break;
      case "interviewed":
        color = Colors.purple;
        break;
      case "hired":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:jobportal/model.dart/company.dart';
// import 'package:jobportal/model.dart/job.dart';
// import 'package:jobportal/provider/network_provider.dart';
// import 'package:jobportal/utils/date_formatter.dart';
// import 'package:jobportal/utils/app_routes.dart';

// /// A card that displays a job with a "post" like UI.
// Widget buildJobPostStyleCard(
//   BuildContext context,
//   NetworkProvider provider,
//   Job job,
// ) {
//   final company = job.company;

//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(22),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ---------------- HEADER ----------------
//         GestureDetector(
//           onTap: () {
//             Navigator.pushNamed(
//               context,
//               AppRoutes.companyDetails,
//               arguments:
//                   company,
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Use company logo
//                 if (company != null &&
//                     company.companyLogo != null &&
//                     company.companyLogo!.isNotEmpty)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       company.companyLogo!,
//                       width: 40,
//                       height: 40,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Icon(Icons.business, size: 40);
//                       },
//                     ),
//                   )
//                 else
//                   const Icon(Icons.business, size: 40),
//                 const SizedBox(width: 12),

//                 // Company name + time
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         company?.companyName ?? 'Unknown Company',
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             "Posted ${formatTimeAgo(job.postedAt)}",
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         // ---------------- TITLE ----------------
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18),
//           child: Text(
//             job.jobTitle, // Use job title
//             style: const TextStyle(
//               fontSize: 15.5,
//               fontWeight: FontWeight.w800,
//               height: 1.3,
//             ),
//           ),
//         ),

//         const SizedBox(height: 10),

//         // ---------------- DESCRIPTION ----------------
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18),
//           child: Text(
//             job.jobDescription ??
//                 'No description available.', // Use job description
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black54,
//               height: 1.45,
//             ),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),

//         const SizedBox(height: 16),

//         // ---------------- BOTTOM BAR ----------------
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
//           decoration: const BoxDecoration(
//             color: Color(0xffEFE7FF),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(22),
//               bottomRight: Radius.circular(22),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // ❤️ Like
//               GestureDetector(
//                 onTap: () {
//                   // TODO: Implement job liking functionality
//                 },
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.favorite_border,
//                       color: Colors.grey,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 6),
//                     const Text("0", style: TextStyle(fontSize: 13)),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 28),

//               // 💬 Comments
//               GestureDetector(
//                 onTap: () {

//                 },
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.comment_outlined,
//                       size: 20,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 6),
//                     Text("0", style: const TextStyle(fontSize: 13)),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 28),

//               // ↗️ Share
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.share_outlined,
//                     size: 20,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(width: 6),
//                   const Text("0", style: TextStyle(fontSize: 13)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

import 'package:intl/intl.dart';

String formatTimeAgo(DateTime? date) {
  if (date == null) {
    return 'recently';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()}y ago';
  } else if (difference.inDays >= 30) {
    return '${(difference.inDays / 30).floor()}mo ago';
  } else if (difference.inDays >= 7) {
    return '${(difference.inDays / 7).floor()}w ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'just now';
  }
}

String formatFullDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat.yMMMd().format(date); // e.g., Sep 10, 2023
}
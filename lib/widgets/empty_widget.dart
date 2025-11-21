
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String message;

  const EmptyStateWidget({
    super.key,
    this.imagePath = "assets/images/noresult.png",
    this.title = "No results found",
    this.message =
        "The search could not be found, please check\nspelling or write another word.",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image / Illustration
            SizedBox(
              height: 200,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    theme
                        .colorScheme
                        .primary, // Assuming primary color for main titles
              ),
            ),

            const SizedBox(height: 10),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color:
                    theme
                        .colorScheme
                        .onSurfaceVariant, // Assuming a secondary text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

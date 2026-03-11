import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onButtonPressed;

  const CustomCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          // Image
          Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Black shade with content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Button'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

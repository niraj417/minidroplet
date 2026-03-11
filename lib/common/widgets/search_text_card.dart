import 'package:flutter/cupertino.dart';
import '../../core/constant/app_export.dart';

class SearchTextCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const SearchTextCard({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2), // Changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Icon(CupertinoIcons.text_aligncenter, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

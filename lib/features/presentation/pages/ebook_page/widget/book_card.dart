import 'package:flutter/material.dart';
import 'package:tinydroplets/common/widgets/custom_image.dart';
import 'package:tinydroplets/core/theme/app_color.dart';

class BookCard extends StatelessWidget {
  final String imageUrl;
  final String bookName;
  // final double progress;

  const BookCard({
    super.key,
    required this.imageUrl,
    required this.bookName,
    // required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 210,
      width: 155,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Rounded corners
              child: CustomImage(
                imageUrl: imageUrl,
              ),
            ),
          ),
          const SizedBox(height: 5), // Spacing
          Text(
            bookName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0.5), // Spacing
          // SizedBox(
          //   width: 130,
          //   child: Row(
          //     children: [
          //       // Progress Bar
          //       Expanded(
          //         child: LinearProgressIndicator(
          //           value: progress,
          //           backgroundColor: Colors.grey[300],
          //           color: Color(AppColor.primaryColor),
          //           minHeight: 5,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //       ),
          //       const SizedBox(width: 10), // Spacing
          //       // Percentage
          //       Text(
          //         "${(progress * 100).toStringAsFixed(0)}%",
          //         style: const TextStyle(
          //             fontSize: 10, fontWeight: FontWeight.w600),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

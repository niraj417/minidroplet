import '../../../../../core/constant/app_export.dart';

class TrendingBookCard extends StatelessWidget {
  final String imageUrl;
  final String bookName;
  final String author;
  const TrendingBookCard({
    super.key,
    required this.imageUrl,
    required this.bookName,
    required this.author,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded corners
            child: CustomImage(
              imageUrl: imageUrl,

            ),
          ),
          const SizedBox(height: 5), // Spacing
          Expanded(
            child: Text(
              bookName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              softWrap: true,
               overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              author,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

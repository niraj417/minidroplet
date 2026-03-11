
import '../../../../../../core/constant/app_export.dart';

class VideoRatingBottomSheet extends StatefulWidget {
  final int initialRating;
  final String initialComment;
  final Function(int rating, String comment) onSubmit;
  final int videoId;

  const VideoRatingBottomSheet({
    Key? key,
    this.initialRating = 0,
    this.initialComment = '',
    required this.onSubmit,
    required this.videoId,
  }) : super(key: key);

  @override
  State<VideoRatingBottomSheet> createState() => _VideoRatingBottomSheetState();
}

class _VideoRatingBottomSheetState extends State<VideoRatingBottomSheet> {
  late int _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close button at top right
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            'Rate your experience',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            "How's your overall experience today?",
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 20),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 25),

          // Comment Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Describe your issue',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "We'd love to hear your suggestions",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 25),

          // Submit Button
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                widget.onSubmit(_rating, _commentController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Submit'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
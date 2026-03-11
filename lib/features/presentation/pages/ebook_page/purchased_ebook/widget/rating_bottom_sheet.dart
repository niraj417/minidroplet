import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';

class RatingBottomSheet extends StatefulWidget {
  final int ebookId;
  final Function(bool) onRatingSubmitted;

  const RatingBottomSheet({
    super.key,
    required this.ebookId,
    required this.onRatingSubmitted,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {

      CommonMethods.showSnackBar(context,'Please select a rating');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.addEbookRating,
        {
          "ebook_id": widget.ebookId,
          "rating": _selectedRating,
          "review": _reviewController.text.trim(),
        },
      );

      if (response.data['status'] == 1) {
        widget.onRatingSubmitted(true);
        if (mounted) {
          Navigator.pop(context);
          CommonMethods.showSnackBar(context,
              response.data['message'] ?? 'Rating submitted successfully');
        }
      } else {
        if (mounted) {
          CommonMethods.showSnackBar(context,'Failed to submit rating');

        }
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context,'Oops something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rate this Book',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return IconButton(
                icon: Icon(
                  Icons.star,
                  size: 32,
                  color: starNumber <= _selectedRating
                      ? Color(AppColor.primaryColor)
                      : Colors.grey[300],
                ),
                onPressed: () {
                  setState(() => _selectedRating = starNumber);
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review here',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Rating'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/ebook_page_carousel_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/trending_book_card.dart';

class EbookPageCarouselSection extends StatelessWidget {
  final EbookPageCarouselData carouselData;
  final Function(AllEbookDataModel) onEbookTap;
  final bool isSubscribed;
  final bool showAdForFreeBooks;

  const EbookPageCarouselSection({
    Key? key,
    required this.carouselData,
    required this.onEbookTap,
    required this.isSubscribed,
    required this.showAdForFreeBooks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (carouselData.ebooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              carouselData.carouselName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),

          // Books List
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: carouselData.ebooks.length,
              itemBuilder: (context, index) {
                final ebook = carouselData.ebooks[index];

                // Create book card
                Widget bookCard = TrendingBookCard(
                  imageUrl: ebook.coverImage,
                  bookName: ebook.title,
                  author: ebook.adminName,
                );

                // Wrap with ad if needed
                final shouldShowAd = showAdForFreeBooks &&
                    !isSubscribed &&
                    ebook.priceType == 'free';

                if (shouldShowAd) {
                  // You'll need to import InterstitialAdWidget
                  // return InterstitialAdWidget(
                  //   onAdClosed: () => onEbookTap(ebook),
                  //   child: bookCard,
                  // );
                  // For now, just return the card with tap
                  return GestureDetector(
                    onTap: () => onEbookTap(ebook),
                    child: bookCard,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => onEbookTap(ebook),
                    child: bookCard,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
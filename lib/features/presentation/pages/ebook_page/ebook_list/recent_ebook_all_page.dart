import 'package:flutter/material.dart';
import 'package:tinydroplets/common/widgets/app_bar/custom_app_bar.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/recently_viewed_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/book_card.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/trending_book_card.dart';

import '../../../../../common/navigation/navigation_service.dart';
import '../../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../buy_ebook/ebook_buy_page.dart';
import '../purchased_ebook/purchased_ebook_detail_page.dart';

class RecentEbookAllPage extends StatelessWidget {
  final List<RecentlyViewedEbookDataModel> recentEbookData;
  const RecentEbookAllPage({super.key, required this.recentEbookData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'All Ebooks'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: GridView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.67,
          ),
          itemCount: recentEbookData.length,
          itemBuilder: (context, index) {
            final data = recentEbookData[index];
            bool shouldShowAd = data.priceType == 'free';

            print('Grid Item ${data.id}: priceType=${data.priceType}, isBuy=${data.isBuy}, shouldShowAd=$shouldShowAd');

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: shouldShowAd
                  ? InterstitialAdWidget(
                onAdClosed: () {
                  print('Ad closed for grid item ${data.id}');
                  if (data.isBuy == '1') {
                    goto(
                      context,
                      PurchasedEbookBuyDetailPage(ebookId: data.id),
                    );
                  } else {
                    goto(
                      context,
                      EbookBuyDetailPage(ebookId: data.id),
                    );
                  }
                },
                child: TrendingBookCard(
                  imageUrl: data.coverImage,
                  bookName: data.title,
                  author: data.adminName,
                ),
              )
                  : InkWell(
                onTap: () {
                  print('Tapped grid item ${data.id}');
                  if (data.isBuy == '1') {
                    goto(
                      context,
                      PurchasedEbookBuyDetailPage(ebookId: data.id),
                    );
                  } else {
                    goto(
                      context,
                      EbookBuyDetailPage(ebookId: data.id),
                    );
                  }
                },
                child: TrendingBookCard(
                  imageUrl: data.coverImage,
                  bookName: data.title,
                  author: data.adminName,
                ),
              ),
            );
          },
        ),

      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/app_bar/custom_app_bar.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/trending_book_card.dart';
import '../../../../../common/navigation/navigation_service.dart';
import '../../../../../common/widgets/guest_user_restriction.dart';
import '../../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../../core/utils/shared_pref.dart';
import '../../../../../core/utils/shared_pref_key.dart';
import '../buy_ebook/ebook_buy_page.dart';
import '../purchased_ebook/purchased_ebook_detail_page.dart';
import 'bloc/ebook_bloc.dart';
import 'bloc/ebook_state.dart';

class EbookAllPage extends StatefulWidget {
  final List<AllEbookDataModel> allEbookData;
  const EbookAllPage({super.key, required this.allEbookData});

  @override
  State<EbookAllPage> createState() => _EbookAllPageState();
}

class _EbookAllPageState extends State<EbookAllPage> {

  bool paidAvailable = false;

  @override
  void initState() {
    super.initState();
    paidAvailable = SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

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
          itemCount: widget.allEbookData.length,
          itemBuilder: (context, index) {
            final data = widget.allEbookData[index];
            bool shouldShowAd = data.priceType == 'free';

            print('All Ebook Item ${data.id}: priceType=${data.priceType}, isBuy=${data.isBuy}, shouldShowAd=$shouldShowAd');

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: shouldShowAd
                  ? InterstitialAdWidget(
                onAdClosed: () {
                  if(SharedPref.isGuestUser() && widget.allEbookData[index].id != 29 && widget.allEbookData[index].id != 28){
                    GuestRestrictionDialog.show(context);
                    return;
                  }
                  print('Ad closed for allEbookData item ${data.id}');
                  if (data.isBuy == '1' || paidAvailable) {
                    print("Paid Ebook Avialable : ${paidAvailable}");
                    goto(
                      context,
                      PurchasedEbookBuyDetailPage(ebookId: data.id),
                    );
                    context.read<EbookBloc>().add(FetchRecentlyViewedEbookData());
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
                  print('Tapped allEbookData item ${data.id}');
                  if (data.isBuy == '1' || paidAvailable) {
                    goto(
                      context,
                      PurchasedEbookBuyDetailPage(ebookId: data.id),
                    );
                    context.read<EbookBloc>().add(FetchRecentlyViewedEbookData());
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

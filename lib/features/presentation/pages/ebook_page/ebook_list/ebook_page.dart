import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_filter/ebook_search_filter_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/ebook_all_page.dart';
import 'package:tinydroplets/common/widgets/search_text_filed.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/buy_ebook/ebook_buy_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/recent_ebook_all_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/ebook_slider_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/book_card.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/trending_book_card.dart';
import '../../../../../common/widgets/custom_caraousel.dart';
import '../../../../../common/widgets/guest_user_restriction.dart';
import '../../../../../common/widgets/search_text_card.dart';
import '../../../../../core/services/ad_service/ad_bloc/ad_cubit.dart';
import '../../../../../core/services/ad_service/ad_manager.dart';
import '../../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../../core/utils/url_opener.dart';
import '../../feed_page/bloc/feed_bloc.dart';
import '../search_ebook/search_ebook.dart';
import 'bloc/ebook_bloc.dart';
import 'bloc/ebook_event.dart';
import 'bloc/ebook_state.dart';

class EbookPage extends StatefulWidget {
  const EbookPage({super.key});

  @override
  State<EbookPage> createState() => _EbookPageState();
}

class _EbookPageState extends State<EbookPage> {

  bool isSubscribed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSubscribed = SharedPref.getBool("isSubscribed") ?? false;
  }

  Future<void> _handleRefresh(BuildContext context) async {
    context.read<EbookBloc>().add(RefreshEbookData());
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: 'Guide'),
      body: BlocBuilder<EbookBloc, EbookState>(
        builder: (context, state) {
          return RefreshIndicator(
            backgroundColor: Color(AppColor.primaryColor),
            color: Colors.white,

            onRefresh: () => _handleRefresh(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SearchTextCard(
                          text: 'Search Guides and Meal Plans',
                          onTap: () => goto(context, EbookSearchFilterScreen()),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (state.ebookItems.isNotEmpty)
                        CustomCarousel<EbookSliderDataModel>(
                          items:
                              state.ebookItems.isNotEmpty
                                  ? state.ebookItems
                                  : [],
                          itemBuilder:
                              (context, imageUrl, index) => GestureDetector(
                                onTap: () {
                                  // UrlOpener.launchURL(imageUrl.image);

                                  if (imageUrl.isBuy == '1' || !isSubscribed) {
                                    if (imageUrl.openId == null) {
                                      CommonMethods.showSnackBar(
                                        context,
                                        'Id not found',
                                      );
                                      return;
                                    } else {
                                      goto(
                                        context,
                                        PurchasedEbookBuyDetailPage(
                                          ebookId: int.parse(
                                            imageUrl.openId ?? '',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (imageUrl.openId == null) {
                                      CommonMethods.showSnackBar(
                                        context,
                                        'Id not found',
                                      );
                                      return;
                                    } else {
                                      goto(
                                        context,
                                        EbookBuyDetailPage(
                                          ebookId: int.parse(
                                            imageUrl.openId ?? '',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CustomImage(
                                      imageUrl: imageUrl.image,
                                      width: 300,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      BlocBuilder<EbookBloc, EbookState>(
                        builder: (context, state) {
                          if (state.recentlyViewedItem.isEmpty) {
                            // return NoDataWidget(
                            //     onPressed: () => context
                            //         .read<EbookBloc>()
                            //         .add(FetchRecentlyViewedEbookData()));
                            //return NoDataWidget(onPressed: onPressed)
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                              ),
                              child: AppButton(
                                onPressed: () {
                                  goto(
                                    context,
                                    EbookAllPage(
                                      allEbookData: state.allEbookItems,
                                    ),
                                  );
                                },
                                text: 'Explore More',
                                width: MediaQuery.of(context).size.width * 0.4,
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Continue explore',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        goto(
                                          context,
                                          RecentEbookAllPage(
                                            recentEbookData:
                                                state.recentlyViewedItem,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'View all',
                                        style: TextStyle(
                                          color: Color(AppColor.primaryColor),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 255,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.recentlyViewedItem.length > 5
                                        ? 5
                                        : state.recentlyViewedItem.length,
                                    itemBuilder: (context, index) {
                                      final data = state.recentlyViewedItem[index];

                                      // Check if this should show ads (only for free ebooks)
                                      bool shouldShowAd = data.priceType == 'free';

                                      // Debug logging
                                      print('Recently Viewed Item ${data.id}: priceType=${data.priceType}, isBuy=${data.isBuy}, shouldShowAd=$shouldShowAd');

                                      return Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: shouldShowAd
                                            ? InterstitialAdWidget(
                                          onAdClosed: () {
                                            if(SharedPref.isGuestUser() && data.id != 29 && data.id != 28){
                                              GuestRestrictionDialog.show(context);
                                              return;
                                            }

                                            print('Ad closed for recently viewed item ${data.id}');
                                            if (data.isBuy == '1' || !isSubscribed) {
                                              goto(
                                                context,
                                                PurchasedEbookBuyDetailPage(ebookId: data.id),
                                              );
                                              context.read<EbookBloc>().add(
                                                FetchRecentlyViewedEbookData(),
                                              );
                                            } else {
                                              goto(
                                                context,
                                                EbookBuyDetailPage(ebookId: data.id),
                                              );
                                              context.read<EbookBloc>().add(
                                                FetchRecentlyViewedEbookData(),
                                              );
                                            }
                                          },
                                          child: TrendingBookCard(
                                            imageUrl: data.coverImage,
                                            bookName: data.title,
                                            author: data.adminName,
                                          ),
                                        )
                                            : GestureDetector(
                                          onTap: () {
                                            print('GestureDetector tapped for recently viewed item ${data.id}');
                                            if (data.isBuy == '1' || !isSubscribed) {
                                              goto(
                                                context,
                                                PurchasedEbookBuyDetailPage(ebookId: data.id),
                                              );
                                              context.read<EbookBloc>().add(
                                                FetchRecentlyViewedEbookData(),
                                              );
                                            } else {
                                              goto(
                                                context,
                                                EbookBuyDetailPage(ebookId: data.id),
                                              );
                                              context.read<EbookBloc>().add(
                                                FetchRecentlyViewedEbookData(),
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
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child:
                            state.allEbookItems.isEmpty
                                ? NoDataWidget(
                                  onPressed:
                                      () => context.read<EbookBloc>().add(
                                        FetchRecentlyViewedEbookData(),
                                      ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Trending books',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            goto(
                                              context,
                                              EbookAllPage(
                                                allEbookData:
                                                    state.allEbookItems,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'View all',
                                            style: TextStyle(
                                              color: Color(
                                                AppColor.primaryColor,
                                              ),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 255,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.allEbookItems.length >= 5 ? 5 : state.allEbookItems.length,
                                        itemBuilder: (context, index) {
                                          final data = state.allEbookItems[index];

                                          // Check if this should show ads (only for free ebooks)
                                          bool shouldShowAd = data.priceType == 'free';

                                          // Debug logging
                                          print('Item ${data.id}: priceType=${data.priceType}, isBuy=${data.isBuy}, shouldShowAd=$shouldShowAd');

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 16.0),
                                            child: shouldShowAd
                                                ? InterstitialAdWidget(
                                              onAdClosed: () {
                                                if(SharedPref.isGuestUser() && data.id != 29 && data.id != 28){
                                                  GuestRestrictionDialog.show(context);
                                                  return;
                                                }
                                                if (data.isBuy == '1' || !isSubscribed) {
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
                                                if (data.isBuy == '1' || !isSubscribed) {
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
                                    /* SizedBox(
                                      height: 255,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            state.allEbookItems.length >= 5
                                                ? 5
                                                : state.allEbookItems.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              state.allEbookItems[index];

                                          */
                                    /*return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16.0,
                                            ),
                                            child: InterstitialAdWidget(
                                              onAdClosed: (){
                                                goto(context, EbookBuyDetailPage(ebookId: data.id));
                                              },
                                              child: TrendingBookCard(
                                                imageUrl: data.coverImage,
                                                bookName: data.title,
                                                author: data.adminName,
                                              ),
                                            ),
                                          );*/
                                    /*

                                          */
                                    /* return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16.0,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (data.isBuy == '1') {
                                                  goto(
                                                    context,
                                                    PurchasedEbookBuyDetailPage(
                                                      ebookId: data.id,
                                                    ),
                                                  );
                                                } else {
                                                  if (data.priceType == 'free') {
                                                    final adCubit = context.read<AdCubit>();
                                                    if (AdManager().shouldShowAds(context)) {
                                                      adCubit.showInterstitialAd(
                                                        onAdClosed: () {
                                                          goto(
                                                            context,
                                                            EbookBuyDetailPage(
                                                              ebookId: data.id,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      // If ads shouldn't show, navigate directly
                                                      goto(
                                                        context,
                                                        EbookBuyDetailPage(
                                                          ebookId: data.id,
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    // If not free, just navigate
                                                    goto(
                                                      context,
                                                      EbookBuyDetailPage(
                                                        ebookId: data.id,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: TrendingBookCard(
                                                imageUrl: data.coverImage,
                                                bookName: data.title,
                                                author: data.adminName,
                                              ),
                                            ),
                                          );*/
                                    /*
                                        },
                                      ),
                                    ),*/
                                    const SizedBox(height: 120),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

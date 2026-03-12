import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_filter/ebook_search_filter_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/ebook_all_page.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/buy_ebook/ebook_buy_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/recent_ebook_all_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/ebook_slider_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/trending_book_card.dart';
import '../../../../../common/widgets/custom_caraousel.dart';
import '../../../../../common/widgets/guest_user_restriction.dart';
import '../../../../../common/widgets/search_text_card.dart';
import '../../../../../core/constant/app_vector.dart';
import '../../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../model/recently_viewed_ebook_model.dart';
import '../widget/ebook_page_carousel_section.dart';
import 'bloc/ebook_bloc.dart';
import 'bloc/ebook_event.dart';
import 'bloc/ebook_state.dart';

class EbookPage extends StatefulWidget {
  const EbookPage({super.key});

  @override
  State<EbookPage> createState() => _EbookPageState();
}

class _EbookPageState extends State<EbookPage> {
  /// Trial OR subscription = premium
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    isSubscribed =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
    ebookCarouselItems = [];
  }

  Future<void> _handleRefresh(BuildContext context) async {
    context.read<EbookBloc>().add(RefreshEbookData());
    //return Future.delayed(const Duration(seconds: 1));
  }

  // =============================================================
  // RECENTLY VIEWED (RecentlyViewedEbookDataModel)
  // =============================================================
  void _openRecentlyViewedEbook(
      BuildContext context,
      RecentlyViewedEbookDataModel data,
      ) {
    if (SharedPref.isGuestUser() && data.id != 29 && data.id != 28) {
      GuestRestrictionDialog.show(context);
      return;
    }

    if (isSubscribed) {
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

    context.read<EbookBloc>().add(FetchRecentlyViewedEbookData());
  }

  // =============================================================
  // TRENDING / ALL EBOOKS (AllEbookDataModel)
  // =============================================================
  void _openEbook(
      BuildContext context,
      AllEbookDataModel data,
      ) {
    if (SharedPref.isGuestUser() && data.id != 29 && data.id != 28) {
      GuestRestrictionDialog.show(context);
      return;
    }

    if (isSubscribed) {
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
  }

  late List<EbookSliderDataModel> ebookCarouselItems;

  /// Ads only for free + non-premium users
  bool _shouldShowAd(String priceType) {
    return priceType == 'free' && !isSubscribed;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: 'Guide'),
      body: BlocBuilder<EbookBloc, EbookState>(
        builder: (context, state) {

          final bool isLoading =
              state.isCarouselLoading ||
                  state.isAllEbookLoading ||
                  state.recentlyViewedItemLoading ||
                  state.isPageCarouselsLoading;

          ebookCarouselItems = state.ebookItems
              .where((e) => e.image != null && e.image.isNotEmpty)
              .toList();

          return Stack(
            children: [
              RefreshIndicator(
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
                          /// Search
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 0),
                            child: SearchTextCard(
                              text: 'Search Guides and Meal Plans',
                              onTap: () =>
                                  goto(context, EbookSearchFilterScreen()),
                            ),
                          ),

                          /// Slider
                          if (!state.isCarouselLoading && ebookCarouselItems.isNotEmpty)
                            CustomCarousel<EbookSliderDataModel>(
                              items: ebookCarouselItems,
                              itemBuilder: (context, item, index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (item.openId != null) {
                                      final id = int.parse(item.openId!);
                                      if (isSubscribed) {
                                        goto(context, PurchasedEbookBuyDetailPage(ebookId: id));
                                      } else {
                                        goto(context, EbookBuyDetailPage(ebookId: id));
                                      }
                                    } else {
                                      debugPrint('⚠️ Ebook tapped without openId');
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CustomImage(
                                        imageUrl: item.image,
                                        width: 300,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          /// Recently Viewed
                          if (state.recentlyViewedItem.isEmpty)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                                width:
                                MediaQuery.of(context).size.width * 0.4,
                              ),
                            )
                          else
                            _recentlyViewedSection(state),

                          /// Trending
                          _trendingSection(state),
                          /// Dynamic Carousel Sections
                          if (!state.isPageCarouselsLoading && state.ebookPageCarousels.isNotEmpty)
                            ...state.ebookPageCarousels.map((carousel) {
                              return EbookPageCarouselSection(
                                carouselData: carousel,
                                onEbookTap: (ebook) => _openEbook(context, ebook),
                                isSubscribed: isSubscribed,
                                showAdForFreeBooks: true, // Set based on your logic
                              );
                            }).toList(),

                          premiumPlaylistBanner(
                            context: context,
                              onTap: () {
                                goto(
                                  context,
                                  EbookAllPage(
                                    allEbookData: state.allEbookItems,
                                  ),
                                );
                              }
                          ),

                          SizedBox(height: 120,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /// ==============================
              /// LOTTIE OVERLAY
              /// ==============================
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                    child: Center(
                      child: Lottie.asset(
                        AppVector.waterDropLoading,
                        width: 120,
                        height: 120,
                        repeat: true,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget premiumPlaylistBanner({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //color: const Color(0xFFE6F59D), // fallback color
        ),
        clipBehavior: Clip.antiAlias, // ✅ ensures rounded corners
        child: Stack(
          children: [
            /// 🔹 Background Image (left aligned, no cropping)
            Positioned.fill(
              child: Image.asset(
                AppVector.ebookBanner, // your asset
                fit: BoxFit.cover, // ✅ no height/width crop
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  Widget _recentlyViewedSection(EbookState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Continue explore',
            onViewAll: () => goto(
              context,
              RecentEbookAllPage(
                recentEbookData: state.recentlyViewedItem,
              ),
            ),
          ),
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.recentlyViewedItem.length > 5
                  ? 5
                  : state.recentlyViewedItem.length,
              itemBuilder: (context, index) {
                final data = state.recentlyViewedItem[index];
                final card = TrendingBookCard(
                  imageUrl: data.coverImage,
                  bookName: data.title,
                  author: data.adminName,
                );

                if (_shouldShowAd(data.priceType)) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: InterstitialAdWidget(
                      onAdClosed: () =>
                          _openRecentlyViewedEbook(context, data),
                      child: card,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () =>
                        _openRecentlyViewedEbook(context, data),
                    child: card,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  Widget _trendingSection(EbookState state) {
    if (state.allEbookItems.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<EbookBloc>().add(FetchRecentlyViewedEbookData()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Trending books',
            onViewAll: () => goto(
              context,
              EbookAllPage(allEbookData: state.allEbookItems),
            ),
          ),
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.allEbookItems.length >= 5
                  ? 5
                  : state.allEbookItems.length,
              itemBuilder: (context, index) {
                final data = state.allEbookItems[index];
                final card = TrendingBookCard(
                  imageUrl: data.coverImage,
                  bookName: data.title,
                  author: data.adminName,
                );

                if (_shouldShowAd(data.priceType)) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: InterstitialAdWidget(
                      onAdClosed: () => _openEbook(context, data),
                      child: card,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _openEbook(context, data),
                    child: card,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        TextButton(
          onPressed: onViewAll,
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
    );
  }
}
import '../../model/all_ebook_model.dart';
import '../../model/ebook_page_carousel_model.dart';
import '../../model/ebook_slider_model.dart';
import '../../model/recently_viewed_ebook_model.dart';

abstract class EbookState {
  final List<EbookSliderDataModel> ebookItems;
  final List<AllEbookDataModel> allEbookItems;
  final List<RecentlyViewedEbookDataModel> recentlyViewedItem;
  final List<EbookPageCarouselData> ebookPageCarousels; // NEW
  final bool isCarouselLoading;
  final bool isAllEbookLoading;
  final bool recentlyViewedItemLoading;
  final bool isPageCarouselsLoading; // NEW

  EbookState({
    required this.ebookItems,
    required this.allEbookItems,
    required this.isCarouselLoading,
    required this.isAllEbookLoading,
    required this.recentlyViewedItem,
    required this.recentlyViewedItemLoading,
    required this.ebookPageCarousels, // NEW
    required this.isPageCarouselsLoading, // NEW
  });
}

class EbookInitial extends EbookState {
  EbookInitial()
      : super(
    ebookItems: [],
    allEbookItems: [],
    recentlyViewedItem: [],
    ebookPageCarousels: [], // NEW
    isCarouselLoading: true,
    isAllEbookLoading: true,
    recentlyViewedItemLoading: true,
    isPageCarouselsLoading: true, // NEW
  );
}

class EbookLoaded extends EbookState {
  EbookLoaded({
    required super.ebookItems,
    required super.allEbookItems,
    required super.recentlyViewedItem,
    required super.ebookPageCarousels, // NEW
    required super.isCarouselLoading,
    required super.isAllEbookLoading,
    required super.recentlyViewedItemLoading,
    required super.isPageCarouselsLoading, // NEW
  });
}
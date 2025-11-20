
// ebook_state.dart
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/recently_viewed_ebook_model.dart';

import '../../model/all_ebook_model.dart';
import '../../model/ebook_slider_model.dart';

abstract class EbookState {
  final List<EbookSliderDataModel> ebookItems;
  final List<AllEbookDataModel> allEbookItems;
  final List<RecentlyViewedEbookDataModel> recentlyViewedItem;
  final bool isCarouselLoading;
  final bool isAllEbookLoading;
  final bool recentlyViewedItemLoading;

  EbookState({
    required this.ebookItems,
    required this.allEbookItems,
    required this.isCarouselLoading,
    required this.isAllEbookLoading,
    required this.recentlyViewedItem,
    required this.recentlyViewedItemLoading,
  });
}

class EbookInitial extends EbookState {
  EbookInitial()
      : super(
    ebookItems: [],
    allEbookItems: [],
    recentlyViewedItem: [],
    isCarouselLoading: true,
    isAllEbookLoading: true,
    recentlyViewedItemLoading: true,
  );
}

class EbookLoaded extends EbookState {
  EbookLoaded({
    required super.ebookItems,
    required super.allEbookItems,
    required super.recentlyViewedItem,
    required super.isCarouselLoading,
    required super.isAllEbookLoading,
    required super.recentlyViewedItemLoading,
  });
}

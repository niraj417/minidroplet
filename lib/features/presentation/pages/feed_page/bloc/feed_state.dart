part of 'feed_bloc.dart';

@immutable
sealed class FeedState {
  final List<FeedSliderDataModel>? carouselData;
  final List<FeedPostDataModel>? postData;
  final List<RecipeAllPlaylistDataModel>? playlistData;
  final List<HomepageCarouselDataModel>? homepageCarousels;
  final bool isHomepageCarouselLoading;
  final bool isCarouselLoading;
  final bool isPostLoading;
  final bool isLikeLoading;
  final String? error;
  final Map<int, List<Comment>>? localComments;
  final Map<int, List<Comment>>? localReplies;

  const FeedState({
    this.carouselData,
    this.postData,
    this.playlistData,
    this.homepageCarousels,
    this.isHomepageCarouselLoading = false,
    this.isCarouselLoading = false,
    this.isPostLoading = false,
    this.isLikeLoading = false,
    this.error,
    this.localComments,
    this.localReplies,
  });

  // Add a copyWith method for easier state updates
  FeedState copyWith({
    List<FeedSliderDataModel>? carouselData,
    List<FeedPostDataModel>? postData,
    List<RecipeAllPlaylistDataModel>? playlistData,
    List<HomepageCarouselDataModel>? homepageCarousels,
    bool? isHomepageCarouselLoading,
    bool? isCarouselLoading,
    bool? isPostLoading,
    bool? isLikeLoading,
    String? error,
    Map<int, List<Comment>>? localComments,
    Map<int, List<Comment>>? localReplies,
  }) {
    if (this is FeedLoaded) {
      return FeedLoaded(
        carouselData: carouselData ?? this.carouselData!,
        postData: postData ?? this.postData!,
        playlistData: playlistData ?? this.playlistData,
        homepageCarousels: homepageCarousels ?? this.homepageCarousels,
        localComments: localComments ?? this.localComments,
        localReplies: localReplies ?? this.localReplies,
      );
    }

    return FeedLoading(
      carouselData: carouselData ?? this.carouselData,
      postData: postData ?? this.postData,
      playlistData: playlistData ?? this.playlistData,
      homepageCarousels: homepageCarousels ?? this.homepageCarousels,
      isHomepageCarouselLoading:
      isHomepageCarouselLoading ?? this.isHomepageCarouselLoading,
      isCarouselLoading: isCarouselLoading ?? this.isCarouselLoading,
      isPostLoading: isPostLoading ?? this.isPostLoading,
      isLikeLoading: isLikeLoading ?? this.isLikeLoading,
      localComments: localComments ?? this.localComments,
      localReplies: localReplies ?? this.localReplies,
    );
  }

}

class FeedInitial extends FeedState {
  const FeedInitial() : super();
}

class FeedLoading extends FeedState {
  const FeedLoading({
    super.carouselData,
    super.postData,
    super.playlistData,
    super.homepageCarousels,
    super.isHomepageCarouselLoading,
    super.isCarouselLoading,
    super.isPostLoading,
    super.isLikeLoading,
    super.localComments,
    super.localReplies,
  });
}


class FeedLoaded extends FeedState {
  const FeedLoaded({
    required List<FeedSliderDataModel> carouselData,
    required List<FeedPostDataModel> postData,
    super.playlistData,
    super.homepageCarousels,
    super.localComments,
    super.localReplies,
  }) : super(
    carouselData: carouselData,
    postData: postData,
    isCarouselLoading: false,
    isPostLoading: false,
    isLikeLoading: false,
  );
}

class FeedError extends FeedState {
  const FeedError({required String error}) : super(error: error);
}

/*å
part of 'feed_bloc.dart';

@immutable
sealed class FeedState {
  final List<FeedSliderDataModel>? carouselData;
  final List<FeedPostDataModel>? postData;
  final bool isCarouselLoading;
  final bool isPostLoading;
  final bool isLikeLoading;
  final String? error;
  final Map<int, List<Comment>>? localComments;

  const FeedState({
    this.carouselData,
    this.postData,
    this.isCarouselLoading = false,
    this.isPostLoading = false,
    this.isLikeLoading = false,
    this.error,
    this.localComments,
  });
}

class FeedInitial extends FeedState {
  const FeedInitial() : super();
}

class FeedLoading extends FeedState {
  const FeedLoading({
    super.carouselData,
    super.postData,
    super.isCarouselLoading,
    super.isPostLoading,
    super.isLikeLoading,
    super.localComments,
  });
}

class FeedLoaded extends FeedState {
  const FeedLoaded({
    required List<FeedSliderDataModel> carouselData,
    required List<FeedPostDataModel> postData,
    super.localComments,
  }) : super(
    carouselData: carouselData,
    postData: postData,
    isCarouselLoading: false,
    isPostLoading: false,
    isLikeLoading: false,
  );
}

class FeedError extends FeedState {
  const FeedError({required String error}) : super(error: error);
}
*/

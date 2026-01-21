part of 'feed_bloc.dart';

@immutable
sealed class FeedEvent {}

class FeedCarouselData extends FeedEvent {}

class FeedPostData extends FeedEvent {}

class FeedPlaylistData extends FeedEvent {}

class FeedHomepageCarouselData extends FeedEvent {}

class FeedLikeData extends FeedEvent {
  final int postId;

  FeedLikeData({required this.postId});
}

class FeedPostCommentData extends FeedEvent {
  final int postId;
  final String comment;
  final Comment? localComment;

  FeedPostCommentData(this.localComment,
      {required this.postId, required this.comment});
}

class FeedPostReplyCommentData extends FeedEvent {
  final int commentId;
  final String comment;
  final Comment? localComment;

  FeedPostReplyCommentData(this.localComment,
      {required this.commentId, required this.comment});
}

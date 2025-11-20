import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/constant/app_export.dart';
import '../model/feed_post_model.dart';
import '../model/feed_slider_model.dart';
part 'feed_event.dart';
part 'feed_state.dart';

final DioClient dioClient = GetIt.instance<DioClient>();

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(const FeedInitial()) {
    on<FeedCarouselData>(_onFeedCarouselData);
    on<FeedPostData>(_onFeedPostData);
    on<FeedLikeData>(_onFeedLikeData);
    on<FeedPostCommentData>(_onFeedAddComment);
    on<FeedPostReplyCommentData>(_onFeedAddReplyComment);
  }

  // Handler for FeedCarouselData
  Future<void> _onFeedCarouselData(
      FeedCarouselData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: true,
      isPostLoading: state.isPostLoading,
    ));

    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.feedSlider);

      if (response.data['status'] == 1) {
        final data = FeedSliderModel.fromJson(response.data);
        emit(FeedLoading(
          carouselData: data.data,
          postData: state.postData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Handler for FeedPostData
  Future<void> _onFeedPostData(
      FeedPostData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: state.isCarouselLoading,
      isPostLoading: true,
    ));

    try {
      print('📥 FeedBloc: Fetching post data from ${ApiEndpoints.feedPost}');
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.feedPost,
        {"offset": 0, "limit": 10}, // Adjust parameters as needed
      );

      print('📥 FeedBloc: API Response received');
      print('   - Status: ${response.statusCode}');
      print('   - Data type: ${response.data.runtimeType}');
      print('   - Data keys: ${response.data.keys}');

      if (response.data['status'] == 1) {
        print('✅ FeedBloc: Status is 1, parsing data...');

        // Add try-catch around the parsing to catch the exact error
        try {
          final data = FeedPostModel.fromJson(response.data);
          print('✅ FeedBloc: Successfully parsed ${data.data.length} posts');

          emit(FeedLoaded(
            carouselData: state.carouselData ?? [],
            postData: data.data,
          ));
        } catch (parseError) {
          print('❌ FeedBloc: Parsing error: $parseError');
          print('❌ FeedBloc: Error type: ${parseError.runtimeType}');
          print('❌ FeedBloc: Stack trace: ${parseError.toString()}');
          emit(FeedError(error: 'Data parsing error: $parseError'));
        }
      } else {
        print('❌ FeedBloc: API returned status 0');
        emit(FeedError(error: response.data['message'] ?? 'Unknown error'));
      }
    } catch (e) {
      print('💥 FeedBloc: General error: $e');
      emit(FeedError(error: e.toString()));
    }
  }

  Future<void> _onFeedLikeData(
      FeedLikeData event, Emitter<FeedState> emit) async {
    final originalPostData = state.postData;

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.feedPostLike,
        {'post_id': event.postId},
      );

      if (response.data['status'] == 1) {
        final updatedPostData = originalPostData?.map((post) {
          if (post.id == event.postId) {
            final isCurrentlyLiked = post.isLike == "1";
            final updatedLikeCount =
                isCurrentlyLiked ? post.likeCount - 1 : post.likeCount + 1;

            return post.copyWith(
              isLike: isCurrentlyLiked ? "0" : "1",
              likeCount: updatedLikeCount,
            );
          }
          return post;
        }).toList();

        emit(FeedLoaded(
          carouselData: state.carouselData ?? [],
          postData: updatedPostData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }
  Future<void> _onFeedAddComment(
      FeedPostCommentData event,
      Emitter<FeedState> emit,
      ) async {
    if (state is! FeedLoaded) return;
    final currentState = state as FeedLoaded;

    try {
      // Handle optimistic update - IMMEDIATELY update the comment count
      if (event.localComment != null) {
        final updatedPostData = currentState.postData?.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              // Increment comment count immediately
              commentCount: post.commentCount + 1,
              allComments: [...post.allComments, event.localComment!],
            );
          }
          return post;
        }).toList();

        emit(FeedLoaded(
          carouselData: currentState.carouselData ?? [],
          postData: updatedPostData ?? [],
          localComments: {
            ...currentState.localComments ?? {},
            event.postId: [...(currentState.localComments?[event.postId] ?? []), event.localComment!],
          },
          localReplies: currentState.localReplies,
        ));
      }

      // Make API call
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.addFeedPostComment,
        {
          'post_id': event.postId,
          'comment': event.comment,
        },
      );

      if (response.data['status'] == 1) {
        final newComment = Comment.fromJson(response.data['data']);

        // Get the current state after optimistic update
        final latestState = state as FeedLoaded;

        final updatedPostData = latestState.postData?.map((post) {
          if (post.id == event.postId) {
            // Remove the local comment and add the server comment
            final comments = post.allComments
                .where((c) => c.id != event.localComment?.id)
                .toList();

            return post.copyWith(
              // KEEP THE INCREMENTED COUNT - Don't change it back
              commentCount: post.commentCount, // This is already incremented from optimistic update
              allComments: [...comments, newComment],
            );
          }
          return post;
        }).toList();

        // Remove local comment after successful API response
        final updatedLocalComments = Map<int, List<Comment>>.from(latestState.localComments ?? {});
        if (updatedLocalComments.containsKey(event.postId)) {
          updatedLocalComments[event.postId] = updatedLocalComments[event.postId]!
              .where((c) => c.id != event.localComment?.id)
              .toList();

          // Clean up empty entries
          if (updatedLocalComments[event.postId]!.isEmpty) {
            updatedLocalComments.remove(event.postId);
          }
        }

        emit(FeedLoaded(
          carouselData: latestState.carouselData ?? [],
          postData: updatedPostData ?? [],
          localComments: updatedLocalComments,
          localReplies: latestState.localReplies,
        ));
      } else {
        // If API fails, revert the comment count and remove local comment
        final latestState = state as FeedLoaded;
        final revertedPostData = latestState.postData?.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              commentCount: post.commentCount - 1, // Revert the increment
              allComments: post.allComments.where((c) => c.id != event.localComment?.id).toList(),
            );
          }
          return post;
        }).toList();

        // Remove local comment on failure
        final updatedLocalComments = Map<int, List<Comment>>.from(latestState.localComments ?? {});
        if (updatedLocalComments.containsKey(event.postId)) {
          updatedLocalComments[event.postId] = updatedLocalComments[event.postId]!
              .where((c) => c.id != event.localComment?.id)
              .toList();
          if (updatedLocalComments[event.postId]!.isEmpty) {
            updatedLocalComments.remove(event.postId);
          }
        }

        emit(FeedLoaded(
          carouselData: latestState.carouselData ?? [],
          postData: revertedPostData ?? [],
          localComments: updatedLocalComments,
          localReplies: latestState.localReplies,
        ));
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      // If exception occurs, revert the comment count
      final latestState = state as FeedLoaded;
      final revertedPostData = latestState.postData?.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            commentCount: post.commentCount - 1, // Revert the increment
            allComments: post.allComments.where((c) => c.id != event.localComment?.id).toList(),
          );
        }
        return post;
      }).toList();

      // Remove local comment on error
      final updatedLocalComments = Map<int, List<Comment>>.from(latestState.localComments ?? {});
      if (updatedLocalComments.containsKey(event.postId)) {
        updatedLocalComments[event.postId] = updatedLocalComments[event.postId]!
            .where((c) => c.id != event.localComment?.id)
            .toList();
        if (updatedLocalComments[event.postId]!.isEmpty) {
          updatedLocalComments.remove(event.postId);
        }
      }

      emit(FeedLoaded(
        carouselData: latestState.carouselData ?? [],
        postData: revertedPostData ?? [],
        localComments: updatedLocalComments,
        localReplies: latestState.localReplies,
      ));
      emit(FeedError(error: e.toString()));
    }
  }

// Also fix the reply comment method
  Future<void> _onFeedAddReplyComment(
      FeedPostReplyCommentData event,
      Emitter<FeedState> emit,
      ) async {
    if (state is! FeedLoaded) return;
    final currentState = state as FeedLoaded;

    try {
      // Handle optimistic update for reply
      if (event.localComment != null) {
        final updatedPostData = currentState.postData?.map((post) {
          final updatedComments = post.allComments.map((comment) {
            if (comment.id == event.commentId) {
              return comment.copyWith(
                replyComments: [...comment.replyComments, event.localComment!],
              );
            }
            return comment;
          }).toList();

          return post.copyWith(
            // Also increment main comment count for replies if needed
            // commentCount: post.commentCount + 1, // Uncomment if replies should count toward total
            allComments: updatedComments,
          );
        }).toList();

        emit(FeedLoaded(
          carouselData: currentState.carouselData ?? [],
          postData: updatedPostData ?? [],
          localComments: currentState.localComments,
          localReplies: {
            ...currentState.localReplies ?? {},
            event.commentId: [...(currentState.localReplies?[event.commentId] ?? []), event.localComment!],
          },
        ));
      }

      // Make API call for reply
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.replyFeedPostComment,
        {
          'comment_id': event.commentId,
          'comment': event.comment,
        },
      );

      if (response.data['status'] == 1) {
        final newReply = Comment.fromJson(response.data['data']);

        // Get the current state after optimistic update
        final latestState = state as FeedLoaded;

        // Update state with server response
        final updatedPostData = latestState.postData?.map((post) {
          final updatedComments = post.allComments.map((comment) {
            if (comment.id == event.commentId) {
              final replies = comment.replyComments
                  .where((r) => r.id != event.localComment?.id)
                  .toList();

              return comment.copyWith(
                replyComments: [...replies, newReply],
              );
            }
            return comment;
          }).toList();

          return post.copyWith(allComments: updatedComments);
        }).toList();

        // Remove local reply after successful API response
        final updatedLocalReplies = Map<int, List<Comment>>.from(latestState.localReplies ?? {});
        if (updatedLocalReplies.containsKey(event.commentId)) {
          updatedLocalReplies[event.commentId] = updatedLocalReplies[event.commentId]!
              .where((r) => r.id != event.localComment?.id)
              .toList();
          if (updatedLocalReplies[event.commentId]!.isEmpty) {
            updatedLocalReplies.remove(event.commentId);
          }
        }

        emit(FeedLoaded(
          carouselData: latestState.carouselData ?? [],
          postData: updatedPostData ?? [],
          localComments: latestState.localComments,
          localReplies: updatedLocalReplies,
        ));
      } else {
        // Handle API failure - revert optimistic update
        final latestState = state as FeedLoaded;
        final revertedPostData = latestState.postData?.map((post) {
          final revertedComments = post.allComments.map((comment) {
            if (comment.id == event.commentId) {
              return comment.copyWith(
                replyComments: comment.replyComments
                    .where((r) => r.id != event.localComment?.id)
                    .toList(),
              );
            }
            return comment;
          }).toList();

          return post.copyWith(allComments: revertedComments);
        }).toList();

        // Remove local reply on failure
        final updatedLocalReplies = Map<int, List<Comment>>.from(latestState.localReplies ?? {});
        if (updatedLocalReplies.containsKey(event.commentId)) {
          updatedLocalReplies[event.commentId] = updatedLocalReplies[event.commentId]!
              .where((r) => r.id != event.localComment?.id)
              .toList();
          if (updatedLocalReplies[event.commentId]!.isEmpty) {
            updatedLocalReplies.remove(event.commentId);
          }
        }

        emit(FeedLoaded(
          carouselData: latestState.carouselData ?? [],
          postData: revertedPostData ?? [],
          localComments: latestState.localComments,
          localReplies: updatedLocalReplies,
        ));
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      // Handle exception - revert optimistic update
      final latestState = state as FeedLoaded;
      final revertedPostData = latestState.postData?.map((post) {
        final revertedComments = post.allComments.map((comment) {
          if (comment.id == event.commentId) {
            return comment.copyWith(
              replyComments: comment.replyComments
                  .where((r) => r.id != event.localComment?.id)
                  .toList(),
            );
          }
          return comment;
        }).toList();

        return post.copyWith(allComments: revertedComments);
      }).toList();

      // Remove local reply on error
      final updatedLocalReplies = Map<int, List<Comment>>.from(latestState.localReplies ?? {});
      if (updatedLocalReplies.containsKey(event.commentId)) {
        updatedLocalReplies[event.commentId] = updatedLocalReplies[event.commentId]!
            .where((r) => r.id != event.localComment?.id)
            .toList();
        if (updatedLocalReplies[event.commentId]!.isEmpty) {
          updatedLocalReplies.remove(event.commentId);
        }
      }

      emit(FeedLoaded(
        carouselData: latestState.carouselData ?? [],
        postData: revertedPostData ?? [],
        localComments: latestState.localComments,
        localReplies: updatedLocalReplies,
      ));
      emit(FeedError(error: e.toString()));
    }
  }

void refreshFeed() {
    add(FeedPostData());
    add(FeedCarouselData());
  }
}

//
//
// final DioClient dioClient = GetIt.instance<DioClient>();
//
// class FeedBloc extends Bloc<FeedEvent, FeedState> {
//   FeedBloc() : super(const FeedInitial()) {
//     on<FeedCarouselData>(_onFeedCarouselData);
//     on<FeedPostData>(_onFeedPostData);
//     on<FeedLikeData>(_onFeedLikeData);
//   }
//
//   // Handler for FeedCarouselData
//   Future<void> _onFeedCarouselData(
//       FeedCarouselData event, Emitter<FeedState> emit) async {
//     emit(FeedLoading(
//       carouselData: state.carouselData,
//       postData: state.postData,
//       isCarouselLoading: true,
//       isPostLoading: state.isPostLoading,
//     ));
//     Future.delayed(Duration.zero);
//     try {
//       final response = await dioClient.sendGetRequest(ApiEndpoints.feedSlider);
//
//       if (response.data['status'] == 1) {
//         final data = FeedSliderModel.fromJson(response.data);
//         emit(FeedLoaded(
//           carouselData: data.data,
//           postData: state.postData ?? [],
//           feedLikeData: state.feedLikeData ?? [],
//         ));
//       } else {
//         emit(FeedError(error: response.data['message']));
//       }
//     } catch (e) {
//       emit(FeedError(error: e.toString()));
//     }
//   }
//
//   // Handler for FeedPostData
//   Future<void> _onFeedPostData(
//       FeedPostData event, Emitter<FeedState> emit) async {
//     emit(FeedLoading(
//       carouselData: state.carouselData,
//       postData: state.postData,
//       isCarouselLoading: state.isCarouselLoading,
//       isPostLoading: true,
//     ));
//
//     try {
//       final response = await dioClient.sendPostRequest(
//         ApiEndpoints.feedPost,
//         {"offset": 0, "limit": 1000}, // Adjust parameters as needed
//       );
//
//       if (response.data['status'] == 1) {
//         final data = FeedPostModel.fromJson(response.data);
//         emit(FeedLoaded(
//           carouselData: state.carouselData ?? [],
//           postData: data.data,
//           feedLikeData: state.feedLikeData ?? [],
//         ));
//       } else {
//         emit(FeedError(error: response.data['message']));
//       }
//     } catch (e) {
//       emit(FeedError(error: e.toString()));
//     }
//   }
//
//   // Handler for FeedLikeCommentData
//   Future<void> _onFeedLikeData(
//       FeedLikeData event, Emitter<FeedState> emit) async {
//     emit(FeedLoading(
//       carouselData: state.carouselData,
//       postData: state.postData,
//       feedLikeData: state.feedLikeData,
//       isCarouselLoading: state.isCarouselLoading,
//       isPostLoading: state.isPostLoading,
//       isLikeLoading: true,
//     ));
//
//     try {
//       final response = await dioClient
//           .sendPostRequest(ApiEndpoints.feedPostLike, {'post_id': 1});
//
//       if (response.data['status'] == 1) {
//         final likeData = FeedPostLikeModel.fromJson(response.data);
//         emit(FeedLoaded(
//           carouselData: state.carouselData ?? [],
//           postData: state.postData ?? [],
//           feedLikeData: [likeData], // Update this as necessary
//         ));
//       } else {
//         emit(FeedError(error: response.data['message']));
//       }
//     } catch (e) {
//       emit(FeedError(error: e.toString()));
//     }
//   }
//
//   // Call this method to trigger a refresh
//   void refreshFeed() {
//     add(FeedPostData());
//     add(FeedCarouselData());
//     add(FeedLikeData());
//   }
// }
//

/*

final DioClient dioClient = GetIt.instance<DioClient>();

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  late final StreamController<void> _feedStreamController;

  FeedBloc() : super(const FeedInitial()) {
    _feedStreamController = StreamController<void>.broadcast();
    on<FeedCarouselData>(_onFeedCarouselData);
    on<FeedPostData>(_onFeedPostData);
    on<FeedLikeCommentData>(_onFeedLikeCommentData);

    // Listen to the stream for automatic fetching
    _feedStreamController.stream.listen((_) {
      add(FeedPostData());
      add(FeedCarouselData());
      add(FeedLikeCommentData());
    });
  }

  // Handler for FeedCarouselData
  Future<void> _onFeedCarouselData(
      FeedCarouselData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: true,
      isPostLoading: state.isPostLoading,
    ));
    Future.delayed(Duration.zero);
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.feedSlider);

      if (response.data['status'] == 1) {
        final data = FeedSliderModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: data.data,
          postData: state.postData ?? [],
          feedLikeData: state.feedLikeData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Handler for FeedPostData
  Future<void> _onFeedPostData(
      FeedPostData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: state.isCarouselLoading,
      isPostLoading: true,
    ));

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.feedPost,
        {"offset": 0, "limit": 1000}, // Adjust parameters as needed
      );

      if (response.data['status'] == 1) {
        final data = FeedPostModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: state.carouselData ?? [],
          postData: data.data,
          feedLikeData: state.feedLikeData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Handler for FeedLikeCommentData
  Future<void> _onFeedLikeCommentData(
      FeedLikeCommentData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      feedLikeData: state.feedLikeData,
      isCarouselLoading: state.isCarouselLoading,
      isPostLoading: state.isPostLoading,
      isLikeLoading: true,
    ));

    try {
      final response = await dioClient
          .sendPostRequest(ApiEndpoints.feedPostLike, {'post_id': 1});

      if (response.data['status'] == 1) {
        final likeData = FeedPostLikeModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: state.carouselData ?? [],
          postData: state.postData ?? [],
          feedLikeData: [likeData], // Update this as necessary
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Call this method to trigger a refresh
  void refreshFeed() {
    _feedStreamController.add(null);
  }

  @override
  Future<void> close() {
    _feedStreamController.close();
    return super.close();
  }
}
*/

/*
final DioClient dioClient = GetIt.instance<DioClient>();

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(const FeedInitial()) {
    on<FeedCarouselData>(_onFeedCarouselData);
    on<FeedPostData>(_onFeedPostData);
    on<FeedLikeCommentData>(_onFeedLikeCommentData);
  }

  // Handler for FeedCarouselData
  Future<void> _onFeedCarouselData(
      FeedCarouselData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: true,
      isPostLoading: state.isPostLoading,
    ));

    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.feedSlider);

      if (response.data['status'] == 1) {
        final data = FeedSliderModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: data.data,
          postData: state.postData ?? [],
          feedLikeData: state.feedLikeData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Handler for FeedPostData
  Future<void> _onFeedPostData(
      FeedPostData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      isCarouselLoading: state.isCarouselLoading,
      isPostLoading: true,
    ));

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.feedPost,
        {"offset": 0, "limit": 1000}, // Adjust parameters as needed
      );

      if (response.data['status'] == 1) {
        final data = FeedPostModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: state.carouselData ?? [],
          postData: data.data,
          feedLikeData: state.feedLikeData ?? [],
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }

  // Handler for FeedLikeCommentData
  Future<void> _onFeedLikeCommentData(
      FeedLikeCommentData event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      carouselData: state.carouselData,
      postData: state.postData,
      feedLikeData: state.feedLikeData,
      isCarouselLoading: state.isCarouselLoading,
      isPostLoading: state.isPostLoading,
      isLikeLoading: true,
    ));

    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.feedPostLike,
      );

      if (response.data['status'] == 1) {
        final likeData = FeedPostLikeModel.fromJson(response.data);
        emit(FeedLoaded(
          carouselData: state.carouselData ?? [],
          postData: state.postData ?? [],
          feedLikeData: [likeData], // Update this as necessary
        ));
      } else {
        emit(FeedError(error: response.data['message']));
      }
    } catch (e) {
      emit(FeedError(error: e.toString()));
    }
  }
}*/

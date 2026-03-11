import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import '../network/api_endpoints.dart';
import '../utils/common_methods.dart';

class SharingHandler {
  static Future<void> handleFeedShare(
    int postId,
    String postTitle,
    String description,
    BuildContext context,
  ) async {
    try {
      await trackSharedPost(postId);
      final shareContent =
          '$postTitle\n\n$description\nShared via Tiny Droplets';
      Share.share(shareContent);
    } catch (e) {
      CommonMethods.showSnackBar(
        context,
        'Failed to track share: ${e.toString()}',
      );
    }
  }

  static Future<void> trackSharedPost(int postId) async {
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.shareFeedPost,
        {'post_id': postId},
      );
      if (response.data['status'] == 1) {
        CommonMethods.devLog(
          logName: 'Share response',
          message: response.data['message'],
        );
      } else {
        CommonMethods.devLog(
          logName: 'Share response',
          message: response.data['message'],
        );
      }
    } catch (e) {
      throw Exception('Failed to track shared post');
    }
  }

  static Future<void> handleEbookShare(
    String ebookTitle,
    String author,
    String description,
    BuildContext context,
  ) async {
    // String description, String imageUrl, BuildContext context) async {
    try {
      final shareContent =
          '$ebookTitle\n\n$author\n\n$description\nShared via Tiny Droplets';
      Share.share(shareContent);
    } catch (e) {
      CommonMethods.showSnackBar(
        context,
        'Failed to track share: ${e.toString()}',
      );
    }
  }

  static Future<void> commonShare(
    int id,
    String title,
    String description,
    BuildContext context,
  ) async {
    try {
      final shareContent = '$title\n\n$description\nShared via Tiny Droplets';
      Share.share(shareContent);
    } catch (e) {
      CommonMethods.showSnackBar(
        context,
        'Failed to track share: ${e.toString()}',
      );
    }
  }
}

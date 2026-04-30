// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:tinydroplets/core/constant/app_export.dart';
//
// class ShareDialog extends StatelessWidget {
//   final int postId;
//   final String postTitle;
//   final String postDescription;
//   final String postImage;
//
//   const ShareDialog({
//     super.key,
//     required this.postId,
//     required this.postTitle,
//     required this.postDescription,
//     required this.postImage,
//   });
//
//   Future<void> _handleShare(BuildContext context) async {
//     try {
//       await trackSharedPost(postId);
//       final shareContent = '$postTitle\n\n$postDescription\n\nShared via MyApp';
//       Share.share(shareContent);
//     } catch (e) {
//       CommonMethods.showSnackBar(
//           context, 'Failed to track share: ${e.toString()}');
//     }
//   }
//
//   Future<void> trackSharedPost(int postId) async {
//     final DioClient dioClient = GetIt.instance<DioClient>();
//
//     try {
//       final response = await dioClient
//           .sendPostRequest(ApiEndpoints.shareFeedPost, {'post_id': postId});
//       if (response.data['status'] == 1) {
//         CommonMethods.devLog(
//             logName: 'Share response', message: response.data['message']);
//       } else {
//         CommonMethods.devLog(
//             logName: 'Share response', message: response.data['message']);
//       }
//     } catch (e) {
//       throw Exception('Failed to track shared post');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Share Post'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (postImage.isNotEmpty)
//             Image.network(postImage, height: 100, fit: BoxFit.cover),
//           SizedBox(height: 8),
//           Text(postTitle, style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: 4),
//           Text(postDescription),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () => _handleShare(context),
//           child: Text('Share'),
//         ),
//       ],
//     );
//   }
// }

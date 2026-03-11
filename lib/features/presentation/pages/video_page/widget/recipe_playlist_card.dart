
import '../../../../../core/constant/app_export.dart';
import '../model/playlist_video_model.dart';

class RecipePlaylistCard extends StatelessWidget {
  final PlaylistVideo playlistVideo;
  const RecipePlaylistCard({super.key, required this.playlistVideo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Theme.of(context).cardColor,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CustomImage(
                      height: 180,
                      imageUrl: playlistVideo.thumbnail),
                ),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Icon(
                    Icons.play_circle_fill_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Video details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlistVideo.title, // Video title
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // SizedBox(height: 8),
                  Text(
                    playlistVideo.description, // Video title
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

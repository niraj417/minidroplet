import '../../../../../core/constant/app_export.dart';
import '../../../../../core/constant/app_vector.dart';
import 'dart:ui';

class PlaylistPaletteCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final String title;
  final String description;
  final String totalVideos;
  final String totalLength;

  const PlaylistPaletteCard({
    super.key,
    required this.imagePath,
    required this.onPressed,
    required this.title,
    required this.description,
    required this.totalVideos,
    required this.totalLength,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle descriptionStyle = TextStyle(
      fontSize: 15,
      color: Colors.white,
    );
    final TextSpan textSpan = TextSpan(
      text: description,
      style: descriptionStyle,
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 16);

    double height = 320 + textPainter.height;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: height,
              child:
                  imagePath.isNotEmpty
                      ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: CustomImage(
                          imageUrl: imagePath,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Image.asset(AppVector.logo, fit: BoxFit.cover),
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              height: height,
              color: Colors.black.withValues(alpha: 0.5),
            ),

            Positioned(
              top: 30,
              bottom: 0,
              left: 8.0,
              right: 8.0,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomImage(
                              imageUrl: imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 16,
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          softWrap: true,
                        ),
                      ),
                    ),

                    Text(
                      "Total videos: $totalVideos",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Total length: $totalLength Min",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

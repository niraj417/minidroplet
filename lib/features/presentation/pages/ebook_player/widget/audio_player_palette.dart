import 'dart:ui';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
class AudioPlayerPalette extends StatelessWidget {
  final String imagePath;
  const AudioPlayerPalette({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: imagePath.isNotEmpty
                ? CustomImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
            )
                : Image.asset(
              AppVector.logo,
              fit: BoxFit.cover,
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          // Bottom shadow and overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Spine effect
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0, // Add this
                    bottom: 0, // Add this
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
import 'dart:ui';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';

class BookPaletteCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  const BookPaletteCard({super.key, required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double height = 400.0;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              width: double.infinity,
              height: height,
              color: Colors.black.withValues(alpha: 0.2), // Optional tint
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 170,
              height: 250,
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
                  // Optional spine effect
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 250,
                      width: 10,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            right: 100,
            child: IconButton(
              onPressed: onPressed,
              color:  Colors.white,
              icon: Icon(
                Icons.play_circle_rounded,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'dart:ui';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';

class BookPaletteCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final bool showPreview;
  const BookPaletteCard({
    super.key,
    required this.imagePath,
    required this.onPressed,
    this.showPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    double height = 300.0;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath.isNotEmpty)
            Positioned.fill(
              child: CustomImage(imageUrl: imagePath, fit: BoxFit.cover),
            )
          else
            Positioned.fill(
              child: Image.asset(AppVector.logo, fit: BoxFit.cover),
            ),

          if (imagePath.isNotEmpty)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.transparent),
              ),
            ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 170,
              height: 250,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomImage(imageUrl: imagePath, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 250,
                      width: 10,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showPreview)
            Positioned(
              bottom: 0,
              right: 100,
              child: IconButton(
                onPressed: onPressed,
                color: Colors.white,
                icon: Icon(Icons.play_circle_rounded, size: 50),
              ),
            ),
        ],
      ),
    );
  }
}

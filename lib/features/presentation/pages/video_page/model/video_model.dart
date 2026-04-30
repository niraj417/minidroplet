// Models
import '../../../../../core/constant/app_export.dart';

class VideoCategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  VideoCategoryModel({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Recipe {
  final String recipeName;
  final String author;
  final String imageUrl;

  Recipe({
    required this.recipeName,
    required this.author,
    required this.imageUrl,
  });
}


import '../../../../../core/constant/app_export.dart';

class RecipeMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const RecipeMetric({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}


import '../../../../../core/constant/app_export.dart';

class IngredientItem extends StatelessWidget {
  final String name;
  final String amount;
  final String imgUrl;

  const IngredientItem({
    super.key,
    required this.name,
    required this.amount,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomImage(imageUrl: imgUrl),
        ),
        const SizedBox(width: 12),
        Text(name, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(amount, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
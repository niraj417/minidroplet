import '../../../../../core/constant/app_export.dart';

class AgeCircleWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AgeCircleWidget({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: text == 'All' ? const EdgeInsets.all(20.0) : const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isSelected ?  Colors.black54 : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color:  Colors.black54
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   'Months',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //       color: isSelected ? Colors.white :  Color(AppColor.primaryColor),
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold),
            // ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white :  Color(AppColor.primaryColor),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

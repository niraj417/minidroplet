import 'package:flutter/cupertino.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Allow null for onPressed
  final Color? color;
  final TextStyle? textStyle;
  final double borderRadius;
  final bool useCupertino;
  final double? width;
  final bool valid; // Determines if the button is enabled

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textStyle,
    this.borderRadius = 8.0,
    this.useCupertino = true,
    this.width = double.infinity,
    this.valid = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    if (useCupertino) {
      return Center(
        child: SizedBox(
          width: width,
          child: CupertinoButton(
            color: valid
                ? (color ?? Color(AppColor.primaryColor))
                : Colors.grey, // Use grey for disabled state
            borderRadius: BorderRadius.circular(borderRadius),
            onPressed: valid ? onPressed : null, // Disable button if isValid is false
            child: Text(
              text,
              style: textStyle ?? const TextStyle(color: CupertinoColors.white),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: valid
                ? (color ?? Theme.of(context).primaryColor)
                : Colors.grey, // Use grey for disabled state
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: valid ? onPressed : null, // Disable button if isValid is false
          child: Text(
            text,
            style: textStyle ?? const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
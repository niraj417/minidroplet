import 'dart:developer';
import 'package:intl/intl.dart';

import '../constant/app_export.dart';

class CommonMethods {
  static void devLog({required String logName, required dynamic message}) {
    log('$logName --------------> $message');
  }
  int? color;


  // static void showSnackBar(BuildContext context, String message,
  //     {Color color =  Color(AppColor.primaryColor)}) {
  //   final scaffoldMessenger = ScaffoldMessenger.of(context);
  //
  //   final snackBar = SnackBar(
  //     content: Text(message),
  //     backgroundColor: color,
  //     duration: Duration(seconds: 3),
  //     behavior: SnackBarBehavior.floating,
  //   );
  //
  //   scaffoldMessenger.hideCurrentSnackBar();
  //   scaffoldMessenger.showSnackBar(snackBar);
  //   Future.delayed(Duration(seconds: 3), () {
  //     scaffoldMessenger.clearSnackBars();
  //   });
  // }

  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    if (!context.mounted) {
      devLog(logName: 'SnackBar', message: 'Context not mounted, skipping: $message');
      return;
    }

    try {
      color = color ?? Color(AppColor.primaryColor);

      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      );

      scaffoldMessenger.clearSnackBars();

      scaffoldMessenger.showSnackBar(snackBar);

    } catch (e) {
      devLog(logName: 'SnackBar Error', message: 'Failed to show snackbar: $e');
    }
  }


  static void otpSnackBar(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(message)),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration.zero,
      behavior: SnackBarBehavior.floating,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  static String formatRupees(String amount) {
    String formatted = amount.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '₹$formatted';
  }


 static String sanitizeVideoUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Validate the URL format
    try {
      final uri = Uri.parse(url);
      if (!['http', 'https'].contains(uri.scheme)) {
        // If no scheme, assume http
        return 'http://${url}';
      }
      return url;
    } catch (e) {
      CommonMethods.devLog(logName: 'Invalid URL', message: e.toString());
      return '';
    }
  }

  static Color hexToColor(String hexString) {
    // Remove the hash symbol if present
    final hexCode = hexString.replaceAll('#', '');

    // Parse the hex string to an integer
    // If it's a 6-digit hex, add FF for opacity
    // If it's an 8-digit hex (with opacity), use as is
    final colorValue = int.parse(
      hexCode.length == 6 ? 'FF$hexCode' : hexCode,
      radix: 16,
    );

    return Color(colorValue);
  }
}

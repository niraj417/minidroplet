import 'package:flutter/cupertino.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

void goto(BuildContext context, Widget child) {

  Navigator.push(context, CupertinoPageRoute(builder: (context) => child));
  CommonMethods.devLog(logName: 'Page Name', message: child);
}

void gotoReplacement(BuildContext context, Widget child) {
  Navigator.pushReplacement(
      context, CupertinoPageRoute(builder: (context) => child));
  CommonMethods.devLog(logName: 'Page Name', message: child);

}

void gotoRemoveAll(BuildContext context, Widget child) {
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute(
      builder: (context) => child,
    ),
    (route) => false,
  );
  CommonMethods.devLog(logName: 'Page Name', message: child);

}

void backTo(BuildContext context) {
  Navigator.of(context).pop();
}

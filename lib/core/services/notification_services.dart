import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/injections/dependency_injection.dart';

class NotificationService {
  final _firebaseService = sl<FirebaseMessaging>();

  Future<void> initialize() async {
    await requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      CommonMethods.devLog(
          logName: 'Message received', message: message.notification?.title);
      CommonMethods.devLog(
          logName: 'Message received', message: message.notification?.body);
    });
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseService.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ CRITICAL FIX FOR iOS
    await _firebaseService.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    CommonMethods.devLog(logName: 'User granted permission:', message: settings.authorizationStatus);
  }
}

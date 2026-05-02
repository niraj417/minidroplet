import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/injections/dependency_injection.dart';

class NotificationService {
  final _firebaseService = sl<FirebaseMessaging>();

  Future<void> initialize() async {
    await requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      CommonMethods.devLog(
        logName: 'Message received',
        message: message.notification?.title,
      );
      CommonMethods.devLog(
        logName: 'Message received',
        message: message.notification?.body,
      );
    });
  }

  Future<void> requestPermission() async {
    try {
      final settings = await _firebaseService.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _firebaseService.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      CommonMethods.devLog(
        logName: 'User granted permission:',
        message: settings.authorizationStatus,
      );
    } catch (e) {
      CommonMethods.devLog(
        logName: 'Notification permission error',
        message: e.toString(),
      );
    }
  }

  Future<void> enableNotifications() async {
    try {
      await _firebaseService.subscribeToTopic("general");
      CommonMethods.devLog(logName: "Notification", message: "Enabled");
    } catch (e) {
      CommonMethods.devLog(logName: "Enable Error", message: e.toString());
    }
  }

  Future<void> disableNotifications() async {
    try {
      await _firebaseService.unsubscribeFromTopic("general");
      CommonMethods.devLog(logName: "Notification", message: "Disabled");
    } catch (e) {
      CommonMethods.devLog(logName: "Disable Error", message: e.toString());
    }
  }
}

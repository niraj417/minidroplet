  import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../utils/common_methods.dart';

  class FCMService {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    FirebaseMessaging get firebaseMessaging => _firebaseMessaging;

    Future<void> initializeFCMToken() async {
      try {
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // ✅ CRITICAL FIX FOR iOS
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          CommonMethods.devLog(logName: 'User granted notification permissions', message: settings.authorizationStatus.toString());

          String? fcmToken = await _firebaseMessaging.getToken();

          if (fcmToken != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('fcmToken', fcmToken);
            CommonMethods.devLog(logName: 'FCM Token saved', message: fcmToken);
          } else {
            CommonMethods.devLog(logName: 'Failed to fetch FCM Token', message: '');
          }

          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            String? apnsToken = await _firebaseMessaging.getAPNSToken();
            CommonMethods.devLog(logName: 'APNS Token:', message: apnsToken ?? 'No APNS token available');
          }
        } else {
          CommonMethods.devLog(logName: 'Notification permissions not granted', message: settings.authorizationStatus.toString());
        }
      } catch (e) {
        CommonMethods.devLog(logName: 'Error initializing FCM Token:', message: e.toString());
      }
    }

    Future<void> getFcmToken() async {
      try {
        String? fcmToken = await _firebaseMessaging.getToken();
        CommonMethods.devLog(logName: 'FCM Token:', message: fcmToken ?? 'No token available');
      } catch (e) {
        CommonMethods.devLog(logName: 'Error fetching FCM Token:', message: e.toString());
      }
    }

    Future<void> setupBackgroundHandler() async {
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    }

    static Future<void> backgroundHandler(RemoteMessage message) async {
      print('Handling background message: ${message.messageId}');
    }
  }



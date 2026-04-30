import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> initOneSignal() async {
  // Remove this method to stop OneSignal Debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // The OneSignal App ID from your OneSignal dashboard
  OneSignal.initialize("YOUR_ONESIGNAL_APP_ID");

  // Set permissions to request notification permissions on iOS
  OneSignal.Notifications.requestPermission(true);

  // Handle notification opened events
  OneSignal.Notifications.addClickListener((event) {
    print("Notification clicked: ${event.notification.notificationId}");

    // Extract additional data attached to the notification
    if (event.notification.additionalData != null) {
      print("Additional data: ${event.notification.additionalData}");

      // You can navigate to a specific screen based on the additional data
      // Navigator.pushNamed(context, '/details', arguments: event.notification.additionalData);
    }
  });

  // Handle notification received events (when app is in foreground)
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Notification received in foreground: ${event.notification.notificationId}");

    // You can show an in-app notification here or update the UI
    // showInAppNotification(event.notification);

    // Optionally prevent the default display of the notification
    // event.preventDefault();
  });
}
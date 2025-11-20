// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class InAppNotificationService {
  // Singleton pattern
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  // Global key to access the navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Show in-app notification
  void showInAppNotification(OSNotification notification) {
    if (navigatorKey.currentContext != null) {
      // Get the overlay context
      final overlayState = Overlay.of(navigatorKey.currentContext!);

      // Create overlay entry
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: InkWell(
              onTap: () {
                // Handle notification tap
                overlayEntry.remove();

                // Process additional data if any
                if (notification.additionalData != null) {
                  // Navigate to specific screen based on additional data
                  // Navigator.pushNamed(context, '/details', arguments: notification.additionalData);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notification.title ?? 'New Notification',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (notification.body != null)
                            Text(
                              notification.body!,
                              style: TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16),
                      onPressed: () => overlayEntry.remove(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Add the overlay entry
      overlayState.insert(overlayEntry);

      // Auto dismiss after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }
}
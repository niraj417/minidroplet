import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tinydroplets/core/services/ad_service/ad_manager.dart';
import 'package:tinydroplets/core/services/notification_services.dart';
import 'package:tinydroplets/core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_controller.dart';
import '../core/services/payment_service.dart';
import '../core/services/payment_service/payment_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  if (!sl.isRegistered<FirebaseMessaging>()) {
    sl.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  }

  if (!sl.isRegistered<FCMService>()) {
    sl.registerSingleton<FCMService>(FCMService());
  }
  if (!sl.isRegistered<PaymentService>()) {
    sl.registerLazySingleton<PaymentService>(() => PaymentService());
  }
  if (!sl.isRegistered<Razorpay>()) {
    sl.registerLazySingleton(() => Razorpay());
  }
  if (!sl.isRegistered<PaymentBloc>()) {
    sl.registerLazySingleton(() => PaymentBloc(razorpay: sl(), dioClient: sl()));
  }
  if (!sl.isRegistered<DioClient>()) {
    sl.registerSingleton<DioClient>(DioClient());
  }
  if (!sl.isRegistered<AdManager>()) {
    sl.registerSingleton<AdManager>(AdManager());
  }

  _initializeOptionalMessagingServices();
}

void _initializeOptionalMessagingServices() {
  Future<void>(() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('Notification service init failed: $e');
    }

    try {
      await sl<FCMService>().initializeFCMToken();
    } catch (e) {
      debugPrint('FCM token init failed: $e');
    }

    try {
      await sl<FCMService>().setupBackgroundHandler();
    } catch (e) {
      debugPrint('FCM background handler setup failed: $e');
    }
  });
}

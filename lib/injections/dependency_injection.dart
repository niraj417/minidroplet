import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinydroplets/core/services/ad_service/ad_manager.dart';
import 'package:tinydroplets/core/services/notification_services.dart';
import 'package:tinydroplets/core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../core/network/api_controller.dart';
import '../core/services/payment_service.dart';
import '../core/services/payment_service/payment_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  //final sharedPrefs = await SharedPreferences.getInstance();
  //sl.registerSingleton<SharedPreferences>(sharedPrefs);

  await Firebase.initializeApp();

  final firebaseMessaging = FirebaseMessaging.instance;
  sl.registerSingleton<FirebaseMessaging>(firebaseMessaging);

  final fcmService = FCMService();
  sl.registerSingleton<FCMService>(fcmService);
  sl.registerLazySingleton<PaymentService>(() => PaymentService());
  sl.registerLazySingleton(() => Razorpay());

  sl.registerLazySingleton(() => PaymentBloc(razorpay: sl(), dioClient: sl()));

  await NotificationService().initialize();

  await fcmService.initializeFCMToken();
  await fcmService.setupBackgroundHandler();
  sl.registerSingleton<DioClient>(DioClient());
  sl.registerSingleton<AdManager>(AdManager());
}

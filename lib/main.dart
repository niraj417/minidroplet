import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // ✅ ADDED
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/app_restart_widget.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/theme/theme_manager.dart';
import 'package:tinydroplets/core/utils/bloc_provider_helper.dart';
import 'package:tinydroplets/features/presentation/pages/splash_page/launcher_page.dart';

import 'core/services/ad_service/ad_manager.dart';
import 'core/theme/theme_bloc/theme_bloc.dart';
import 'core/theme/theme_bloc/theme_state.dart';
import 'injections/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPref FIRST
  await SharedPref.init();

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  GestureBinding.instance.resamplingEnabled = false;

  await MobileAds.instance.initialize();

  // ✅ ADDED — Request App Tracking Transparency on iOS before ads load
  if (Platform.isIOS) {
    await requestTrackingPermission();
  }

  if (Platform.isAndroid && !kDebugMode) {
    await applyNativeSecurity();
  }

  if (Platform.isIOS) {
    setupScreenshotDetection();
  }

  await setupLocator();

  if (Platform.isAndroid) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.yourcompany.app.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      );
    } catch (e) {
      debugPrint('Error initializing audio background: $e');
    }
  }

  runApp(AppRestartWidget(child: BlocProviderHelper(child: MyApp())));
}

// ✅ ADDED — ATT permission request for iOS 14+
Future<void> requestTrackingPermission() async {
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      // Small delay recommended by Apple — avoids rejection if called too early
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('ATT permission result: $result');
    } else {
      debugPrint('ATT status already set: $status');
    }
  } catch (e) {
    debugPrint('Error requesting ATT permission: $e');
  }
}

Future<void> applyNativeSecurity() async {
  if (kDebugMode) {
    debugPrint('Debug mode active: skipping native screen security');
    return;
  }

  try {
    const platform = MethodChannel(
      'com.tinydroplets.tinydroplets/secure_screen',
    );
    await platform.invokeMethod('disableSecureScreen');
    debugPrint('Native screen security enabled');
  } catch (e) {
    debugPrint('Error enabling native security: $e');
  }
}

void setupScreenshotDetection() {
  const MethodChannel channel = MethodChannel('flutter/userInterfaceIdiom');
  channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'userScreenshot') {
      showScreenshotWarning();
    }
  });
}

void showScreenshotWarning() {
  if (navigatorKey.currentContext != null) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 36),
                SizedBox(height: 12),
                Text(
                  'Screenshot Detected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Taking screenshots of this content is not allowed for security reasons.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Understand'),
                ),
              ],
            ),
          ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdManager().checkAdStatus(context);
      initialization();
    });
  }

  void initialization() async {
    print("Pausing");
    await Future.delayed(Duration(seconds: 3));
    print("unpausing");
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isAndroid && !kDebugMode) {
        applyNativeSecurity();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        ThemeData theme;
        if (state is DarkThemeState) {
          theme = ThemeManager.darkTheme.copyWith(
            primaryColor: Color(AppColor.primaryColor),
          );
        } else if (state is LightThemeState) {
          theme = ThemeManager.lightTheme.copyWith(
            primaryColor: Color(AppColor.primaryColor),
          );
        } else {
          theme = ThemeManager.lightTheme;
        }

        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              themeMode:
                  (state is DarkThemeState) ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: ThemeManager.darkTheme.copyWith(
                primaryColor: Color(AppColor.primaryColor),
              ),
              home: LauncherPage(),
            );
          },
        );
      },
    );
  }
}

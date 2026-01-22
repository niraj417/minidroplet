import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';
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
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  GestureBinding.instance.resamplingEnabled = false;

  await MobileAds.instance.initialize();

  if (Platform.isAndroid && !kDebugMode) {
    await applyNativeSecurity();
  }

  if (Platform.isIOS) {
    setupScreenshotDetection();
  }

  await setupLocator();
  // final paymentService = PaymentService();
  // await paymentService.initialize();
  //
  // print("Live mode: ${paymentService.isLiveMode}");
  // print("Test mode: ${paymentService.isTestMode}");
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

  runApp(BlocProviderHelper(child: MyApp()));
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
              // home: NewOnboardingPage(),
              // home: SizedBox.shrink(),
              // home: LetsGetStartedPage(),
              // home: SplashPage(),
            );
          }
        );
      },
    );
  }
}

/*

// For ios we can not hide or prevent this so we need to add this.

Widget buildWatermarkedContent(Widget child) {
  return Stack(
    children: [
      child,
      Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Transform.rotate(
              angle: -0.5,
              child: Text(
                "CONFIDENTIAL - UserID: 12345",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.3),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}*/

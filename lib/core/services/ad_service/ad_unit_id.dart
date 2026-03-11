import 'dart:io';

class AdUnitId {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8918303949279078/1593231389";
    } else if (Platform.isIOS) {
      // Currently i am returning same ad unit id
      return "ca-app-pub-8918303949279078/1593231389";
    } else {
      throw UnimplementedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8918303949279078/5455357299";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8918303949279078/5455357299";
    } else {
      throw UnimplementedError("Unsupported platform");
    }
  }
}

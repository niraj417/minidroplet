import UIKit
import Flutter
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Must be called before GeneratedPluginRegistrant
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    GeneratedPluginRegistrant.register(with: self)

    // Optional: Only cast after Flutter engine setup
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.tinydroplets.tinydroplets/secure_screen",
        binaryMessenger: controller.binaryMessenger
      )

      setupScreenshotNotification(controller: controller)

      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "enableSecureScreen":
          result(true)
        case "isSecureScreenEnabled":
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

 

  private func setupScreenshotNotification(controller: FlutterViewController) {
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { _ in
      let screenshotChannel = FlutterMethodChannel(
        name: "flutter/userInterfaceIdiom",
        binaryMessenger: controller.binaryMessenger
      )
      screenshotChannel.invokeMethod("userScreenshot", arguments: nil)
    }
  }
}
 private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
      FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
  }
package com.tinydroplets.tinydroplets

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.tinydroplets.tinydroplets/secure_screen"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Hardware acceleration — set after super.onCreate to avoid MIUI window manager crash
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )

        // FLAG_SECURE: wrapped in try-catch because MIUI/HyperOS on Redmi devices
        // can throw when this is applied before the Flutter engine is fully attached.
        try {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } catch (e: Exception) {
            // Graceful degradation on MIUI — security flag will be applied via MethodChannel
        }

        // Make the app draw behind system bars
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Handle splash screen for Android 12+
        // Wrapped in try-catch: MIUI customizes the Android 12 splash screen API
        // in an incompatible way, causing crashes on many Redmi devices.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                splashScreen.setOnExitAnimationListener { splashScreenView ->
                    splashScreenView.remove()
                }
            } catch (e: Exception) {
                // Graceful fallback on MIUI/HyperOS Redmi devices
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureScreen" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                "disableSecureScreen" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                "isSecureScreenEnabled" -> {
                    val isSecure = (window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE) != 0
                    result.success(isSecure)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

package com.tinydroplets.tinydroplets

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channel = "com.tinydroplets.tinydroplets/secure_screen"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } catch (_: Exception) {
            // Some HyperOS builds are unstable when window flags are changed during launch.
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                splashScreen.setOnExitAnimationListener { splashScreenView ->
                    splashScreenView.remove()
                }
            } catch (_: Exception) {
                // Ignore OEM splash screen incompatibilities.
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecureScreen" -> result.success(updateSecureScreen(true))
                    "disableSecureScreen" -> result.success(updateSecureScreen(false))
                    "isSecureScreenEnabled" -> {
                        val isSecure =
                            (window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE) != 0
                        result.success(isSecure)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun updateSecureScreen(enable: Boolean): Boolean {
        return try {
            if (enable) {
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
            true
        } catch (_: Exception) {
            false
        }
    }
}

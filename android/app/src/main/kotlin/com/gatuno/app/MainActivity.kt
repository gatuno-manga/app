package com.gatuno.app

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (biometric prompt).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRIVACY_SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEnabled" -> {
                        setPrivacyScreenEnabled(call.argument<Boolean>("enabled") == true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // FLAG_SECURE blanks the app-switcher thumbnail (and blocks screenshots)
    // while the app lock is on.
    private fun setPrivacyScreenEnabled(enabled: Boolean) {
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private companion object {
        const val PRIVACY_SCREEN_CHANNEL = "com.gatuno.app/privacy_screen"
    }
}

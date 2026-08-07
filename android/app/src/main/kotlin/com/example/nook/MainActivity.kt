package com.example.nook

import android.media.MediaScannerConnection
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "nook/media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    MediaScannerConnection.scanFile(context, arrayOf(path), null) { _, uri ->
                        result.success(uri?.toString())
                    }
                } else {
                    result.error("INVALID_PATH", "Path was null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

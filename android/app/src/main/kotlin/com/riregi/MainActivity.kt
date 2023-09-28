package com.riregi

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageInfo
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.riregi/lib"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getDataLibPath") {
                val ainfo = this.applicationContext.packageManager.getApplicationInfo(
                    "com.riregi",
                    PackageManager.GET_SHARED_LIBRARY_FILES,
                )
                result.success(ainfo.nativeLibraryDir + "/libriregi-data.so")
            } else {
                result.notImplemented();
            }
        }
    }
}
